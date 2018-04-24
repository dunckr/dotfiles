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
  terraform
  tmux
  tmuxinator-completion
  tree
)
CASKS=(
  # Failing
  # virtualbox
  1password
  beardedspice
  dash
  docker
  dropbox
  firefox
  font-source-code-pro
  google-chrome
  iterm2
  jadengeller-helium
  licecap
  phoenix
  sketch
  skype
  slack
  spotify
  sublime-text
  vagrant
  vlc
  xquartz
)
NPM_PACKAGES=(
  diff-so-fancy
  eslint
  eslint-config-airbnb
  eslint-plugin-import
  eslint-plugin-jsx-a11y
  eslint-plugin-react
  http-server
  js-beautify
  jsonlint
  neovim
  prettier
  svgo
  tern
  yarn
)
GEMS=(
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
brew cleanup
npm prune -g
npm update npm -g
npm install -g "${NPM_PACKAGES[@]}"
gem install "${GEMS[@]}"
pip3 install "${PIP_PACAKGES[@]}"
