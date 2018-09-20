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
  ctags
  fzf
  git
  hub
  neovim
  node
  nvm
  python
  rbenv
  ruby-build
  shellcheck
  terraform
  tmux
  tree
)
CASKS=(
  # virtualbox
  1password
  beardedspice
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
  javascript-typescript-langserver
  prettier
  typescript
  yarn
)
GEMS=(
  rails_best_practices
  reek
  rubocop
  rubycritic
  sandi_meter
  solargraph
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
