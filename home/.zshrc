dotfiles="$HOME/dotfiles"

[ -s "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"

# brew
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH

  autoload -Uz compinit
  compinit
fi

# nodenv
if which nodenv > /dev/null; then eval "$(nodenv init -)"; fi

# rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

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
alias diskspace_report="df -P -kHl"

# git
alias g="git"
alias gb="git branch "
alias gbc="git branch --show-current && echo 'copied!' && git branch --show-current | pbcopy"
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
alias glast="echo 'copied!' && git log -1 --pretty=%B | tr -d '\n' | pbcopy"
alias gprune='git checkout -q master && git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch; do mergeBase=$(git merge-base master $branch) && [[ $(git cherry master $(git commit-tree $(git rev-parse $branch^{tree}) -p $mergeBase -m _)) == "-"* ]] && echo "$branch is merged into master and can be deleted"; done'
alias gprunef='git checkout -q master && git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch; do mergeBase=$(git merge-base master $branch) && [[ $(git cherry master $(git commit-tree $(git rev-parse $branch^{tree}) -p $mergeBase -m _)) == "-"* ]] && git branch -D $branch; done'
alias gprunefdev='git checkout -q dev && git for-each-ref refs/heads/ "--format=%(refname:short)" | while read branch; do mergeBase=$(git merge-base dev $branch) && [[ $(git cherry dev $(git commit-tree $(git rev-parse $branch^{tree}) -p $mergeBase -m _)) == "-"* ]] && git branch -D $branch; done'
alias commithelp="echo '
^--^  ^------------^
|     |
|     +-> Summary in present tense.
|
+-------> Type: build, chore, ci, docs, feat, fix, perf, refactor, revert, style, or test

feat: new feature for the user, not a new feature for build script
fix: a bug fix
docs: changes to the documentation only
style: formatting, white-space, etc; no production code change
refactor: code change that does not fix a bug or add a feature, eg. renaming a variable
perf: code change that improves performance
test: adding missing tests, refactoring tests; no production code change
build: change that affects the build system or external dependencies (example scopes: gulp, npm)
ci: change to the CI configuration files and scripts
chore: change that does not modify src or test files
revert: reverts a previous commit
'"

# pip
alias pip3update='pip3 list -o | cut -f 1 -d " " | xargs -n 1 pip3 install --upgrade'

# brew
alias cask='brew cask'
alias macupdate='softwareupdate -i -a;'
alias update='brew -v update; brew -v upgrade; brew cleanup; brew cask cleanup; brew prune; npm install npm -g; npm update -g; pip3update; gem update --system -f; gem update -f; vim +PlugUpdate +PlugUpgrade +UpdateRemotePlugins +qall;'

# applications
alias sketch="/Applications/Sketch.app/Contents/MacOS/Sketch"
alias chrome="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
alias idea='function __idea() { eval "$(/Applications/IntelliJ\ IDEA.app/Contents/MacOS/idea --args \"$@\")"; unset -f __idea; }; __idea'

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
alias dcrp="docker-compose run --rm --service-ports"
alias denv='function __denv() { eval "$(dm env $@)"; unset -f __denv; }; __denv'
alias dopen='function __dopen() { eval "$(open http://`docker-machine ip $@`)"; unset -f __dopen; }; __dopen'
alias dclean='docker rmi $(docker images --filter dangling=true)'
alias ddestroy='docker rmi $(docker images -a -q)'
alias dprune='docker image prune -a -f && docker container prune -f && docker volume prune -f'
alias dca='function __dca() { docker attach --sig-proxy=false --detach-keys=ctrl-c $(docker-compose ps -q "$1"); unset -f __dca; }; __dca'
alias dkill='pkill -f docker'

# kubernetes
alias k="kubectl"

# node
alias tc="tsc --pretty --noEmit --watch"

# ruby
alias critic="rubycritic -f console && sandi_meter -d || true && rails_best_practices"

# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/rails/rails.plugin.zsh
function _rails_command () {
  if [ -e "bin/stubs/rails" ]; then
    bin/stubs/rails $@
  elif [ -e "bin/rails" ]; then
    bin/rails $@
  elif [ -e "script/rails" ]; then
    ruby script/rails $@
  elif [ -e "script/server" ]; then
    ruby script/$@
  else
    command rails $@
  fi
}

function _rake_command () {
  if [ -e "bin/stubs/rake" ]; then
    bin/stubs/rake $@
  elif [ -e "bin/rake" ]; then
    bin/rake $@
  elif type bundle &> /dev/null && ([ -e "Gemfile" ] || [ -e "gems.rb" ]); then
    bundle exec rake $@
  else
    command rake $@
  fi
}

function _rspec_command () {
  if type bundle &> /dev/null && ([ -e "Gemfile" ] || [ -e "gems.rb" ]); then
    bundle exec rspec $@
  else
    command rspec $@
  fi
}

alias rails='_rails_command'

alias rake='_rake_command'

alias rspec='_rspec_command'

# go
export PATH=$PATH:/usr/local/opt/go/libexec

# commands
alias serve="python -m http.server"
alias killall='pkill -f Python node bash nvim ruby ngrok spring'
alias largest='function _largest() { find . -name "*.$@" | xargs wc -l | sort -nr -k5 | head -n 25; unset -f _largest; }; _largest'

# starship
eval "$(starship init zsh)"

# zsh
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^B' backward-word
bindkey '^F' forward-word
bindkey '^D' delete-word
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down
source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh

if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
fi

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
