# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

NPM_PACKAGES="$HOME/.npm_packages"
export PATH=$HOME/bin:$(composer global config bin-dir --absolute --quiet):/usr/local/bin:$NPM_PACKAGES/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/albo/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

export EDITOR='vim'
export DEFAULT_USER='albo'

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
alias alison="cd /mnt/backup/Apps/alison-desktop-2.0.5 && ./start-alison.sh && cd -"
alias t="nvim /home/albo/TODO.md"
alias css.br="npm run css-min > /dev/null && cp dist/*.css . && brotli -f *.css && ls -l *.css.br && echo '' && ll *.css.br && rm *.css && rm *.br"
alias css.gz="npm run css-min > /dev/null && cp dist/*.css . && gzip --best *.css && ls -l *.css.gz && echo '' && ll *.css.gz && rm *.gz"

function nube {
    
    NUBE_HOST="nube.pragmore.com"
    NUBE_USER="ec2-user"

    if [ "$2" = "git" ]; then
        NUBE_GIT_INIT=0
        NUBE_BRANCH="${3:-prod}"
        [ ! -d .git ] && NUBE_GIT_INIT=1 && git init
        git remote add "$NUBE_BRANCH" "$NUBE_USER@$NUBE_HOST:$1.git" && echo -e "Escribí \e[34mgit push $NUBE_BRANCH\e[0m para deployar\e"
        (($NUBE_GIT_INIT)) && git pull $NUBE_BRANCH
    else
        ssh -o LogLevel=QUIET -t "$NUBE_USER@$NUBE_HOST" "/var/www/$1/${@:2}"
    fi
}

