#!/bin/bash

# Contains random stuff you can change with prefs via command line. Running
# this script is not yet automated.

# Disable press-and-hold for keys in favor of key repeat
defaults write -g ApplePressAndHoldEnabled -bool false

# Faster key repeat rate and shorter delay until repeat
defaults write -g InitialKeyRepeat -int 15
defaults write -g KeyRepeat -int 2

# disable with defaults -currentHost delete -g AppleFontSmoothing
defaults -currentHost write -g AppleFontSmoothing -int 0

# Show seconds on top right clock
defaults write com.apple.menuextra.clock ShowSeconds -bool true

# Show path bar and status bar in Finder
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true

# Disable .DS_Store creation on network volumes and USB drives
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Expand save panel by default
defaults write -g NSNavPanelExpandedStateForSaveMode -bool true
defaults write -g NSNavPanelExpandedStateForSaveMode2 -bool true

# Expand print panel by default
defaults write -g PMPrintingExpandedStateForPrint -bool true
defaults write -g PMPrintingExpandedStateForPrint2 -bool true
