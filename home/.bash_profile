# bash-git-prompt setup
if [ -f "$(brew --prefix bash-git-prompt)/share/gitprompt.sh" ]; then
  GIT_PROMPT_THEME=Default
  source "$(brew --prefix bash-git-prompt)/share/gitprompt.sh"
fi

# bash-git-prompt theme
GIT_PROMPT_THEME=Single_line_Solarized

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
#eval "$(hub alias -s)"

# Applications
alias subl="/opt/homebrew-cask/Caskroom/sublime-text/2.0.2/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl"
alias sketch="/Applications/Sketch.app/Contents/MacOS/Sketch"

# Shorthands
alias cls="clear"
alias server="python -m SimpleHTTPServer"

# Vagrant
alias vu="vagrant up && vagrant ssh"
alias vk="vagrant halt -f"
