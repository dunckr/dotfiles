#!/bin/sh

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
  git
  hub
  neovim
  node
  python
  python3
  selenium-server-standalone
  terraform
  tree
)
CASKS=(
  alfred2
  beardedspice
  dash
  docker
  dropbox
  firefox
  font-source-code-pro
  font-droid-sans-mono
  google-chrome
  iterm2
  karabiner-elements
  licecap
  onepassword
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
  diff-so-fancy
  esformatter
  eslint
  eslint-config-airbnb
  eslint-config-airbnb-base
  eslint-plugin-import
  prettier
  svgo
  tern
)
GEMS=(
  rails_best_practices
  ruby-beautify
  rubycritic
  sandi_meter
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
pip3 install ${PIP_PACAKGES[@]}
