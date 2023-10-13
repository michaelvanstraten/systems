# Set a blazingly fast keyboard repeat rate
defaults write -g KeyRepeat -int 2
# Set a shorter Delay until key repeat
defaults write -g InitialKeyRepeat -int 15

# Enable subpixel font rendering on non-Apple LCDs
defaults write NSGlobalDomain AppleFontSmoothing -int 2

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Enable tap to click (Trackpad)
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true
# Don' show recent applications in dock
defaults write com.apple.dock show-recents -bool FALSE

# Show Path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true

# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true

# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

defaults write com.apple.dock autohide-time-modifier -float 0.7

defaults write com.apple.finder _FXSortFoldersFirst -bool true

defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false

defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

defaults write com.apple.finder ShowMountedServersOnDesktop -bool true

defaults write com.apple.menuextra.clock DateFormat -string "\"EEE d MMM HH:mm:ss\""

defaults write com.apple.dock mru-spaces -bool false

defaults write com.apple.dock expose-group-apps -bool true

defaults write com.apple.spaces spans-displays -bool true

# Kill affected applications
for app in Safari Finder Dock Mail SystemUIServer; do
    killall "$app" >/dev/null 2>&1;
done
