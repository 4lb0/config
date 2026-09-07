# Auto-update terminal tab/window title (replaces oh-my-zsh's lib/termsupport.zsh, minus OSC7
# cwd sync - tmux's own "-c #{pane_current_path}" bindings already cover that here).

function title {
  setopt localoptions nopromptsubst
  [[ -n "${INSIDE_EMACS:-}" && "$INSIDE_EMACS" != vterm ]] && return
  : ${2=$1}

  case "$TERM" in
    cygwin|xterm*|putty*|rxvt*|konsole*|ansi|mlterm*|alacritty*|st*|foot*|contour*|wezterm*)
      print -Pn "\e]2;${2:q}\a"
      print -Pn "\e]1;${1:q}\a"
      ;;
    screen*|tmux*)
      print -Pn "\ek${1:q}\e\\"
      ;;
    *)
      if [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
        print -Pn "\e]2;${2:q}\a"
        print -Pn "\e]1;${1:q}\a"
      elif (( ${+terminfo[fsl]} && ${+terminfo[tsl]} )); then
        print -Pn "${terminfo[tsl]}$1${terminfo[fsl]}"
      fi
      ;;
  esac
}

ZSH_THEME_TERM_TAB_TITLE_IDLE="%15<..<%~%<<"
ZSH_THEME_TERM_TITLE_IDLE="%n@%m:%~"
[[ "$TERM_PROGRAM" == Apple_Terminal ]] && ZSH_THEME_TERM_TITLE_IDLE="%n@%m"

function omz_termsupport_precmd {
  [[ "${DISABLE_AUTO_TITLE:-}" != true ]] || return 0
  title "$ZSH_THEME_TERM_TAB_TITLE_IDLE" "$ZSH_THEME_TERM_TITLE_IDLE"
}

function omz_termsupport_preexec {
  [[ "${DISABLE_AUTO_TITLE:-}" != true ]] || return 0
  emulate -L zsh
  local CMD="${1[(wr)^(*=*|sudo|ssh|mosh|rake|-*)]:gs/%/%%}"
  local LINE="${2:gs/%/%%}"
  title "$CMD" "%100>...>${LINE}%<<"
}

autoload -Uz add-zsh-hook
if [[ -z "$INSIDE_EMACS" || "$INSIDE_EMACS" = vterm ]]; then
  add-zsh-hook precmd omz_termsupport_precmd
  add-zsh-hook preexec omz_termsupport_preexec
fi
