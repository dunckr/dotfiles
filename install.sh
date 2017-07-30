#!/bin/bash

dotfiles="$HOME/dotfiles"

link() {
  from="$1"
  to="$2"
  echo "Linking '$from' to '$to'"
  rm -f "$to"
  ln -s "$from" "$to"
}

bash osx/setup.sh
bash homebrew/install.sh
bash homebrew/dependancies.sh
bash nvim/setup.sh

for location in $(find home -name '.*'); do
  file="${location##*/}"
  file="${file%.sh}"
  link "$dotfiles/$location" "$HOME/$file"
done

link "$dotfiles/iterm2/" "$HOME/Library/Preferences/"
link "$dotfiles/nvim/init.vim" "$HOME/.config/nvim/"
link "$dotfiles/karabiner/" "$HOME/.config/karabiner/"
link "$dotfiles/tmuxinator" "$HOME/.tmuxinator"

mkdir ~/.nvm
