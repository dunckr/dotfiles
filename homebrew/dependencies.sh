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
  cloc
  coreutils
  fzf
  git
  gnupg
  neovim
  node
  nvm
  postgres
  python
  rbenv
  ruby-build
  shellcheck
  siege
  starship
  terraform
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
  ngrok
  pennywise
  phoenix
  sketch
  skype
  slack
  spotify
  sublime-text
  vlc
  xquartz
  zoomus
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
)
PIP_PACAKGES=(
  neovim
)

for tap in "${TAPS[@]}"; do
  brew tap "$tap"
done

brew install "${FORMULAS[@]}"
brew update
brew cask install "${CASKS[@]}"
brew cleanup

. /usr/local/opt/nvm/nvm.sh

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
