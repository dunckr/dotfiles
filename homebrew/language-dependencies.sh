#!/bin/sh

NODE_VERSION=24.13.0
RUBY_VERSION=4.0.1
PYTHON_VERSION=3.14.2

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
