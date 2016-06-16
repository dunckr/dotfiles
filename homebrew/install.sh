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
  diff-so-fancy
  docker
  docker-machine
  docker-swarm
  git
  graphicsmagick
  hub
  imagemagick
  kubectl
  neovim
  python
  python3
  rust
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
  google-cloud-sdk
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
  virtualbox
  vlc
)
PACKAGES=(
  coffee-react
  coffee-react-transform
  coffee-script
  coffeelint-cjsx
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
npm update npm -g
npm install -g ${PACKAGES[@]}
