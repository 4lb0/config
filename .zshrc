# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.

ZSH_THEME="skaro"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="dd/mm/yyyy"

# Plugins
# Added autojump http://fendrich.se/blog/2012/09/28/no/
plugins=(git autojump)

source $ZSH/oh-my-zsh.sh

# User configuration

export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"

# Load aliases
source ~/.bash_aliases

# Enable full colors support
# http://vim.wikia.com/wiki/256_colors_in_vim
export TERM=xterm-256color

# Frequently used paths
# http://robots.thoughtbot.com/cding-to-frequently-used-directories-in-zsh
setopt auto_cd

# Turn on # comments
setopt interactivecomments

# Terminal is preventing Control+s
# http://stackoverflow.com/questions/8616843/ctrl-s-is-not-working-as-a-horizontal-split-in-vim-when-using-commandt
stty -ixon -ixoff

# Add Syntax Highlighting
# http://jilles.me/badassify-your-terminal-and-shell/
source ~/.oh-my-zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh  

# Add Z - Jump around
# http://jilles.me/badassify-your-terminal-and-shell/
. ~/.zsh/z/z.sh

export PATH="$PATH:$HOME/.composer/vendor/bin" # Add Composer path
