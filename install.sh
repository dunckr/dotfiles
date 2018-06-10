#!/bin/bash

dir="dotfiles"

cd "$HOME"
mkdir "$dir"

git clone https://github.com/dunckr/dotfiles "$dir"

cd "$dir"
bash setup.sh
