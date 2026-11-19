--[[
mapping-tips.lua -- startup tips for your own key mappings, plus usage tracking.

WHAT IT IS
  A tiny self-contained Neovim plugin (one file, no dependencies). When Neovim
  starts on an empty buffer it shows a floating "tip" reminding you of one of
  the mappings or commands defined in your init.vim. It also counts how often
  you actually press each mapped key sequence, so you can prune dead mappings.

  The tip pool is parsed from your config at runtime, so it stays in sync when
  you edit init.vim -- no hardcoded list to maintain.

HOW IT IS LOADED
  This file lives in the dotfiles repo (/Users/albo/config) and is symlinked
  into a plugin directory, so Neovim sources it automatically at startup:

    mkdir -p ~/.config/nvim/plugin
    ln -sfn /Users/albo/config/mapping-tips.lua \
      ~/.config/nvim/plugin/mapping-tips.lua

  init.vim does NOT need to change: Neovim sources plugin/*.lua by itself.

COMMANDS
  :MapTip              show another tip now (blank-buffer rule applies)
  :MapTip!             show another tip even outside a blank buffer
  :MapTips             list all parsed mappings/commands in a scratch split
  :MapTips unused      list only mappings never used
  :MapTips used        list only mappings that have been used
  :MapTips refresh     re-read init.vim and refresh the list
  :MapTips disable     switch the plugin off for this session
  :MapTips enable      switch it back on (and start tracking keys)
  :MapTips close       close the opened list

  In the list: q closes the split, <CR> jumps to the mapping's source line.

CONFIG KNOBS (vim.g, all optional)
  vim.g.mapping_tips                 = false   disable tips/tracking
  vim.g.mapping_tips_once_per_day    = 1       show the startup tip at most
                                               once per calendar day
  vim.g.mapping_tips_duration        = 10      auto-close after N seconds
                                               (clamped to 6..15)

  Every other tunable lives in the `config` table below (weights, width,
  parser source paths, stats location, key buffer size, ...).

PERSISTENCE
  Counts live in <stdpath('state')>/mapping-tips.json (created on demand,
  written atomically, debounced to once every ~30s and again on VimLeavePre).

STATE SHAPE
  {
    version = 1,
    seen = { ["<Space> a"] = { count = 3, last = 1700000000 }, ... },
    last_shown = "2026-11-19",
  }

  The `seen` key is the canonical key sequence: <leader> expanded, special
  keys in <Key> notation, tokens joined by single spaces. Mappings that share
  the same lhs in different modes therefore share one counter (e.g. the
  normal- and insert-mode <F3> mappings); that is deliberate and harmless for
  pruning -- if the counter is zero, both are dead.

NOTES
  * Everything is wrapped in pcall: a parser or UI failure can never break
    startup and never prints errors.
  * Sourcing this file twice re-creates tags/autocmds with clear = true and
    re-registers a single on_key handler, so nothing is duplicated.
  * Only rhs containing <Plug>/<SID>/<Cmd> are skipped -- unless a comment
    directly above describes them (then they are genuinely useful tips).
--]]

if not (type(vim) == 'table' and vim.api and vim.fn) then
  return {}
end

local M = {}

--- Tunables. Everything you may want to change is here. --------------------
local config = {
  enabled = true,
  -- Parsed at runtime, in order; duplicates (symlinks) are resolved away.
  source_files = { '~/.config/nvim/init.vim', '~/config/init.vim' },
  stats_name = 'mapping-tips.json', -- relative to stdpath('state')
  startup_delay_ms = 400,
  duration_ms = 10000,
  min_duration_s = 6,
  max_duration_s = 15,
  close_grace_ms = 500, -- ignore close triggers right after showing
  min_width = 36,
  max_width = 72,
  weight = { unused = 4, used = 1 },
  key_buffer = 12,
  -- false => also count sequences when the current mode does not match
  mode_aware = true,
  save_interval_ms = 30000,
  once_per_day = false,
  show_commands = true,
  -- keep <Plug>/<SID>/<Cmd> mappings when a comment describes them
  described_private_rhs = true,
  private_rhs = { '<plug>', '<sid>', '<cmd>' },
  list_limit = 500,
}

local MODIFIERS = {
  silent = true,
  nowait = true,
  expr = true,
  buffer = true,
  unique = true,
  script = true,
  special = true,
}

local MAP_CMDS = {
  map = '',
  nmap = 'n',
  imap = 'i',
  vmap = 'v',
  xmap = 'x',
  smap = 's',
  omap = 'o',
  cmap = 'c',
  tmap = 't',
  lmap = 'l',
  noremap = '',
  nnoremap = 'n',
  inoremap = 'i',
  vnoremap = 'v',
  xnoremap = 'x',
  snoremap = 's',
  onoremap = 'o',
  cnoremap = 'c',
  tnoremap = 't',
  lnoremap = 'l',
}

local PRETTY_KEYS = {
  cr = 'CR',
  tab = 'Tab',
  esc = 'Esc',
  bs = 'BS',
  del = 'Del',
  space = 'Space',
  leader = 'Leader',
  localleader = 'LocalLeader',
}

local MODE_LABEL = {
  [''] = 'all',
  n = 'n',
  i = 'i',
  v = 'v',
  x = 'x',
  s = 's',
  o = 'o',
  c = 'c',
  t = 't',
  l = 'l',
  ['!'] = 'i/c',
  [':'] = ':',
}

local ns = vim.api.nvim_create_namespace('mapping-tips')

local state = {
  setup_done = false,
  parsed = false,
  parsed_stamp = -1,
  tips = {},
  index = {},
  stats = { version = 1, seen = {}, last_shown = '' },
  current = nil,
  win = nil,
  buf = nil,
  timer = nil,
  remaining = 0,
  countdown_row = nil,
  shown_at = 0,
  tail = {},
  mode = 'n',
  dirty = false,
  flush_scheduled = false,
  tracking = false,
  disabled = false,
  list_rows = setmetatable({}, { __mode = 'k' }),
  list_bufs = setmetatable({}, { __mode = 'k' }),
  command_by_name = {},
}

-- Small helpers -------------------------------------------------------------

local function leader()
  local v = vim.g.mapleader
  if type(v) == 'string' and v ~= '' then
    return v
  end
  return '\\'
end

local function localleader()
  local v = vim.g.maplocalleader
  if type(v) == 'string' and v ~= '' then
    return v
  end
  return leader()
end

local function trim(s)
  return (s:gsub('^%s+', ''):gsub('%s+$', ''))
end

local function display_width(s)
  local ok, w = pcall(vim.fn.strdisplaywidth, s)
  if ok and type(w) == 'number' then
    return w
  end
  return #s
end

local function truncate(s, width)
  if width <= 1 or s == '' then
    return ''
  end
  if display_width(s) <= width then
    return s
  end
  local ok, out = pcall(function()
    local chars = vim.fn.strchars(s)
    local text = s
    while chars > 0 and display_width(text .. '…') > width do
      chars = chars - 1
      text = vim.fn.strcharpart(s, 0, chars)
    end
    return text .. '…'
  end)
  if ok then
    return out
  end
  return s:sub(1, width)
end

local function pad(s, width)
  local w = display_width(s)
  if w >= width then
    return s
  end
  return s .. string.rep(' ', width - w)
end

local function random_int(n)
  if n <= 0 then
    return 1
  end
  local ok, v = pcall(vim.fn.rand)
  if ok and type(v) == 'number' and v >= 0 then
    return v % n + 1
  end
  return math.random(n)
end

local function today()
  return os.date('%Y-%m-%d')
end

local function stats_path()
  local ok, dir = pcall(vim.fn.stdpath, 'state')
  if not ok or type(dir) ~= 'string' then
    dir = vim.fn.expand('~/.local/state/nvim')
  end
  return dir .. '/' .. config.stats_name
end

-- Config values that vim.g may override ------------------------------------

local function is_enabled()
  if state.disabled then
    return false
  end
  local g = vim.g.mapping_tips
  if g == nil then
    return config.enabled
  end
  return not (g == false or g == 0 or g == '0')
end

local function once_per_day()
  local g = vim.g.mapping_tips_once_per_day
  if g == nil then
    return config.once_per_day
  end
  return not (g == false or g == 0 or g == '0')
end

local function duration_s()
  local g = tonumber(vim.g.mapping_tips_duration)
  local secs
  if g then
    secs = g
  else
    secs = config.duration_ms / 1000
  end
  if secs < config.min_duration_s then
    secs = config.min_duration_s
  elseif secs > config.max_duration_s then
    secs = config.max_duration_s
  end
  return math.floor(secs)
end

-- Stats persistence ---------------------------------------------------------

local function load_stats()
  local out = { version = 1, seen = {}, last_shown = '' }
  local ok, lines = pcall(vim.fn.readfile, stats_path())
  if not ok or type(lines) ~= 'table' then
    return out
  end
  local ok2, data = pcall(vim.json.decode, table.concat(lines, '\n'))
  if not ok2 or type(data) ~= 'table' then
    return out
  end
  if type(data.seen) == 'table' then
    for key, val in pairs(data.seen) do
      if type(key) == 'string' and type(val) == 'table' then
        local count = tonumber(val.count) or 0
        if count > 0 then
          out.seen[key] = {
            count = math.floor(count),
            last = tonumber(val.last) or 0,
          }
        end
      elseif type(key) == 'string' and type(val) == 'number' then
        out.seen[key] = { count = math.floor(val), last = 0 }
      end
    end
  end
  if type(data.last_shown) == 'string' then
    out.last_shown = data.last_shown
  end
  return out
end

local function write_stats()
  local path = stats_path()
  local dir = vim.fn.fnamemodify(path, ':h')
  pcall(function()
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, 'p')
    end
  end)
  local ok, encoded = pcall(vim.json.encode, {
    version = 1,
    seen = next(state.stats.seen) == nil and vim.empty_dict() or state.stats.seen,
    last_shown = state.stats.last_shown or '',
  })
  if not ok or type(encoded) ~= 'string' then
    return false
  end
  local tmp = path .. '.tmp'
  local ok2 = pcall(vim.fn.writefile, { encoded }, tmp)
  if not ok2 then
    return false
  end
  local renamed = os.rename(tmp, path)
  if renamed then
    return true
  end
  local ok3 = pcall(vim.fn.rename, tmp, path)
  return ok3
end

local function save_stats()
  if not state.dirty then
    return
  end
  local ok, wrote = pcall(write_stats)
  if ok and wrote then
    state.dirty = false
  end
end

local function schedule_save()
  state.dirty = true
  if state.flush_scheduled then
    return
  end
  state.flush_scheduled = true
  pcall(vim.defer_fn, function()
    state.flush_scheduled = false
    save_stats()
  end, config.save_interval_ms)
end

-- Mapping parsing -----------------------------------------------------------

local function read_source(path)
  local expanded = vim.fn.expand(path)
  local ok, readable = pcall(vim.fn.filereadable, expanded)
  if not ok or readable == 0 then
    return nil
  end
  local ok2, lines = pcall(vim.fn.readfile, expanded)
  if not ok2 or type(lines) ~= 'table' then
    return nil
  end
  return {
    path = expanded,
    label = vim.fn.fnamemodify(expanded, ':t'),
    lines = lines,
  }
end

local function resolve_sources()
  local out, seen = {}, {}
  for _, path in ipairs(config.source_files) do
    local src = read_source(path)
    if src then
      local real = src.path
      local ok, resolved = pcall(vim.fn.resolve, src.path)
      if ok and type(resolved) == 'string' and resolved ~= '' then
        real = resolved
      end
      if not seen[real] then
        seen[real] = true
        src.path = real
        src.label = vim.fn.fnamemodify(real, ':t')
        out[#out + 1] = src
      end
    end
  end
  return out
end

-- Join vimscript continuation lines (leading backslash) into logical lines.
local function logical_lines(lines)
  local out = {}
  local i = 1
  while i <= #lines do
    local text = lines[i]
    local start = i
    while i < #lines and lines[i + 1]:match('^%s*\\') do
      i = i + 1
      local cont = lines[i]:gsub('^%s*\\%s?', '')
      text = text .. ' ' .. cont
    end
    out[#out + 1] = { text = text, line = start }
    i = i + 1
  end
  return out
end

local function parse_description(lines, start_line)
  local parts = {}
  local i = start_line - 1
  while i >= 1 do
    local raw = lines[i]
    if not raw:match('^%s*"') then
      break
    end
    local text = trim(raw:gsub('^%s*"', ''))
    local decorative = text:match('^"*$') ~= nil
    local section = text:match('^=>') ~= nil
    if not decorative and not section then
      table.insert(parts, 1, text)
    end
    i = i - 1
  end
  return trim(table.concat(parts, ' '):gsub('%s+', ' '))
end

local function tokenize(lhs)
  local toks = {}
  local i = 1
  while i <= #lhs do
    local special = lhs:match('^<[^<>]+>', i)
    if special then
      toks[#toks + 1] = special
      i = i + #special
    else
      local ch = lhs:match('^[%z\1-\127\194-\244][\128-\191]*', i)
      if not ch or ch == '' then
        ch = lhs:sub(i, i)
      end
      toks[#toks + 1] = ch
      i = i + #ch
    end
  end
  return toks
end

local function canon_token(tok)
  local low = tok:lower()
  if low == '<leader>' then
    tok = leader()
  elseif low == '<localleader>' then
    tok = localleader()
  end
  local ok, raw = pcall(vim.api.nvim_replace_termcodes, tok, true, true, true)
  if not ok or type(raw) ~= 'string' or raw == '' then
    return low
  end
  local ok2, kt = pcall(vim.fn.keytrans, raw)
  if ok2 and type(kt) == 'string' and kt ~= '' then
    return kt
  end
  return low
end

local function expand_lhs(lhs)
  local s = lhs
  s = s:gsub('<[Ll][Ee][Aa][Dd][Ee][Rr]>', function()
    return leader()
  end)
  s = s:gsub('<[Ll][Oo][Cc][Aa][Ll][Ll][Ee][Aa][Dd][Ee][Rr]>', function()
    return localleader()
  end)
  s = s:gsub('<[Ss][Pp][Aa][Cc][Ee]>', '␣')
  s = s:gsub('<([^<>]+)>', function(inner)
    local low = inner:lower()
    if PRETTY_KEYS[low] then
      return '<' .. PRETTY_KEYS[low] .. '>'
    end
    local mod, key = low:match('^([csdam])%-(.+)$')
    if mod and key then
      key = PRETTY_KEYS[key] or key:upper()
      return '<' .. mod:upper() .. '-' .. key .. '>'
    end
    return '<' .. inner .. '>'
  end)
  return s
end

local function describe_rhs(rhs)
  local s = trim(rhs:gsub('%s+', ' '))
  if s == '' then
    return '(no rhs)'
  end
  return truncate(s, 46)
end

local function is_private_rhs(rhs)
  local low = rhs:lower()
  for _, needle in ipairs(config.private_rhs) do
    if low:find(needle, 1, true) then
      return true
    end
  end
  return false
end

local function parse_mapping_line(text)
  local cmd, rest = text:match('^%s*([%a]+!?)%s+(.+)$')
  if not cmd then
    return nil
  end
  local bang = cmd:sub(-1) == '!'
  if bang then
    cmd = cmd:sub(1, -2)
  end
  local mode = MAP_CMDS[cmd]
  if not mode then
    return nil
  end
  if bang then
    if cmd == 'map' or cmd == 'noremap' then
      mode = '!'
    else
      return nil
    end
  end

  local mods = {}
  while true do
    local mod, tail = rest:match('^<([%w%-]+)>%s*(.*)$')
    if not mod or not MODIFIERS[mod:lower()] then
      break
    end
    mods[mod:lower()] = true
    rest = tail
  end

  local lhs, rhs = rest:match('^(%S+)%s*(.*)$')
  if not lhs or lhs == '' or rhs == '' then
    return nil
  end
  return { mode = mode, lhs = lhs, rhs = rhs, mods = mods }
end

local function parse_command_line(text)
  local body = text:match('^%s*command!?%s+(.+)$')
  if not body then
    return nil
  end
  while true do
    local flag, tail = body:match('^(%-%-?%S+)%s+(.*)$')
    if not flag then
      break
    end
    body = tail
  end
  local name, rest = body:match('^(%S+)%s*(.*)$')
  if not name or not name:match('^%u[%w]*$') then
    return nil
  end
  if rest == '' then
    return nil
  end
  return { name = name, rhs = rest }
end

local function make_mapping_tip(src, entry, parsed, desc)
  local toks = tokenize(parsed.lhs)
  local keys = {}
  for i, tok in ipairs(toks) do
    keys[i] = canon_token(tok)
  end
  return {
    kind = 'mapping',
    mode = parsed.mode,
    lhs = expand_lhs(parsed.lhs),
    raw_lhs = parsed.lhs,
    rhs = describe_rhs(parsed.rhs),
    desc = desc,
    file = src.label,
    path = src.path,
    line = entry.line,
    tokens = keys,
    keys = table.concat(keys, ' '),
  }
end

local function make_command_tip(src, entry, parsed, desc)
  return {
    kind = 'command',
    mode = ':',
    lhs = ':' .. parsed.name,
    raw_lhs = ':' .. parsed.name,
    rhs = describe_rhs(parsed.rhs),
    desc = desc,
    file = src.label,
    path = src.path,
    line = entry.line,
    tokens = {},
    keys = ':' .. parsed.name,
  }
end

--- Parse one file. Returns a list of tip tables. Exposed as M.parse for tests.
local function parse_file(src)
  local tips = {}
  local index = {}
  local in_function = 0
  local fallback = 'mapped in ' .. src.label
  local last_desc, last_desc_line = '', -10

  for _, entry in ipairs(logical_lines(src.lines)) do
    local text = entry.text

    if text:match('^%s*endf%a*') then
      in_function = math.max(0, in_function - 1)
    elseif text:match('^%s*fu%a*!?%s') then
      in_function = in_function + 1
    elseif in_function == 0 then
      local parsed = parse_mapping_line(text)
      if parsed then
        local desc = parse_description(src.lines, entry.line)
        local private = is_private_rhs(parsed.rhs)
        -- A private rhs is only a useful tip when something describes it. If the
        -- comment sits above the previous, related mapping (q / <leader>q),
        -- borrow that description.
        if desc == '' and private and last_desc ~= '' and entry.line - last_desc_line <= 3 then
          desc = last_desc
        end
        local keep = not private or (config.described_private_rhs and desc ~= '')
        if keep then
          if desc ~= '' then
            last_desc, last_desc_line = desc, entry.line
          end
          local tip = make_mapping_tip(src, entry, parsed, desc ~= '' and desc or fallback)
          local key = tip.mode .. '\0' .. tip.keys
          if index[key] then
            tips[index[key]] = tip -- later definition wins, like Vim itself
          else
            tips[#tips + 1] = tip
            index[key] = #tips
          end
        end
      elseif config.show_commands then
        local command = parse_command_line(text)
        if command then
          local desc = parse_description(src.lines, entry.line)
          local tip = make_command_tip(
            src,
            entry,
            command,
            desc ~= '' and desc or ('command from ' .. src.label)
          )
          tips[#tips + 1] = tip
        end
      end
    end
  end
  return tips
end

local function build_index()
  local index = {}
  local commands = {}
  for _, tip in ipairs(state.tips) do
    if tip.kind == 'command' then
      commands[tip.raw_lhs:sub(2)] = tip
    elseif #tip.tokens > 0 then
      local last = tip.tokens[#tip.tokens]
      local bucket = index[last]
      if not bucket then
        bucket = {}
        index[last] = bucket
      end
      bucket[#bucket + 1] = tip
    end
  end
  for _, bucket in pairs(index) do
    table.sort(bucket, function(a, b)
      return #a.tokens > #b.tokens
    end)
  end
  state.index = index
  state.command_by_name = commands
end

local function ensure_parsed(force)
  local srcs = resolve_sources()
  local stamp = 0
  for _, src in ipairs(srcs) do
    stamp = stamp + (tonumber(vim.fn.getftime(src.path)) or 0)
  end
  if not force and state.parsed and stamp == state.parsed_stamp then
    return
  end
  local tips = {}
  for _, src in ipairs(srcs) do
    local ok, parsed = pcall(parse_file, src)
    if ok and type(parsed) == 'table' then
      for _, tip in ipairs(parsed) do
        tips[#tips + 1] = tip
      end
    end
  end
  state.tips = tips
  state.parsed = true
  state.parsed_stamp = stamp
  build_index()
end

function M.parse(path)
  local src = read_source(path or config.source_files[1])
  if not src then
    return {}
  end
  return parse_file(src)
end

function M.tips()
  ensure_parsed(false)
  return state.tips
end

function M.stats()
  return state.stats
end

-- Usage tracking ------------------------------------------------------------

local function count_of(tip)
  local entry = state.stats.seen[tip.keys]
  if type(entry) == 'table' then
    return tonumber(entry.count) or 0
  end
  return 0
end

local function mode_letter(mode)
  if type(mode) ~= 'string' or mode == '' then
    return ''
  end
  local c = mode:sub(1, 1)
  if c == 'n' then
    return 'n'
  elseif c == 'i' then
    return 'i'
  elseif c == 'v' or c == 'V' or c == '\22' then
    return 'v'
  elseif c == 's' or c == 'S' then
    return 's'
  elseif c == 'c' then
    return 'c'
  elseif c == 't' then
    return 't'
  elseif c == 'o' then
    return 'o'
  elseif c == 'R' then
    return 'i'
  end
  return c
end

local function mode_matches(tip, current)
  if not config.mode_aware or tip.mode == '' or current == '' then
    return true
  end
  if tip.mode == current then
    return true
  end
  if tip.mode == 'x' and current == 'v' then
    return true
  end
  if tip.mode == 's' and current == 'v' then
    return true
  end
  if tip.mode == '!' and (current == 'i' or current == 'c') then
    return true
  end
  return false
end

local function suffix_matches(tokens)
  local n = #tokens
  if n == 0 or #state.tail < n then
    return false
  end
  local offset = #state.tail - n
  for i = 1, n do
    if state.tail[offset + i] ~= tokens[i] then
      return false
    end
  end
  return true
end

local function record(tip)
  local entry = state.stats.seen[tip.keys]
  if type(entry) ~= 'table' then
    entry = { count = 0, last = 0 }
    state.stats.seen[tip.keys] = entry
  end
  entry.count = (tonumber(entry.count) or 0) + 1
  entry.last = os.time()
  schedule_save()
end

local function on_key(key, typed)
  local ok = pcall(function()
    -- The callback runs *after* mappings are applied: `typed` holds the keys
    -- the user actually pressed (the lhs), `key` holds the expansion. Only
    -- `typed` is interesting here, and it may contain several keys at once.
    local source = typed
    if type(source) ~= 'string' or source == '' then
      return
    end
    for _, tok in ipairs(tokenize(vim.fn.keytrans(source))) do
      state.tail[#state.tail + 1] = tok
    end
    while #state.tail > config.key_buffer do
      table.remove(state.tail, 1)
    end
    local bucket = state.index[state.tail[#state.tail]]
    if not bucket then
      return
    end
    local current = mode_letter(state.mode)
    for _, tip in ipairs(bucket) do
      if mode_matches(tip, current) and suffix_matches(tip.tokens) then
        record(tip)
        return
      end
    end
  end)
  if not ok then
    return nil
  end
  return nil
end

local function install_on_key()
  pcall(vim.on_key, nil, ns)
  state.tail = {}
  state.tracking = true
  local ok = pcall(vim.on_key, on_key, ns)
  if not ok then
    state.tracking = false
  end
end

local function remove_on_key()
  pcall(vim.on_key, nil, ns)
  state.tail = {}
  state.tracking = false
end

-- Startup / buffer checks ---------------------------------------------------

local function is_blank_buffer()
  if vim.fn.argc() ~= 0 then
    return false
  end
  if vim.bo.buftype ~= '' then
    return false
  end
  if vim.api.nvim_buf_get_name(0) ~= '' then
    return false
  end
  if vim.bo.filetype ~= '' then
    return false
  end
  local ok, lines = pcall(vim.api.nvim_buf_get_lines, 0, 0, 1, false)
  if not ok or type(lines) ~= 'table' then
    return false
  end
  if lines[1] ~= nil and lines[1] ~= '' then
    return false
  end
  local ok2, wintype = pcall(vim.fn.win_gettype)
  if ok2 and type(wintype) == 'string' and wintype ~= '' then
    return false
  end
  if vim.fn.getcmdwintype() ~= '' then
    return false
  end
  return true
end

-- Display -------------------------------------------------------------------

local function setup_highlights()
  vim.api.nvim_set_hl(0, 'MappingTipsBorder', { link = 'FloatBorder', default = true })
  vim.api.nvim_set_hl(0, 'MappingTipsTitle', { link = 'Title', default = true })
  vim.api.nvim_set_hl(0, 'MappingTipsKey', { link = 'Special', default = true })
  vim.api.nvim_set_hl(0, 'MappingTipsMeta', { link = 'Comment', default = true })
  vim.api.nvim_set_hl(0, 'MappingTipsHint', { link = 'Comment', default = true })
end

local function close_timer()
  if state.timer then
    pcall(vim.fn.timer_stop, state.timer)
    state.timer = nil
  end
end

local function close()
  close_timer()
  local win = state.win
  state.win = nil
  state.buf = nil
  state.current = nil
  if win and pcall(vim.api.nvim_win_is_valid, win) then
    pcall(vim.api.nvim_win_close, win, true)
  end
end

local function wrap(text, width)
  local out, current = {}, ''
  for word in text:gmatch('%S+') do
    local candidate = current == '' and word or (current .. ' ' .. word)
    if current ~= '' and display_width(candidate) > width then
      out[#out + 1] = current
      current = word
    else
      current = candidate
    end
  end
  if current ~= '' then
    out[#out + 1] = current
  end
  if #out == 0 then
    out[1] = ''
  end
  return out
end

local function pick_tip(exclude)
  local tips = state.tips
  if #tips == 0 then
    return nil
  end
  local total, weights = 0, {}
  for i, tip in ipairs(tips) do
    local skip = exclude ~= nil and #tips > 1 and tip == exclude
    if not skip then
      local weight = count_of(tip) == 0 and config.weight.unused or config.weight.used
      weights[i] = weight
      total = total + weight
    end
  end
  if total == 0 then
    for i = 1, #tips do
      if tips[i] ~= exclude then
        return tips[i]
      end
    end
    return tips[1]
  end
  local target = random_int(total)
  for i, tip in ipairs(tips) do
    local weight = weights[i] or 0
    if target <= weight then
      return tip
    end
    target = target - weight
  end
  return tips[1]
end

local function update_countdown()
  local buf = state.buf
  local row = state.countdown_row
  if not buf or not row or not pcall(vim.api.nvim_buf_is_valid, buf) then
    return
  end
  local text = ' (auto-closes in ' .. state.remaining .. 's)'
  -- The float buffer is 'nomodifiable', so toggle it just for the update.
  pcall(function()
    vim.bo[buf].modifiable = true
  end)
  pcall(vim.api.nvim_buf_set_lines, buf, row, row + 1, false, { text })
  pcall(function()
    vim.bo[buf].modifiable = false
  end)
end

local function arm_close_timer()
  local secs = duration_s()
  state.remaining = secs
  state.timer = vim.fn.timer_start(1000, function()
    state.remaining = state.remaining - 1
    if state.remaining <= 0 then
      vim.schedule(function()
        pcall(close)
      end)
      return
    end
    vim.schedule(function()
      pcall(update_countdown)
    end)
  end, { ['repeat'] = -1 })
end

local function float_lines(tip, index, total)
  local inner = config.max_width - 4
  local head = 'Tip · ' .. index .. '/' .. total
  local key_part = '(' .. (MODE_LABEL[tip.mode] or tip.mode) .. ') ' .. tip.lhs
  local first = ' ' .. head .. '   ' .. key_part

  local used = count_of(tip)
  local meta = '`' .. tip.rhs .. '`  ·  ' .. tip.file .. ':' .. tip.line
    .. '  ·  used ' .. used .. ' time' .. (used == 1 and '' or 's')

  local lines = { first }
  for _, part in ipairs(wrap(tip.desc, inner)) do
    lines[#lines + 1] = ' ' .. part
  end
  for _, part in ipairs(wrap(meta, inner)) do
    lines[#lines + 1] = ' ' .. part
  end
  lines[#lines + 1] = ''
  local hint = ':MapTip  next tip   ·  :MapTips  list   ·  :MapTips unused  prune'
  for _, part in ipairs(wrap(hint, inner)) do
    lines[#lines + 1] = ' ' .. part
  end
  state.countdown_row = #lines
  local secs = duration_s()
  lines[#lines + 1] = ' (auto-closes in ' .. secs .. 's)'

  local width = config.min_width
  for _, line in ipairs(lines) do
    width = math.max(width, display_width(line) + 2)
  end
  width = math.min(config.max_width, width)
  return lines, width, head, key_part
end

local function show(opts)
  opts = opts or {}
  if not is_enabled() then
    return false
  end
  if not opts.force and not is_blank_buffer() then
    return false
  end
  if opts.automatic and once_per_day() and state.stats.last_shown == today() then
    return false
  end

  ensure_parsed(false)
  if #state.tips == 0 then
    return false
  end

  local tip = pick_tip(state.current)
  if not tip then
    return false
  end

  close()
  pcall(setup_highlights)

  local index
  for i, item in ipairs(state.tips) do
    if item == tip then
      index = i
      break
    end
  end
  index = index or 1

  local lines, width = float_lines(tip, index, #state.tips)
  local ui = vim.api.nvim_list_uis()[1]
  local cols = ui and ui.width or vim.o.columns
  local rows = ui and ui.height or vim.o.lines
  local height = #lines
  local row = math.max(1, math.floor((rows - height) / 2) - 2)
  local col = math.max(0, math.floor((cols - width) / 2))

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = 'mapping-tips'
  vim.bo[buf].modifiable = true

  local ok, win = pcall(vim.api.nvim_open_win, buf, false, {
    relative = 'editor',
    row = row,
    col = col,
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    focusable = false,
    noautocmd = true,
    zindex = 250,
    title = ' mapping tips ',
    title_pos = 'center',
  })
  if not ok or not win then
    pcall(vim.api.nvim_buf_delete, buf, { force = true })
    return false
  end

  pcall(vim.api.nvim_buf_set_lines, buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false
  vim.wo[win].wrap = false
  vim.wo[win].winblend = 0
  vim.wo[win].cursorline = false
  vim.wo[win].winhl = table.concat({
    'Normal:NormalFloat',
    'NormalFloat:NormalFloat',
    'FloatBorder:MappingTipsBorder',
    'FloatTitle:MappingTipsTitle',
  }, ',')

  -- Title (first line) and key (lhs) highlights.
  local first = lines[1]
  local key_start = first:find('(', 1, true)
  pcall(vim.api.nvim_buf_set_extmark, buf, ns, 0, 0, {
    end_col = key_start and (key_start - 2) or #first,
    hl_group = 'MappingTipsTitle',
  })
  if key_start then
    pcall(vim.api.nvim_buf_set_extmark, buf, ns, 0, key_start - 1, {
      end_col = #first,
      hl_group = 'MappingTipsKey',
    })
  end
  for i = #lines - 3, #lines do
    if lines[i] then
      pcall(vim.api.nvim_buf_set_extmark, buf, ns, i - 1, 0, {
        end_col = #lines[i],
        hl_group = 'MappingTipsHint',
      })
    end
  end

  state.win = win
  state.buf = buf
  state.current = tip
  state.shown_at = vim.uv.now()
  state.stats.last_shown = today()
  schedule_save()
  arm_close_timer()
  return true
end

local function maybe_show_startup()
  pcall(function()
    if vim.v.vim_did_enter == 0 then
      return
    end
    show({ automatic = true })
  end)
end

-- :MapTips list -------------------------------------------------------------

local function sorted_tips(filter)
  ensure_parsed(false)
  local items = {}
  for _, tip in ipairs(state.tips) do
    local count = count_of(tip)
    if filter == 'unused' then
      if count == 0 then
        items[#items + 1] = tip
      end
    elseif filter == 'used' then
      if count > 0 then
        items[#items + 1] = tip
      end
    else
      items[#items + 1] = tip
    end
  end
  table.sort(items, function(a, b)
    local ca, cb = count_of(a), count_of(b)
    if ca ~= cb then
      return ca < cb
    end
    if a.kind ~= b.kind then
      return a.kind < b.kind
    end
    if a.lhs ~= b.lhs then
      return a.lhs < b.lhs
    end
    return a.line < b.line
  end)
  return items
end

local function list_close(buf)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      local ok = pcall(vim.api.nvim_win_close, win, true)
      if ok then
        return
      end
    end
  end
  pcall(vim.cmd, 'enew')
end

local function open_list(filter)
  local items = sorted_tips(filter)
  local counts = { unused = 0, used = 0 }
  for _, tip in ipairs(items) do
    if count_of(tip) == 0 then
      counts.unused = counts.unused + 1
    else
      counts.used = counts.used + 1
    end
  end

  local lhs_w, count_w = 6, 5
  for _, tip in ipairs(items) do
    lhs_w = math.max(lhs_w, display_width(tip.lhs))
    count_w = math.max(count_w, display_width(tostring(count_of(tip))))
  end
  lhs_w = math.min(lhs_w, 18)
  count_w = math.min(count_w, 6)

  local title = 'Mapping tips'
  if filter then
    title = title .. ' (' .. filter .. ')'
  end
  title = title .. ' — ' .. #items .. ' shown · ' .. counts.unused .. ' never used'

  local lines = {
    title,
    'q close  ·  <CR> jump to source  ·  :MapTips unused|used refresh',
    '',
  }
  local rows = {}
  local function add_row(tip)
    local count = count_of(tip)
    local mode = MODE_LABEL[tip.mode] or tip.mode
    local row = pad(mode, 3) .. ' ' .. pad(truncate(tip.lhs, lhs_w), lhs_w) .. '  '
      .. pad(tostring(count), count_w) .. '  '
      .. pad(truncate(tip.desc, 44), 44) .. ' '
      .. tip.file .. ':' .. tip.line
    lines[#lines + 1] = row
    rows[#lines] = tip
  end

  if filter == nil and counts.unused > 0 then
    lines[#lines + 1] = '── never used (' .. counts.unused .. ') ' .. string.rep('─', 40)
    for _, tip in ipairs(items) do
      if count_of(tip) == 0 then
        add_row(tip)
      end
    end
    lines[#lines + 1] = ''
  end
  if filter == nil and counts.used > 0 then
    lines[#lines + 1] = '── used (' .. counts.used .. ') ' .. string.rep('─', 45)
  end
  for _, tip in ipairs(items) do
    if filter ~= nil or count_of(tip) > 0 then
      add_row(tip)
    end
  end

  local ok = pcall(vim.cmd, 'botright new')
  if not ok then
    return false
  end
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].buftype = 'nofile'
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = 'mapping-tips-list'
  vim.bo[buf].modifiable = true
  pcall(vim.api.nvim_buf_set_lines, buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false

  state.list_rows[buf] = rows
  state.list_bufs[buf] = true

  vim.keymap.set('n', 'q', function()
    list_close(buf)
  end, { buffer = buf, nowait = true, silent = true, desc = 'Close mapping tips' })

  vim.keymap.set('n', '<CR>', function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local tip = rows[row]
    if not tip then
      return
    end
    vim.cmd('edit ' .. vim.fn.fnameescape(tip.path))
    pcall(vim.api.nvim_win_set_cursor, 0, { tip.line, 0 })
    pcall(vim.cmd, 'normal! zz')
  end, { buffer = buf, nowait = true, silent = true, desc = 'Jump to mapping source' })

  vim.keymap.set('n', '<C-c>', function()
    list_close(buf)
  end, { buffer = buf, nowait = true, silent = true })
  return true
end

-- Autocmds -----------------------------------------------------------------

local function close_on_event()
  if not state.win then
    return
  end
  if vim.uv.now() - state.shown_at < config.close_grace_ms then
    return
  end
  close()
end

local function install_autocmds()
  local group = vim.api.nvim_create_augroup('MappingTips', { clear = true })

  local function on_cmdline_leave()
    pcall(function()
      if vim.v.event.cmdtype ~= ':' or vim.v.event.abort then
        return
      end
      local line = vim.fn.getcmdline()
      if type(line) ~= 'string' or line == '' then
        return
      end
      -- Strip an optional range (:'<,'>, :% ...) before the command name.
      local head = line:gsub("^%s*[%d%.,%%%$'<>%+%-]*%s*", '')
      local name = head:match('^(%a[%w]*)')
      if not name then
        return
      end
      local tip = state.command_by_name[name]
      if tip then
        record(tip)
      end
    end)
  end

  vim.api.nvim_create_autocmd('CmdlineLeave', {
    group = group,
    callback = on_cmdline_leave,
  })

  vim.api.nvim_create_autocmd('VimEnter', {
    group = group,
    callback = function()
      vim.defer_fn(function()
        maybe_show_startup()
      end, config.startup_delay_ms)
    end,
  })

  vim.api.nvim_create_autocmd('ModeChanged', {
    group = group,
    callback = function()
      state.mode = vim.api.nvim_get_mode().mode
      state.tail = {}
    end,
  })

  local close_events = {
    'CursorMoved',
    'InsertEnter',
    'BufEnter',
    'VimResized',
    'WinScrolled',
  }
  vim.api.nvim_create_autocmd(close_events, {
    group = group,
    callback = function()
      pcall(close_on_event)
    end,
  })

  vim.api.nvim_create_autocmd('VimLeavePre', {
    group = group,
    callback = function()
      pcall(save_stats)
      pcall(close_timer)
    end,
  })
end

-- Commands ------------------------------------------------------------------

local function install_commands()
  local ok1 = pcall(vim.api.nvim_create_user_command, 'MapTip', function(args)
    pcall(function()
      if args.bang then
        show({ force = true })
      else
        show({})
      end
    end)
  end, { bang = true, desc = 'Show another mapping tip' })

  local ok2 = pcall(vim.api.nvim_create_user_command, 'MapTips', function(args)
    pcall(function()
      local sub = args.fargs[1]
      if sub == 'disable' then
        state.disabled = true
        vim.g.mapping_tips = false
        remove_on_key()
        close()
      elseif sub == 'enable' then
        state.disabled = false
        vim.g.mapping_tips = 1
        if not state.tracking then
          install_on_key()
        end
      elseif sub == 'refresh' then
        ensure_parsed(true)
        open_list(nil)
      elseif sub == 'close' then
        for buf in pairs(state.list_bufs) do
          if pcall(vim.api.nvim_buf_is_valid, buf) then
            list_close(buf)
          end
        end
      elseif sub == 'unused' or sub == 'used' then
        open_list(sub)
      elseif sub == nil then
        open_list(nil)
      end
    end)
  end, {
    nargs = '?',
    desc = 'List mapping tips',
    complete = function()
      return { 'unused', 'used', 'refresh', 'close', 'disable', 'enable' }
    end,
  })

  return ok1 and ok2
end

-- Setup ---------------------------------------------------------------------

function M.setup()
  if state.setup_done then
    return
  end
  state.setup_done = true
  vim.g.loaded_mapping_tips = 1

  state.stats = load_stats()
  state.mode = vim.api.nvim_get_mode().mode

  pcall(setup_highlights)
  pcall(install_autocmds)
  pcall(install_commands)
  if is_enabled() then
    pcall(install_on_key)
  end

  if vim.v.vim_did_enter == 1 then
    vim.defer_fn(function()
      pcall(function()
        show({ automatic = true })
      end)
    end, 50)
  end
end

M.show = function()
  return show({})
end
M.close = close
M.enabled = is_enabled
M.config = config

pcall(M.setup)

-- Allow `require('mapping-tips')` to reach the live module (tests, tinkering)
-- without polluting _G. It is only registered; nothing else changes.
pcall(function()
  package.loaded['mapping-tips'] = M
end)

return M
