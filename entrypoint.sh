#!/bin/bash
set -e

# Set display
export DISPLAY=:0

# Start Xvfb in the background
Xvfb $DISPLAY -screen 0 1024x768x16 -ac -nolisten tcp &

# Give Xvfb a moment to start
sleep 2

# Run the Torch server with Wine in headless mode
exec wine Torch.Server.exe --nogui
