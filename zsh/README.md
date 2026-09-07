Replaces oh-my-zsh
==================

These files replace oh-my-zsh's core (`compinit`, completion styling, history
options, key bindings, directory aliases, terminal title) and its `z` /
`per-directory-history` plugins, sourced directly from `.zshrc` without the
framework overhead around them. The `git` plugin was already replaced earlier
by two functions (`gst`, `gd`) directly in `.zshrc`; the `fzf` plugin is now
just `eval "$(fzf --zsh)"`, also in `.zshrc`.

Files
-----

* `completion.zsh` — completion styling + cached `compinit`/`bashcompinit`.
* `keybindings.zsh` — vendored verbatim from oh-my-zsh's `lib/key-bindings.zsh`.
* `directories.zsh` — vendored verbatim from oh-my-zsh's `lib/directories.zsh`
  (`l`/`ll`/`la`, `..`/`...`, `md`/`rd`, `cd -N`, `auto_cd`).
* `history.zsh` — bumps `HISTSIZE`/`SAVEHIST` and sets the history `setopt`s
  oh-my-zsh used to set.
* `misc.zsh` — a few cheap shell options, the `_='sudo '` alias, and `take()`
  (mkdir -p + cd).
* `termsupport.zsh` — auto-updates the terminal tab/window title.
* `z.zsh` — vendored from oh-my-zsh's `z` plugin (actually `agkozak/zsh-z`).
* `per-directory-history.zsh` — vendored from oh-my-zsh's plugin of the same
  name (Ctrl-G toggles per-directory vs. global history).

Deliberately dropped
---------------------

* OSC7 cwd sync (termsupport.zsh's `omz_termsupport_cwd`) — tmux's own
  `-c "#{pane_current_path}"` bindings already open new panes in the right
  directory, so this wasn't needed.
* `takeurl`/`takezip`/`takegit`, `omz_urlencode`/`omz_urldecode`,
  `open_command`, `omz_history -c` confirm-wrapper — rarely used utility
  functions from oh-my-zsh's `lib/functions.zsh`.
* The big `ignored-patterns` username-completion list and bracketed-paste/
  url-quote "magic" (`lib/misc.zsh`) — low value, and the latter loops over
  `$fpath`, which is exactly the kind of overhead this migration removes.
* `docker-compose` plugin — confirmed unused.

If you hit a missing alias/keybinding/behavior that used to come from
oh-my-zsh, it's probably in one of the dropped bits above — add it back here.
