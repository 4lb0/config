let mapleader = ","

set termguicolors

call plug#begin('~/.vim/plugged')

" Visual plugins
Plug 'itchyny/lightline.vim'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'dracula/vim', { 'as': 'dracula' }

" IDE
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'editorconfig/editorconfig-vim'

" Type related
Plug 'leafgarland/typescript-vim', { 'for': ['typescript', 'typescriptreact'] }
Plug 'maxmellon/vim-jsx-pretty'
Plug 'cespare/vim-toml', { 'for': 'toml', 'branch': 'main' }
Plug 'bialet/bialet.vim', { 'for': 'wren' }

" Initialize plugin system
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

colorscheme dracula

" Lightline
set showtabline=2
set noshowmode

function! CocCurrentFunction()
  return get(b:, 'coc_current_function', '')
endfunction

let g:lightline#bufferline#unnamed = '[No Name]'

let g:lightline = {
      \   'colorscheme': 'darcula',
      \   'active': {
      \    'left': [ [ 'mode', 'paste' ], ['readonly', 'filename', 'modified' ], [ 'cocstatus', 'currentfunction' ] ]
      \   },
      \   'tabline': {
      \    'left': [ ['buffers'] ],
      \    'right': [ ['close'] ]
      \   },
      \   'component_function': {
      \    'cocstatus': 'coc#status',
      \    'currentfunction': 'CocCurrentFunction'
      \   },
      \   'component_expand': {
      \    'buffers': 'lightline#bufferline#buffers'
      \   },
      \   'component_type': {
      \     'buffers': 'tabsel'
      \   }
      \ }

syntax enable

" CoC
set cmdheight=2 " taller command line: coc lists/messages rarely need a keypress to scroll
set updatetime=300 " idle ms before CursorHold: drives coc reference highlight and signature help
set shortmess+=IcF " I: no intro screen · c: no completion matches echo · F: no file info line
set signcolumn=number " draw coc diagnostic signs inside the number column, no extra gutter
set pumheight=12 " cap the completion popup height so it can't cover half the screen

" Use tab for trigger completion with characters ahead and navigate.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1):
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
" Cycle backwards through the completion menu, or <C-h> when it's closed
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
      \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')
" Symbol renaming
nmap <F2> <Plug>(coc-rename)
" Add `:Format` command to format the current buffer with coc (skips quietly
" when the filetype has no format provider, e.g. vim files)
command! -nargs=0 Format :call <SID>Format()
function! s:Format() abort
  if !get(g:, 'coc_service_initialized', 0)
    echom 'coc.nvim is still starting, try :Format again in a second'
    return
  endif
  try
    let l:has_provider = CocHasProvider('format')
  catch
    echom 'coc.nvim is not ready, try :Format again in a second'
    return
  endtry
  if l:has_provider
    call CocActionAsync('format')
  else
    echom 'No coc formatter for filetype "' . &filetype . '" (configure one in coc-settings.json)'
  endif
endfunction

" Mappings for CoCList

" Show all diagnostics
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Show commands
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => IDE configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Neovim is utf-8 internally, no 'set encoding' needed.
" Only force zsh when it exists: a hard-coded shell breaks on machines without it.
if executable('zsh')
  set shell=/bin/zsh
endif
set number relativenumber " show hybrid numbers line
set showmatch " highlight matching [{()}]
set lazyredraw " Speed up the macro, lazy redraw http://www.matthewoakley.co.uk/how-to-speed-up-your-macros-in-vim/
let php_htmlInStrings = 1
set title " Improve terminal title
set list listchars=tab:»·,nbsp:␣,trail:•,extends:⟩,precedes:⟨ " make tabs, nbsp and overflowing text visible
set clipboard=unnamedplus " share clipboard with OS
set mouse=a " Enable mouse usage (all modes)
set splitright " :vsplit opens the new window on the right
set splitbelow " :split opens the new window below
set scrolloff=8 " keep 8 lines of context above/below the cursor
set sidescrolloff=8 " same as scrolloff, for horizontal scrolling
set backspace=indent,eol,start " backspace may delete indent, the line break and pre-insert text
set timeoutlen=400 " ms to wait for a mapping/leader sequence to complete before splitting the keys

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Search
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set ignorecase " Ignore case when searching
set smartcase " When searching try to be smart about cases
set hlsearch " Highlight search results
set incsearch " Makes search act like search in modern browsers
set inccommand=nosplit " live preview of :s/…/…/ while typing, without a preview split

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" set the files we don't want to search
set wildignore=*.o,*~,*.pyc,*cache/*,*log/*,.git/*,.svn/*,*/vendor/*,*/node_modules/*,*.png,*.jpg,*.gif,*.pdf,*.DS_Store,._*
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set noswapfile
set hidden " keep buffers loaded: use buffers as tabs, switch without saving first
set confirm " ask instead of failing with E37/E89 on unsaved changes
set wildmenu  " visual autocomplete for command menu

" Filetypes and per-filetype options. Grouped so re-sourcing init.vim replaces
" these rules instead of stacking duplicates (autocmd! clears the group first).
augroup user_filetypes
  autocmd!
  " .tsx must become typescriptreact, otherwise JSX is lost
  autocmd BufNewFile,BufRead *.ts  setlocal filetype=typescript
  autocmd BufNewFile,BufRead *.tsx setlocal filetype=typescriptreact
  autocmd BufNewFile,BufRead *.php,*.java,*.c setlocal shiftwidth=4 tabstop=4
  autocmd BufNewFile,BufRead *.h setlocal filetype=c
  autocmd BufNewFile,BufRead *.asm setlocal filetype=nasm
  autocmd BufNewFile,BufRead *.csv setlocal filetype=csv
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set expandtab
set smarttab
set shiftwidth=2
set tabstop=2
set lbr
set tw=500
set autoindent
set smartindent
set wrap
set nofoldenable

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Custom mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Toggle paste mode: paste raw text without autoindent/abbrev surprises
nnoremap <silent> <F3> :set paste!<cr>
" Same, but keeps you in insert mode
inoremap <silent> <F3> <esc>:set paste!<cr>i
" Toggle relative numbers line
nnoremap <silent> m :set relativenumber!<CR>
" C projects: run make (uses the default 'makeprg', needs a Makefile)
nnoremap <silent> <leader>c :make<CR>
" Git status of the repository
nnoremap gs :Git status<CR>
" Git blame for the current file
nnoremap gb :Git blame<CR>

function! s:GitSyncEvent(job_id, data, event)
  if a:event == 'stdout'
    echom '🔄 git sync'
  elseif a:event == 'stderr'
    echom '🚨 git sync error : ' . join(a:data)
  elseif a:event == 'exit'
    if a:data == 0
      echom '✅ git sync ok'
    else
      echom '⚠️ git sync failed'
    endif
  endif
endfunction

function! GitSync()
  let s:callbacks = {
      \ 'on_stdout': function('s:GitSyncEvent'),
      \ 'on_stderr': function('s:GitSyncEvent'),
      \ 'on_exit': function('s:GitSyncEvent')
      \ }
  let s:my_job = jobstart(['sh', '-c', 'git add . && git commit -m "wip" && git pull --rebase && git push'], s:callbacks)
endfunction

" Sync: git add . + commit "wip" + pull --rebase + push, in the background
nnoremap <leader>s :call GitSync()<CR>
" Fuzzy-find files in the project
nnoremap <silent> <leader>f :Files<CR>
" Fuzzy-find lines in the current buffer
nnoremap <silent> <leader>l :Lines<CR>
" Grep the word under the cursor (fzf's Ag)
nnoremap <silent> <leader>a :Ag! <C-R><C-W><CR>
" Buffers (used as tabs)
" <leader>n = new empty "tab" in the current window (no split)
nnoremap <silent> <leader>n :enew<CR>
" Next buffer
nnoremap <silent> <tab> :bnext<CR>
" Previous buffer
nnoremap <silent> <s-tab> :bprevious<CR>
" q = close buffer (asks to discard unsaved changes), <leader>q = close without asking
nnoremap <silent> q :call <SID>CloseBuffer(0)<CR>
nnoremap <silent> <leader>q :call <SID>CloseBuffer(1)<CR>

function! s:CloseBuffer(force) abort
  let l:buf = bufnr('%')
  if getbufinfo(l:buf)[0].changed && !a:force
    let l:name = empty(bufname(l:buf)) ? '[No Name]' : bufname(l:buf)
    if confirm('Discard changes in ' . l:name . '?', "&Discard\n&Cancel", 2) != 1
      return
    endif
  endif
  if len(getbufinfo({'buflisted': 1})) > 1
    bprevious
  endif
  " bang: changes were already confirmed discarded (or -force), don't ask again
  execute 'bdelete!' l:buf
endfunction

nnoremap <leader><leader> <Cmd>CocCommand<CR>

" C-Space in normal mode: the same agent session picker tmux opens elsewhere.
" tmux hands C-Space back to Vim/Neovim, and insert mode keeps coc#refresh.
nnoremap <silent> <C-Space> :call <SID>OpenAgentPicker()<CR>

function! s:OpenAgentPicker() abort
  if empty($TMUX) || !executable('tmux')
    echom 'The agent picker needs tmux'
    return
  endif
  " jobstart so the editor is not blocked while the popup is open
  try
    call jobstart(['tmux', 'display-popup', '-E', '-b', 'rounded',
          \ '-w', '90%', '-h', '60%', '-T', 'agents',
          \ expand('~/bin/sessions-ls')])
  catch
    echom 'Could not open the agent picker: ' . v:exception
  endtry
endfunction
