#!/bin/bash

# Ensure adb has executable permissions
PLATFORM=$(uname -m)
if [ "$PLATFORM" == "aarch64" ]; then
    ADB_PATH=~/.kodi/addons/script.scrcpy-launcher/bin/lib_arm64/adb
    SCRCPY_PATH=~/.kodi/addons/script.scrcpy-launcher/bin/lib_arm64/scrcpy
    SCRCPY_SERVER_PATH=~/.kodi/addons/script.scrcpy-launcher/bin/lib_arm64/scrcpy-server
else
    ADB_PATH=~/.kodi/addons/script.scrcpy-launcher/bin/lib/adb
    SCRCPY_PATH=~/.kodi/addons/script.scrcpy-launcher/bin/lib/scrcpy
    SCRCPY_SERVER_PATH=~/.kodi/addons/script.scrcpy-launcher/bin/lib/scrcpy-server
fi

# Apply executable permissions if not already set
for file in "$ADB_PATH" "$SCRCPY_PATH" "$SCRCPY_SERVER_PATH"; do
    if [ ! -x "$file" ]; then
        chmod +x "$file"
    fi
done

# Connect to device using adb
if [ -z "$1" ]; then
    echo "Error: Please specify IP address...exiting"
    exit 1
else
    addr="$1"
fi

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(dirname "$ADB_PATH") "$ADB_PATH" connect "$addr"

if [ $? -eq 0 ]; then
    echo "Device connected successfully."
else
    echo "Failed to connect to device. Please verify IP and adb status."
    exit 1
fi
