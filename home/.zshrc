dotfiles="$HOME/dotfiles"

[ -s "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"

# brew
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi

# nvm
 export NVM_DIR="$HOME/.nvm"

[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && . "/usr/local/opt/nvm/etc/bash_completion.d/nvm"

autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc

# rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

export EDITOR=vim

# aliases
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

# system
alias battery="pmset -g batt"

# git
alias g="git"
alias gb="git branch "
alias gco="git checkout "
alias gaa="git add -v -A"
alias gc="git commit -v"
alias gcm="git commit -v -m 'WIP' --no-verify"
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

# pip
alias pip3update='pip3 list -o | cut -f 1 -d " " | xargs -n 1 pip3 install --upgrade'

# brew
alias cask='brew cask'
alias macupdate='softwareupdate -i -a;'
alias update='brew -v update; brew -v upgrade; brew cleanup; brew cask cleanup; brew prune; npm install npm -g; npm update -g; pip3update; gem update --system -f; gem update -f; vim +PlugUpdate +PlugUpgrade +UpdateRemotePlugins +qall;'

# applications
alias subl="/usr/local/bin/subl"
alias sketch="/Applications/Sketch.app/Contents/MacOS/Sketch"
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
alias idea='function __idea() { eval "$(open -na 'IntelliJ IDEA.app' --args '$@')"; unset -f __idea; }; __idea'

# shorthands
alias cls="clear"

# vagrant
alias vu="vagrant up && vagrant ssh"
alias vk="vagrant halt -f"

# neovim
alias vim="nvim"

# tmux
alias mux="tmuxinator"

# docker
alias dm="docker-machine"
alias dc="docker-compose"
alias dcr="docker-compose run --rm"
alias denv='function __denv() { eval "$(dm env $@)"; unset -f __denv; }; __denv'
alias dopen='function __dopen() { eval "$(open http://`docker-machine ip $@`)"; unset -f __dopen; }; __dopen'
alias dclean='docker rmi $(docker images --filter dangling=true)'
alias dkill='docker rmi $(docker images -a -q)'
alias dprune='docker image prune -a -f && docker container prune -f && docker volume prune -f'
alias dca='function __dca() { docker attach --sig-proxy=false --detach-keys=ctrl-c $(docker-compose ps -q "$1"); unset -f __dca; }; __dca'

# ruby
alias be="bundle exec"
alias critic="rubycritic -f console && sandi_meter -d || true && rails_best_practices"

# python
export PATH="/usr/local/opt/python/libexec/bin:$PATH"

# go
export PATH=$PATH:/usr/local/opt/go/libexec

# commands
alias killall='pkill -f Python node bash nvim ruby'
alias largest='function _largest() { find . -name "*.$@" | xargs wc -l | sort -nr -k5 | head -n 25; unset -f _largest; }; _largest'

# starship
eval "$(starship init zsh)"

