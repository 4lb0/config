# Completion setup (replaces oh-my-zsh's lib/completion.zsh + core compinit call)

zmodload -i zsh/complist

WORDCHARS=''

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word
setopt always_to_end

bindkey -M menuselect '^o' accept-and-infer-next-history
zstyle ':completion:*:*:*:*:*' menu select

# case insensitive (all), partial-word and substring completion
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

zstyle ':completion:*' list-colors ''

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Use caching so that commands like apt and dpkg complete are usable
ZSH_CACHE_DIR="$HOME/.cache/zsh"
mkdir -p "$ZSH_CACHE_DIR"
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"

# compinit, cached: only run the full (slower) security audit once a day
autoload -Uz compinit
_zcompdump="$ZSH_CACHE_DIR/zcompdump"
if [[ -n ${_zcompdump}(#qN.mh+24) ]]; then
  compinit -d "$_zcompdump"
else
  compinit -C -d "$_zcompdump"
fi
unset _zcompdump

# automatically load bash completion functions (needed for nvm's bash_completion)
autoload -U +X bashcompinit && bashcompinit
