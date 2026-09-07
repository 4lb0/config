# Misc settings and helpers (replaces oh-my-zsh's lib/misc.zsh + functions.zsh's take())

setopt multios              # enable redirect to multiple streams: echo >file1 >file2
setopt long_list_jobs       # show long list format job notifications
setopt interactivecomments  # recognize comments

# default pager
if (( ${+commands[less]} )); then
  : ${PAGER:=less}
  : ${LESS:=-R}
  export PAGER LESS
fi

## super user alias
alias _='sudo '

# mkdir -p + cd in one shot
function take() {
  mkdir -p "$@" && cd "${@:$#}"
}
