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

# Define paths based on architecture
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

# Set XDG_RUNTIME_DIR to prevent errors
export XDG_RUNTIME_DIR=/tmp/runtime-$(id -u)

# Set the full path to adb if it's in the same folder as scrcpy
ADB_PATH="$BIN_PATH/adb"

# Ensure adb has executable permissions
if [ ! -x "$ADB_PATH" ]; then
    chmod +x "$ADB_PATH"
fi

# Start adb server if not already running
"$ADB_PATH" start-server

# Start scrcpy with specified options
"$BIN_PATH/scrcpy" --max-fps "$fps" -m "$size" --crop "$crop" --bit-rate "$bitrate"
