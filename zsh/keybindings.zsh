# Key bindings

# Emacs mode (otherwise zsh picks vi mode because EDITOR contains "vi")
bindkey -e

# [Ctrl-R] - search history backward. Supports patterns like 'git*push'.
bindkey '^R' history-incremental-pattern-search-backward
