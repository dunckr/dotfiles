dotfiles="$HOME/dotfiles"

# Locals
if [ -f "$HOME/.bashrc.local" ]; then
  source "$HOME/.bashrc.local"
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

# nvm
export NVM_DIR="$HOME/.nvm"
  . "/usr/local/opt/nvm/nvm.sh"

# rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# python
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

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
alias cp="cp -v"
alias mv="mv -v"
alias ls="ls -FGh"
alias du="du -cksh"
alias df="df -h"
# Use modern regexps for sed, i.e. "(one|two)", not "\(one\|two\)"
alias sed="sed -E"
# Just print request/response headers
alias curl="curl --verbose"
# Use modern regexps for grep, and do show color when `grep` is the final
# command, but don't when piping to something else, because the added color
# codes will mess up the expected input.
alias grep="egrep --color=auto"
alias mkdir="\mkdir -p"

# IP
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# System
alias battery="pmset -g batt"

# Git
alias g="git"
__git_complete g _git
alias gb="git branch "
__git_complete gb _git_branch
alias gco="git checkout "
__git_complete gco _git_checkout

alias gaa="git add -v -A"
alias gc="git commit -v"
alias gcm="git commit -v -m 'WIP'"
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
alias macupdate='softwareupdate -i -a;'
alias update='brew -v update; brew -v upgrade; brew cleanup; brew cask cleanup; brew prune; npm install npm -g; npm update -g; pip3update; gem update --system -y; gem update -y; vim +PlugUpdate +PlugUpgrade +UpdateRemotePlugins +qall;'

# Hub
eval "$(hub alias -s)"

# Applications
alias subl="/usr/local/bin/subl"
alias sketch="/Applications/Sketch.app/Contents/MacOS/Sketch"
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"

# Shorthands
alias cls="clear"

# Vagrant
alias vu="vagrant up && vagrant ssh"
alias vk="vagrant halt -f"

# Neovim
alias vim="nvim"

# tmux
alias mux="tmuxinator"

# Docker
alias dm="docker-machine"
alias dc="docker-compose"
alias denv='function __denv() { eval "$(dm env $@)"; unset -f __denv; }; __denv'
alias dopen='function __dopen() { eval "$(open http://`docker-machine ip $@`)"; unset -f __dopen; }; __dopen'
alias dclean='docker rmi $(docker images --filter dangling=true)'
alias dkill='docker rmi $(docker images -a -q)'
alias dprune='docker image prune -a -f && docker container prune -f && docker volume prune -f'

# Ruby
alias be="bundle exec"
alias critic="rubycritic -f console && sandi_meter -d || true && rails_best_practices"

# GO
export GOPATH=$HOME/go
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$GOROOT/bin

alias killforce='function __killforce() { eval "pgrep $@ | xargs kill -9"; unset -f __killforce; }; __killforce'
alias largest='function _largest() { find . -name "*.$@" | xargs wc -l | sort -nr -k5 | head -n 25; unset -f _largest; }; _largest'
