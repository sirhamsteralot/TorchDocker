#!/bin/bash
set -e

# Directory for SteamCMD
STEAMCMD_DIR="$HOME/steamcmd"
mkdir -p "$STEAMCMD_DIR"
cd "$STEAMCMD_DIR"

# Download SteamCMD if not already present
if [ ! -f steamcmd.sh ]; then
    echo "Downloading SteamCMD..."
    wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
    tar -xvzf steamcmd_linux.tar.gz
fi

# Run SteamCMD to download Space Engineers Dedicated Server
./steamcmd.sh +login anonymous +force_install_dir /torch +app_update 298740 validate +quit

echo "Space Engineers Dedicated Server is installed in /torch."

cd /torch

# Set display
export DISPLAY=:0

# Start Xvfb in the background
Xvfb $DISPLAY -screen 0 1024x768x16 -ac -nolisten tcp &

# Give Xvfb a moment to start
sleep 2

# Run the Torch server with Wine in headless mode
exec wine Torch.Server.exe --nogui
