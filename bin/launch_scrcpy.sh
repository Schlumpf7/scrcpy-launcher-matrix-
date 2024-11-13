#!/bin/bash

# Load environment settings
. /etc/profile

# Set platform-dependent variables
PLATFORM=$(uname -m)

# Check for all required parameters
fps="${1:-}"
size="${2:-}"
crop="${3:-}"
bitrate="${4:-}"

if [ -z "$fps" ] || [ -z "$size" ] || [ -z "$crop" ] || [ -z "$bitrate" ]; then
    echo "Error: Missing parameters. Usage: $0 <fps> <size> <crop> <bitrate>"
    exit 1
fi

# Define paths and libraries based on architecture
if [ "$PLATFORM" == "aarch64" ]; then
    BIN_PATH=~/.kodi/addons/script.scrcpy-launcher/bin/lib_arm64
else
    BIN_PATH=~/.kodi/addons/script.scrcpy-launcher/bin/lib
fi

# Ensure scrcpy and scrcpy-server have executable permissions
for file in "$BIN_PATH/scrcpy" "$BIN_PATH/scrcpy-server"; do
    if [ ! -x "$file" ]; then
        chmod +x "$file"
    fi
done

# Set SDL environment variables for EGL/GL support
export SDL_VIDEO_EGL_DRIVER=libEGL.so
export SDL_VIDEO_GL_DRIVER=libGLESv2.so
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BIN_PATH
export PATH=$PATH:$BIN_PATH
export SCRCPY_SERVER_PATH=$BIN_PATH/scrcpy-server

# Stop Kodi (optional, uncomment if needed for debugging)
# systemctl stop kodi

# Start scrcpy with specified options
"$BIN_PATH/scrcpy" --max-fps "$fps" -m "$size" --crop "$crop" --bit-rate "$bitrate"

# Restart Kodi (optional, uncomment if needed for debugging)
# systemctl start kodi
