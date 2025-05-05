#!/bin/bash

# Absolute path to your Flutter project directory
PROJECT_DIR="$HOME/Desktop/tbp"

# AppleScript to open new Terminal tab and run flutter attach
osascript <<EOF
tell application "Terminal"
  activate
  do script "cd \"$PROJECT_DIR\" && flutter attach"
end tell
EOF
