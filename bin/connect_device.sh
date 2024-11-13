#!/bin/bash

# Set platform-dependent variables
PLATFORM=$(uname -m)
ADDR="$1"

# Verify the IP address is provided
if [ -z "$ADDR" ]; then
    echo "Error: Please specify IP address...exiting"
    exit 1
fi

# Define library paths based on architecture
if [ "$PLATFORM" == "aarch64" ]; then
    LIB_PATH=~/.kodi/addons/script.scrcpy-launcher/bin/lib_arm64
else
    LIB_PATH=~/.kodi/addons/script.scrcpy-launcher/bin/lib
fi

# Connect to device using adb with correct environment variables
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LIB_PATH \
"$LIB_PATH/adb" connect "$ADDR"

# Check if adb connection was successful
if [ $? -eq 0 ]; then
    echo "Device connected successfully."
else
    echo "Failed to connect to device. Please verify IP and adb status."
    exit 1
fi
