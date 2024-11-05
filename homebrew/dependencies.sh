#!/bin/sh

NODE_VERSION=22.11.0
RUBY_VERSION=3.3.0
PYTHON_VERSION=3.10.4

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
  gh
  git
  git-delta
  gnupg
  jq
  libpq
  neovim
  nodenv
  pyenv
  rbenv
  ruby-build
  shellcheck
  siege
  starship
  svn
  terraform
  tree
  zsh-autosuggestions
  zsh-completions
  zsh-history-substring-search
  zsh-syntax-highlighting
)
CASKS=(
  bitwarden
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
  skype
  slack
  spotify
  vlc
)
NPM_PACKAGES=(
  @prettier/plugin-ruby
  javascript-typescript-langserver
  prettier
  prettier-plugin-tailwindcss
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
pip3 install "${PIP_PACAKGES[@]}"

vim +PlugUpdate +PlugUpgrade +UpdateRemotePlugins +qall

# Fix permissions of zsh
compaudit | xargs chmod g-w
