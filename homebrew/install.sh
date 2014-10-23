#!/bin/sh

ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"

TAPS=(
    caskroom/cask
)
FORMULAS=(
    caskroom/cask/brew-cask
    coreutils
    docker
    go
    git
    python
    python3
    tree
)
CASKS=(
    alfred
    dash
    dropbox
    firefox
    google-chrome
    iterm2
    node
    onepassword
    sketch
    skype
    spotify
    sublime-text3
    vlc
)

for tap in ${TAPS[@]}
do
    brew tap $tap
done

brew install ${FORMULAS[@]}
brew update
brew cask install ${CASKS[@]}
brew cask alfred link
brew cleanup
