Replaces oh-my-zsh
==================

These files replace oh-my-zsh's core (`compinit`, completion styling, history
options, key bindings, directory aliases) and its `z` plugin, sourced directly
from `.zshrc` without the framework overhead around them. The `git` plugin was
already replaced earlier by two functions (`gst`, `gd`) directly in `.zshrc`.

Files
-----

* `completion.zsh` — completion styling + cached `compinit`/`bashcompinit`.
* `keybindings.zsh` — emacs mode and Ctrl-R history search.
* `directories.zsh` — vendored verbatim from oh-my-zsh's `lib/directories.zsh`
  (`l`/`ll`/`la`, `..`/`...`, `md`/`rd`, `cd -N`, `auto_cd`).
* `history.zsh` — bumps `HISTSIZE`/`SAVEHIST` and sets the history `setopt`s
  oh-my-zsh used to set.
* `misc.zsh` — a few cheap shell options, the `_='sudo '` alias, and `take()`
  (mkdir -p + cd).
* `z.zsh` — vendored from oh-my-zsh's `z` plugin (actually `agkozak/zsh-z`).

Deliberately dropped
---------------------

* Terminal title and OSC7 cwd sync (oh-my-zsh's `lib/termsupport.zsh`) — tmux
  sets the window title, and its own `-c "#{pane_current_path}"` bindings
  already open new panes in the right directory.
* Most of oh-my-zsh's `lib/key-bindings.zsh` — only emacs mode and Ctrl-R
  history search are kept.
* `fzf` plugin — Ctrl-R uses zsh's built-in incremental pattern search instead.
* `per-directory-history` plugin — history is a single global `~/.zsh_history`.
* `takeurl`/`takezip`/`takegit`, `omz_urlencode`/`omz_urldecode`,
  `open_command`, `omz_history -c` confirm-wrapper — rarely used utility
  functions from oh-my-zsh's `lib/functions.zsh`.
* The big `ignored-patterns` username-completion list and bracketed-paste/
  url-quote "magic" (`lib/misc.zsh`) — low value, and the latter loops over
  `$fpath`, which is exactly the kind of overhead this migration removes.
* `docker-compose` plugin — confirmed unused.

If you hit a missing alias/keybinding/behavior that used to come from
oh-my-zsh, it's probably in one of the dropped bits above — add it back here.
