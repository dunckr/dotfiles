#!/bin/bash

dotfiles="$HOME/dotfiles"

link() {
    from="$1"
    to="$2"
    echo "Linking '$from' to '$to'"
    rm -f "$to"
    ln -s "$from" "$to"
}

sudo bash spf13/install.sh
sudo bash osx/custom.sh
sudo bash homebrew/install.sh
sudo zsh prezto/install.sh

for location in $(find home -name '.*'); do
    file="${location##*/}"
    file="${file%.sh}"
    link "$dotfiles/$location" "$HOME/$file"
done

