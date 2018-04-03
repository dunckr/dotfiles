#!/bin/sh

TAPS=(
  caskroom/cask
  caskroom/fonts
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
  fzf
  git
  hub
  neovim
  node
  python
  python3
  rbenv
  reattach-to-user-namespace
  ruby-build
  selenium-server-standalone
  shellcheck
  slack
  terraform
  tmux
  tmuxinator-completion
  tree
)
CASKS=(
  beardedspice
  dash
  docker
  dropbox
  firefox
  font-source-code-pro
  google-chrome
  iterm2
  licecap
  onepassword
  sketch
  skype
  slate
  spotify
  sublime-text
  vagrant
  virtualbox
  vlc
  xquartz
)
NPM_PACKAGES=(
  bs-platform
  diff-so-fancy
  eslint
  eslint-config-airbnb
  eslint-plugin-import
  eslint-plugin-jsx-a11y
  eslint-plugin-react
  js-beautify
  jsonlint
  neovim
  prettier
  reason-cli
  svgo
  tern
  yarn
)
GEMS=(
  # rails_best_practices
  # ruby-beautify
  # rubycritic
  # sandi_meter
  sass
  scss-lint
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
brew cask alfred link
brew cleanup
npm update npm -g
npm install -g "${NPM_PACKAGES[@]}"
gem install "${GEMS[@]}"
pip3 install "${PIP_PACAKGES[@]}"
