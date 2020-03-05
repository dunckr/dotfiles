#!/bin/sh

NODE_VERSION=13.9.0
RUBY_VERSION=2.5.1

TAPS=(
  homebrew/cask
  homebrew/cask-fonts
  neovim/homebrew-neovim
)
FORMULAS=(
  ack
  awscli
  bash
  bash-completion
  bash-git-prompt
  cloc
  coreutils
  ctags
  fzf
  git
  gnupg
  hub
  neovim
  node
  nvm
  postgres
  python
  rbenv
  ruby-build
  shellcheck
  siege
  terraform
  tmux
  tree
)
CASKS=(
  beardedspice
  docker
  dropbox
  firefox
  font-source-code-pro
  google-chrome
  intellij-idea
  iterm2
  licecap
  muzzle
  pennywise
  phoenix
  sketch
  skype
  slack
  spotify
  sublime-text
  vlc
  xquartz
)
NPM_PACKAGES=(
  @prettier/plugin-ruby
  diff-so-fancy
  javascript-typescript-langserver
  prettier
  typescript
  yarn
)
GEMS=(
  brakeman
  bundler-audit
  rails_best_practices
  reek
  rubocop
  rubycritic
  sandi_meter
  tmuxinator
)
PIP_PACAKGES=(
  neovim
)

for tap in "${TAPS[@]}"
do
  brew tap "$tap"
done

brew install "${FORMULAS[@]}"
brew update
brew cask install "${CASKS[@]}"
brew cleanup

source /usr/local/opt/nvm/nvm.sh

nvm install $NODE_VERSION
nvm alias default $NODE_VERSION

rbenv install $RUBY_VERSION -s
rbenv global $RUBY_VERSION

npm prune -g
npm update npm -g
npm install -g "${NPM_PACKAGES[@]}"
gem install "${GEMS[@]}"
pip3 install "${PIP_PACAKGES[@]}"

vim +PlugUpdate +PlugUpgrade +UpdateRemotePlugins +qall
