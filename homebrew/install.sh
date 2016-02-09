#!/bin/sh

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

TAPS=(
  caskroom/cask
  caskroom/fonts
  neovim/homebrew-neovim
)
FORMULAS=(
  bash-completion
  bash-git-prompt
  boot2docker
  caskroom/cask/brew-cask
  cloc
  coreutils
  docker
  docker-machine
  docker-swarm
  git
  go
  graphicsmagick
  hub
  imagemagick
  neovim
  python
  python3
  selenium-server-standalone
  terraform
  tree
)
CASKS=(
  alfred
  bartender
  beardedspice
  dash
  dropbox
  firefox
  font-source-code-pro
  google-chrome
  iterm2
  node
  onepassword
  seil
  sketch
  skype
  slate
  spotify
  sublime-text
  tmux
  vagrant
  vim
  virtualbox
  vlc
)

for tap in ${TAPS[@]}
do
  brew tap $tap
done

brew install ${FORMULAS[@]}
brew update
brew cask install ${CASKS[@]}
brew cask alfred link
brew cleanup
