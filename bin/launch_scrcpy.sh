#!/bin/bash

# Log everything to a debug file
LOGFILE="/tmp/scrcpy_debug.log"
echo "Script started at $(date)" >> "$LOGFILE"
echo "Platform: $(uname -m)" >> "$LOGFILE"

# Load environment settings
. /etc/profile

# Set platform-dependent variables
PLATFORM=$(uname -m)

# Debugging: Check that parameters are being passed correctly
echo "Parameters: fps=$1, size=$2, crop=$3, bitrate=$4" >> "$LOGFILE"

# Check for all required parameters
fps="${1:-}"
size="${2:-}"
crop="${3:-}"
bitrate="${4:-}"

if [ -z "$fps" ] || [ -z "$size" ] || [ -z "$crop" ] || [ -z "$bitrate" ]; then
    echo "Error: Missing parameters. Usage: $0 <fps> <size> <crop> <bitrate>" >> "$LOGFILE"
    exit 1
fi

# Define paths based on architecture
if [ "$PLATFORM" == "aarch64" ]; then
    BIN_PATH=~/.kodi/addons/script.scrcpy-launcher/bin/lib_arm64
else
    BIN_PATH=~/.kodi/addons/script.scrcpy-launcher/bin/lib
fi

# Debugging: Check if the bin path exists
echo "Bin path: $BIN_PATH" >> "$LOGFILE"
if [ ! -d "$BIN_PATH" ]; then
    echo "Error: Bin path $BIN_PATH not found" >> "$LOGFILE"
    exit 1
fi

# Ensure scrcpy and scrcpy-server have executable permissions
for file in "$BIN_PATH/scrcpy" "$BIN_PATH/scrcpy-server"; do
    if [ ! -x "$file" ]; then
        chmod +x "$file"
        echo "Made $file executable" >> "$LOGFILE"
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

# Debugging: Ensure adb is executable
if [ ! -x "$ADB_PATH" ]; then
    chmod +x "$ADB_PATH"
    echo "Made adb executable" >> "$LOGFILE"
fi

# Start adb server if not already running
echo "Starting adb server..." >> "$LOGFILE"
"$ADB_PATH" start-server >> "$LOGFILE" 2>&1

# Stop Kodi (xbmc) to allow scrcpy to take control of the screen
echo "Stopping Kodi (xbmc)..." >> "$LOGFILE"
systemctl stop kodi >> "$LOGFILE" 2>&1
if [ $? -eq 0 ]; then
    echo "Kodi (xbmc) stopped successfully" >> "$LOGFILE"
else
    echo "Failed to stop Kodi (xbmc)" >> "$LOGFILE"
    exit 1
fi

# Start scrcpy with specified options
echo "Starting scrcpy..." >> "$LOGFILE"
"$BIN_PATH/scrcpy" --max-fps "$fps" -m "$size" --crop "$crop" --bit-rate "$bitrate" >> "$LOGFILE" 2>&1
if [ $? -eq 0 ]; then
    echo "scrcpy started successfully" >> "$LOGFILE"
else
    echo "Failed to start scrcpy" >> "$LOGFILE"
    exit 1
fi

# Restart Kodi (xbmc) after scrcpy finishes
echo "Starting Kodi (xbmc)..." >> "$LOGFILE"
systemctl start kodi >> "$LOGFILE" 2>&1
if [ $? -eq 0 ]; then
    echo "Kodi (xbmc) restarted successfully" >> "$LOGFILE"
else
    echo "Failed to restart Kodi (xbmc)" >> "$LOGFILE"
    exit 1
fi

echo "Script finished at $(date)" >> "$LOGFILE"
