export NPM_PACKAGES="$HOME/.npm_packages"
export RUBY_LOCAL="$HOME/.gem/ruby/2.7.0/bin"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export YARN_BIN="$HOME/.yarn/bin"
export YARN_MODULES_BIN="$HOME/.config/yarn/global/node_modules/.bin"
export JAVA_HOME=$(update-alternatives --query java | grep Value | awk 'match($2, /\/usr\/lib\/jvm\/[^\/]+\//) {print substr($2, RSTART, RLENGTH)}')
export SALESFORCE_BIN="$HOME/apps/sfdx/bin"

export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$NPM_PACKAGES/bin:$RUBY_LOCAL:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$YARN_BIN:$YARN_MODULES_BIN:$JAVA_HOME:$SALESFORCE_BIN:$PATH

if type "composer" > /dev/null; then
  export PATH=$(composer global config bin-dir --absolute --quiet):$PATH
fi

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# NVM setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Uncomment the following line to automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"


# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

plugins=(git fzf z docker-compose per-directory-history)

source $ZSH/oh-my-zsh.sh

# User configuration

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

export DEFAULT_USER='albo'

if [ "$TERM" = "linux" ]; then
	printf %b '\e[40m' '\e[8]' # set default background to color 0 'dracula-bg'
	printf %b '\e[37m' '\e[8]' # set default foreground to color 7 'dracula-fg'
	printf %b '\e]P0282a36'    # redefine 'black'          as 'dracula-bg'
	printf %b '\e]P86272a4'    # redefine 'bright-black'   as 'dracula-comment'
	printf %b '\e]P1ff5555'    # redefine 'red'            as 'dracula-red'
	printf %b '\e]P9ff7777'    # redefine 'bright-red'     as '#ff7777'
	printf %b '\e]P250fa7b'    # redefine 'green'          as 'dracula-green'
	printf %b '\e]PA70fa9b'    # redefine 'bright-green'   as '#70fa9b'
	printf %b '\e]P3f1fa8c'    # redefine 'brown'          as 'dracula-yellow'
	printf %b '\e]PBffb86c'    # redefine 'bright-brown'   as 'dracula-orange'
	printf %b '\e]P4bd93f9'    # redefine 'blue'           as 'dracula-purple'
	printf %b '\e]PCcfa9ff'    # redefine 'bright-blue'    as '#cfa9ff'
	printf %b '\e]P5ff79c6'    # redefine 'magenta'        as 'dracula-pink'
	printf %b '\e]PDff88e8'    # redefine 'bright-magenta' as '#ff88e8'
	printf %b '\e]P68be9fd'    # redefine 'cyan'           as 'dracula-cyan'
	printf %b '\e]PE97e2ff'    # redefine 'bright-cyan'    as '#97e2ff'
	printf %b '\e]P7f8f8f2'    # redefine 'white'          as 'dracula-fg'
	printf %b '\e]PFffffff'    # redefine 'bright-white'   as '#ffffff'
	clear
fi
# FZF Dracula Theme
export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4'

# Disable docker-compose suggestion https://github.com/docker/scan-cli-plugin/issues/149
export DOCKER_SCAN_SUGGEST=false

# Improve default
alias ag="ag --ignore \"*.bundle\" --ignore \"*.sql\" -i --color"
alias less="less -r"
alias df="df -h"

# Aliases
alias upd="sudo apt update && sudo apt dist-upgrade -y && sudo apt autoremove -y && sudo snap refresh && omz update"
alias css.br="npm run css-min > /dev/null && cp dist/*.css . && brotli -f *.css && ls -l *.css.br && echo '' && ll *.css.br && rm *.css && rm *.br"
alias css.gz="npm run css-min > /dev/null && cp dist/*.css . && gzip --best *.css && ls -l *.css.gz && echo '' && ll *.css.gz && rm *.gz"

# Opens default editor with the files or with the changed git files if able.
function e
{
  if [ $# -lt 1 ]; then
    test -d .git && \
      (test -f .gitignore \
        && git ls-files -zmo --exclude-from=.gitignore \
        || git ls-files -zmo) \
      | xargs -0 file -i | grep -v binary \
      | awk  -F ':' 'BEGIN{ORS="\0"} {print $1}' | xargs -0 $EDITOR \
      || $EDITOR
  else
    $EDITOR ${*}
  fi
}

# Alias to add and commit, no need to put quotes for the message
function c
{
  git add .
  git commit -m "${*}"
}

function visit
{
  curl -kLs $1 | highlight --syntax html -O xterm256 | less
}

# Set a task in the One Thing extension
function task
{
  gsettings --schemadir ~/.local/share/gnome-shell/extensions/one-thing@github.com/schemas \
    set org.gnome.shell.extensions.one-thing thing-value "'${*}'"
}

# sfdx autocomplete setup
eval SFDX_AC_ZSH_SETUP_PATH=/home/albo/.cache/sfdx/autocomplete/zsh_setup \
  && test -f $SFDX_AC_ZSH_SETUP_PATH && source $SFDX_AC_ZSH_SETUP_PATH
