export NPM_PACKAGES="$HOME/.npm_packages"
export RUBY_LOCAL="$HOME/.gem/ruby/2.7.0/bin"

export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$NPM_PACKAGES/bin:$RUBY_LOCAL:$PATH

# Zsh config (replaces oh-my-zsh, see zsh/README.md)
for f in completion keybindings directories history misc termsupport z per-directory-history; do
  source "$HOME/config/zsh/$f.zsh"
done

# NVM setup
export NVM_DIR="$HOME/.nvm"
if command -v brew >/dev/null 2>&1; then
  [ -s "$(brew --prefix nvm)/nvm.sh" ] && \. "$(brew --prefix nvm)/nvm.sh" --no-use
  [ -s "$(brew --prefix nvm)/bash_completion" ] && \. "$(brew --prefix nvm)/bash_completion"  # This loads nvm bash_completion
elif [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh" --no-use
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

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

# fzf shell integration: Ctrl-R history, Ctrl-T file finder, Alt-C cd (replaces oh-my-zsh's fzf plugin)
eval "$(fzf --zsh)"
if [[ -z "$FZF_DEFAULT_COMMAND" ]]; then
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
  elif (( $+commands[rg] )); then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git/*"'
  elif (( $+commands[ag] )); then
    export FZF_DEFAULT_COMMAND='ag -l --hidden -g "" --ignore .git'
  fi
fi

# Disable docker-compose suggestion https://github.com/docker/scan-cli-plugin/issues/149
export DOCKER_SCAN_SUGGEST=false

# Improve default
alias ag="ag --ignore \"*.bundle\" --ignore \"*.sql\" -i --color"
alias less="less -r"
alias df="df -h"
# This alias is to prevent to keep opening GhostScript
alias gs="git status"

# Git shortcuts (replacement for oh-my-zsh's git plugin, only these two are used)
function gst { git status "$@" }
function gd { git diff "$@" }

# Aliases
alias upd='nvim +PlugUpdate +qall & (npm install npm@latest -g && npm update -g) & if [[ "$(uname)" == "Darwin" ]]; then brew update && brew upgrade && brew autoremove && brew cleanup; else sudo snap refresh & sudo sh -c "apt update && apt dist-upgrade -y && apt autoremove -y"; fi'
alias css.br="npm run css-min > /dev/null && cp dist/*.css . && brotli -f *.css && ls -l *.css.br && echo '' && ll *.css.br && rm *.css && rm *.br"
alias css.gz="npm run css-min > /dev/null && cp dist/*.css . && gzip --best *.css && ls -l *.css.gz && echo '' && ll *.css.gz && rm *.gz"
alias rr="git add . && git commit -m '#wip testing in remote' && git push"

# Opens default editor with the files or with the changed git files if able.
function e {
  if [ $# -lt 1 ]; then
    if test -d .git; then
      if test -f .gitignore; then
        git ls-files -zmo --exclude-from=.gitignore | tr '\0' '\n' > /tmp/e_git_files
      else
        git ls-files -zmo | tr '\0' '\n' > /tmp/e_git_files
      fi
      xargs file -i < /tmp/e_git_files | grep -v binary | awk -F ':' '{print $1}' > /tmp/e_files_to_edit
      grep -vE '\.claude\.DS_Store'  /tmp/e_files_to_edit > /tmp/e_files_to_edit_filtered
      if [ -s /tmp/e_files_to_edit_filtered ]; then
        # Remove .claude files, cap at 10 to avoid opening too many buffers
        head -n 10 /tmp/e_files_to_edit_filtered | xargs $EDITOR
        return
      fi
    fi
  fi
  $EDITOR "$@"
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

# Start the project
function start() {
  if [[ -f "main.py" ]]; then
    fastapi dev main.py
  elif [[ -f "pnpm-lock.yaml" ]]; then
    pnpm dev
  else
    bialet
  fi
}

# Use / command generator using Ollama
function '/'() {
  local prompt="$*"
  local system_prompt="You are a command-line assistant. Given a user request in natural language, respond with ONLY the exact shell command to accomplish it. No explanations, no markdown, no code blocks, just the raw command."
  local response=$(ollama run qwen2.5-coder:1.5b "${system_prompt}

User request: ${prompt}

Command:")
  # Remove any markdown code blocks if present
  response=$(echo "$response" | sed 's/```bash//g; s/```sh//g; s/```//g' | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  # Push to zsh buffer (appears on command line ready to execute)
  print -z "$response"
}

SF_AC_ZSH_SETUP_PATH=/home/albo/.cache/sf/autocomplete/zsh_setup && test -f $SF_AC_ZSH_SETUP_PATH && source $SF_AC_ZSH_SETUP_PATH; # sf autocomplete setup

# Prevent homograph attacks https://github.com/sheeki03/tirith
command -v tirith >/dev/null && eval "$(tirith init)"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# Scripts de desarrollo Pausa
[ -d "/Users/albo/work/pausa/dev-utils/bin" ] && export PATH="$PATH:/Users/albo/work/pausa/dev-utils/bin"

# Starship prompt (replaces oh-my-zsh's agnoster theme, no per-prompt git subprocess spam)
eval "$(starship init zsh)"
