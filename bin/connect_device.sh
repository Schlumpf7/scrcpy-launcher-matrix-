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
  LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/.kodi/addons/script.scrcpy-launcher/bin/lib ~/.kodi/addons/script.scrcpy-launcher/bin/adb_arm64 connect "$addr"
else
  LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/.kodi/addons/script.scrcpy-launcher/bin/lib ~/.kodi/addons/script.scrcpy-launcher/bin/adb connect "$addr"
fi