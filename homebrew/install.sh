#!/bin/sh

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

TAPS=(
    caskroom/cask
    caskroom/fonts
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
    bartender
    dash
    dropbox
    firefox
    font-source-code-pro
    google-chrome
    iterm2
    node
    onepassword
    seil
    sketch
    skype
    slate
    spotify
    sublime-text
    vagrant
    vlc
    virtualbox
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
