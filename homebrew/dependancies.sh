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
  gnupg
  hub
  neovim
  node
  nvm
  puma/puma/puma-dev
  python
  rbenv
  ruby-build
  shellcheck
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
  iterm2
  licecap
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
npm prune -g
npm update npm -g
npm install -g "${NPM_PACKAGES[@]}"
gem install "${GEMS[@]}"
pip3 install "${PIP_PACAKGES[@]}"
