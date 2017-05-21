#!/bin/sh

TAPS=(
  caskroom/cask
  caskroom/fonts
  neovim/homebrew-neovim
)
FORMULAS=(
  alfred2
  bash
  bash-completion
  bash-git-prompt
  caskroom/cask/brew-cask
  cloc
  coreutils
  fzf
  git
  hipchat
  hub
  neovim
  node
  python
  python3
  rbenv
  ruby-build
  selenium-server-standalone
  shellcheck
  slack
  terraform
  tmux
  tree
)
CASKS=(
  beardedspice
  dash
  docker
  dropbox
  firefox
  font-droid-sans-mono
  font-source-code-pro
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
  xquartz
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
  scss-lint
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
