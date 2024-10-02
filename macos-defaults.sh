#!/bin/bash

# Contains random stuff you can change with prefs via command line. Running
# this script is not yet automated.

defaults write -g ApplePressAndHoldEnabled 0

# disable with defaults -currentHost delete -g AppleFontSmoothing
defaults -currentHost write -g AppleFontSmoothing -int 0
