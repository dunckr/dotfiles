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
  caskroom/cask/brew-cask
  cloc
  coreutils
  diff-so-fancy
  docker
  git
  hub
  kubectl
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
  google-cloud-sdk
  iterm2
  licecap
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
NPM_PACKAGES=(
  coffee-react
  coffee-react-transform
  coffee-script
  coffeelint-cjsx
  eslint
  js-beautify
)
GEMS=(
  ruby-beautify
  sass
)
PIP_PACAKGES=(
  flake8
  neovim
  pyflakes
  pylint
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
npm install -g ${NPM_PACKAGES[@]}
gem install ${GEMS[@]}
pip install ${PIP_PACAKGES[@]}
