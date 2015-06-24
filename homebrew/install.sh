#!/bin/sh

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

TAPS=(
    caskroom/cask
    caskroom/fonts
    neovim/homebrew-neovim
)
FORMULAS=(
    caskroom/cask/brew-cask
    coreutils
    cloc
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
    neovim
    seil
    sketch
    skype
    slate
    spotify
    sublime-text
    tmux
    vagrant
    vim
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
