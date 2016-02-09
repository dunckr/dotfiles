dotfiles="$HOME/dotfiles"

# private
if [ -f "$dotfiles/private/.bashrc.local" ]; then
  source "$dotfiles/private/.bashrc.local"
fi

# bash completion
if [ -f `brew --prefix`/etc/bash_completion ]; then
  . `brew --prefix`/etc/bash_completion
fi

# brew completions
if [ -f "$(brew --repository)/Library/Contributions/brew_bash_completion.sh" ]; then
  source "$(brew --repository)/Library/Contributions/brew_bash_completion.sh"
fi

# bash-git-prompt
if [ -f "$(brew --prefix bash-git-prompt)/share/gitprompt.sh" ]; then
  GIT_PROMPT_THEME=Single_line_Solarized
  source "$(brew --prefix bash-git-prompt)/share/gitprompt.sh"
fi

export EDITOR=vim

# Aliases
alias ..='cd ..'
alias cd..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias ~='cd ~'

# Git
alias gst="git status"
alias gaa="git add -A"
alias gb="git branch"
alias gd="git diff"
alias gdc="git diff --cached"
alias gcm="git commit -m"
alias gco="git checkout"
alias gl="git log"
alias gf="git fetch"
alias grc="git rebase --continue"

# Brew
alias cask='brew cask'
alias brewupdate="brew -v update; brew -v upgrade --all; brew cleanup; brew cask cleanup; brew prune; brew doctor"

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

# NeoVim
alias vim="nvim"

# Docker
alias dm="docker-machine"
alias dc="docker-compose"
alias denv='function __denv() { eval "$(dm env $@)"; unset -f __denv; }; __denv'

# GO
export GOPATH=$HOME/Go
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin
