# Defines environment variables.

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ "$SHLVL" -eq 1 && ! -o LOGIN && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# Add private env
if [ -f "${ZDOTDIR:-$HOME}/.zshenv.local" ]; then
    source "${ZDOTDIR:-$HOME}/.zshenv.local"
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

# Hub
eval "$(hub alias -s)"

# Applications
alias subl="/opt/homebrew-cask/Caskroom/sublime-text/2.0.2/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl"
alias sketch="/Applications/Sketch.app/Contents/MacOS/Sketch"

# Shorthands
alias cls="clear"
alias server="python -m SimpleHTTPServer"

# Vagrant
alias vu="vagrant up && vagrant ssh"
alias vk="vagrant halt -f"
