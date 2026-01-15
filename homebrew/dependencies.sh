#!/bin/sh

NODE_VERSION=24.13.0
RUBY_VERSION=4.0.1
PYTHON_VERSION=3.14.2

TAPS=(
  homebrew/cask
  neovim/homebrew-neovim
)
FORMULAS=(
  ack
  awscli
  bat
  cloc
  coreutils
  eza
  fd
  fzf
  gh
  git
  git-delta
  gnupg
  jq
  lazygit
  libpq
  neovim
  nodenv
  pyenv
  rbenv
  ripgrep
  ruby-build
  shellcheck
  siege
  starship
  tealdeer
  terraform
  tree
  zoxide
  zsh-autosuggestions
  zsh-completions
  zsh-history-substring-search
  zsh-syntax-highlighting
)
# WARNING: pennywise and muzzle may be unsigned and deprecated by Homebrew on 2026-09-01
# If removed, install manually from their websites
CASKS=(
  bitwarden
  claude-code
  docker
  dropbox
  firefox
  font-source-code-pro
  google-chrome
  intellij-idea
  licecap
  mongodb-compass
  muzzle
  pennywise
  phoenix
  slack
  spotify
  vlc
)
NPM_PACKAGES=(
  @prettier/plugin-ruby
  prettier
  prettier-plugin-tailwindcss
  typescript
  typescript-language-server
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
PIP_PACKAGES=(
  aws-shell
  neovim
)

for tap in "${TAPS[@]}"; do
  brew tap "$tap"
done

brew install "${FORMULAS[@]}"
brew update
brew install "${CASKS[@]}" --cask
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
pip3 install "${PIP_PACKAGES[@]}"

nvim +PlugUpdate +PlugUpgrade +UpdateRemotePlugins +qall

# Fix permissions of zsh
compaudit | xargs chmod g-w
