#!/bin/sh

ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

install coreutils
install git
install go

exit 0
