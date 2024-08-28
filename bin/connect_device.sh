#!/bin/bash
PLATFORM=$(uname -m)
# Get IP address
if [ -z "$1" ]; then
    echo "Error, please specify IP address...exiting"
    exit 1
else
    addr="$1"
fi

if [ "$PLATFORM" == "aarch64" ]; then
  LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/.kodi/addons/script.scrcpy-launcher/bin/lib_arm64 ~/.kodi/addons/script.scrcpy-launcher/bin/lib_arm64/adb connect "$addr"
else
  LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/.kodi/addons/script.scrcpy-launcher/bin/lib ~/.kodi/addons/script.scrcpy-launcher/bin/lib/adb connect "$addr"
fi
