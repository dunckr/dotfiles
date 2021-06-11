#!/bin/bash

dir="dotfiles"

cd "$HOME" || exit
mkdir "$dir"

git clone https://github.com/dunckr/dotfiles "$dir"

cd "$dir" || exit
bash setup.sh
