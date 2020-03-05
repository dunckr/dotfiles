defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)

# Always open everything in Finder's list view. This is important.
defaults write com.apple.Finder FXPreferredViewStyle Nlsv

# Show the ~/Library folder.
chflags nohidden ~/Library

# Set sidebar icon size to small
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Menu bar: hide the Time Machine, Volume, User, and Bluetooth icons
for domain in ~/Library/Preferences/ByHost/com.apple.systemuiserver.*; do
        defaults write "${domain}" dontAutoLoad -array \
            "/System/Library/CoreServices/Menu Extras/TimeMachine.menu" \
            "/System/Library/CoreServices/Menu Extras/Volume.menu" \
            "/System/Library/CoreServices/Menu Extras/User.menu"
done
defaults write com.apple.systemuiserver menuExtras -array \
    "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
    "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
    "/System/Library/CoreServices/Menu Extras/Battery.menu" \
    "/System/Library/CoreServices/Menu Extras/Clock.menu"

# Stop xQuartz opening XTern
defaults write org.macosforge.xquartz.X11 nolisten_tcp 0
defaults write org.macosforge.xquartz.X11 app_to_run /usr/bin/true
