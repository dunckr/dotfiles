#!/bin/sh

NODE_VERSION=14.17.0
RUBY_VERSION=3.0.2
PYTHON_VERSION=3.8.3

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
  git-delta
  gnupg
  jq
  kompose
  neovim
  nodenv
  postgres
  rbenv
  ruby-build
  shellcheck
  siege
  starship
  terraform
  tree
  zsh-autosuggestions
  zsh-completions
  zsh-history-substring-search
  zsh-syntax-highlighting
)
CASKS=(
  docker
  dropbox
  firefox
  font-source-code-pro
  google-chrome
  intellij-idea
  iterm2
  licecap
  mongodb-compass
  muzzle
  ngrok
  pennywise
  phoenix
  sketch
  skype
  slack
  spotify
  virtualbox
  vlc
  xquartz
  zoomus
)
NPM_PACKAGES=(
  @prettier/plugin-ruby
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
  aws-shell
  neovim
)

for tap in "${TAPS[@]}"; do
  brew tap "$tap"
done

brew install "${FORMULAS[@]}"
brew update
brew cask install "${CASKS[@]}"
brew cleanup

nodenv install $NODE_VERSION -s
nodenv global $NODE_VERSION

rbenv install $RUBY_VERSION -s
rbenv global $RUBY_VERSION

pyenv install $PYTHON_VERSION -s
pyenv global $PYTHON_VERSION

npm prune -g
npm update npm -g
npm install -g "${NPM_PACKAGES[@]}"
gem install "${GEMS[@]}"
pip3 install "${PIP_PACAKGES[@]}"

vim +PlugUpdate +PlugUpgrade +UpdateRemotePlugins +qall
