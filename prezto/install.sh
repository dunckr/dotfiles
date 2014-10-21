#!/bin/bash

zsh
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
chsh -s /bin/zsh

git clone https://github.com/dunckr/swash-prompt "${ZDOTDIR:-$HOME}/.zprezto/modules/prompt/functions"

