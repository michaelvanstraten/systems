#!/bin/bash

# macOS System Customization Script
# This script configures various system settings in macOS to enhance user experience and customization.
# Please review and adjust the settings as needed for your preferences.

# === Keyboard Settings ===
# Set a faster keyboard repeat rate
defaults write -g KeyRepeat -int 2
# Set a shorter delay until key repeat
defaults write -g InitialKeyRepeat -int 15

# === Display Settings ===
# Enable subpixel font rendering on non-Apple LCDs
defaults write NSGlobalDomain AppleFontSmoothing -int 2

# === Dock Settings ===
# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true
# Make Dock icons of hidden applications translucent
defaults write com.apple.dock showhidden -bool true
# Don't show recent applications in Dock
defaults write com.apple.dock show-recents -bool false
# Set Dock autohide time modifier
defaults write com.apple.dock autohide-time-modifier -float 0.7
# Show indicator lights for open applications in the Dock
defaults write com.apple.dock show-process-indicators -bool true
# Disable most recently used spaces in Dock
defaults write com.apple.dock mru-spaces -bool false
# Enable grouping of application windows in Exposé
defaults write com.apple.dock expose-group-apps -bool true

# === Finder Settings ===
# Show Path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true
# Sort folders first in Finder
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Disable the warning when changing a file extension in Finder
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# Don't show external hard drives on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
# Don't show removable media on the desktop
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
# Show mounted servers on the desktop
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true

# === Miscellaneous Settings ===
# Avoid creating .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# === Menu Bar Clock Format ===
# Customize the date and time format in the menu bar clock
defaults write com.apple.menuextra.clock DateFormat -string "\"EEE d MMM HH:mm:ss\""

# === Kill Affected Applications ===
# Restart applications to apply the changes
for app in Safari Finder Dock Mail SystemUIServer; do
    killall "$app" >/dev/null 2>&1;
done
