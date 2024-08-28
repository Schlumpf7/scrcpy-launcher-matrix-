#!/bin/bash
PLATFORM=$(uname -m)

. /etc/profile


if [ -z "$1" ]; then
    echo "Error, please specify max fps...exiting"
    exit 1
else
    fps="$1"
fi

if [ -z "$2" ]; then
    echo "Error, please specify max size...exiting"
    exit 1
else
    size="$2"
fi

if [ -z "$3" ]; then
    echo "Error, please specify crop...exiting"
    exit 1
else
    crop="$3"
fi

if [ -z "$4" ]; then
    echo "Error, please specify bitrate...exiting"
    exit 1
else
    bitrate="$4"
fi

systemctl stop kodi # Must close kodi for proper video display

bin=~/.kodi/addons/script.scrcpy-launcher/bin

if [ "$PLATFORM" == "aarch64" ]; then
  SDL_VIDEO_EGL_DRIVER=libEGL.so SDL_VIDEO_GL_DRIVER=libGLESv2.so LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$bin/lib_arm64 PATH=$PATH:$bin SCRCPY_SERVER_PATH=$bin/lib_arm64/scrcpy-server $bin/lib_arm64/scrcpy --max-fps "$fps" -m "$size" --crop "$crop" --bit-rate "$bitrate" 
else
  SDL_VIDEO_EGL_DRIVER=libEGL.so SDL_VIDEO_GL_DRIVER=libGLESv2.so LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$bin/lib PATH=$PATH:$bin SCRCPY_SERVER_PATH=$bin/lib/scrcpy-server $bin/lib/scrcpy --max-fps "$fps" -m "$size" --crop "$crop" --bit-rate "$bitrate" 
fi
systemctl start kodi # Reopen kodi

