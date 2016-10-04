dotfiles="$HOME/dotfiles"

# private
if [ -f "$dotfiles/secret/.bashrc.local" ]; then
  source "$dotfiles/secret/.bashrc.local"
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

# google cloud completion
source '/opt/homebrew-cask/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.bash.inc'
source '/opt/homebrew-cask/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.bash.inc'

export EDITOR=vim

# Aliases
alias ..='cd ..'
alias cd..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias ~='cd ~'

alias ls='ls -FG'

# IP
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# System
alias battery="pmset -g batt"

# Git
alias gaa="git add -v -A"
alias gb="git branch"
alias gcm="git commit -v -am"
alias gco="git checkout"
alias gd="git diff-index --quiet HEAD -- || clear; git --no-pager diff --patch-with-stat"
alias gdf="git diff --color --color-words --abbrev"
alias gf="git fetch"
alias gl="git log"
alias glog="git log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --"
alias gp="git push"
alias grc="git rebase --continue"
alias gsclone="git clone --depth=1"
alias gst="git status"
alias gup="git pull"
alias glast="git log -1 --pretty=%B | tr -d '\n' | pbcopy"

# Pip
alias pip3update='pip3 list -o | cut -f 1 -d " " | xargs -n 1 pip3 install --upgrade'

# Brew
alias cask='brew cask'
alias update='softwareupdate -i -a; brew -v update; brew -v upgrade --all; brew cleanup; brew cask cleanup; brew prune; npm install npm -g; npm update -g; gem update --system; gem update; pip3update;'

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
alias dopen='function __dopen() { eval "$(open http://`docker-machine ip $@`)"; unset -f __dopen; }; __dopen'
alias dclean='docker rmi $(docker images --filter dangling=true)'
alias dkill='docker rmi $(docker images -a -q)'
