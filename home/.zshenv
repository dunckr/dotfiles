# Defines environment variables.

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# Git short-cuts
alias gst="git status"
alias gaa="git add -A"
alias gb="git branch"
alias gd="git diff"
alias gdc="git diff --cached"
alias gcm="git commit -a"
alias gco="git commit -m"
alias gl="git log"
alias gf="git fetch"
alias grc="git rebase --continue"


alias subl="/Applications/Subl.app/Contents/SharedSupport/bin/subl"
alias cls="clear"
