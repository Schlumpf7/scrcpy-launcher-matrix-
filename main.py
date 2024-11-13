# -*- coding: utf-8 -*-

import os
import sys
import subprocess
from subprocess import CalledProcessError
import xbmcaddon
import xbmcgui
import platform

arch = platform.machine()

def adb_connect_to_device(addr):
    try:
        result = subprocess.check_output(
            f"~/.kodi/addons/script.scrcpy-launcher/bin/connect_device.sh {addr}", shell=True
        )
        if "connected" not in result.decode():
            xbmcgui.Dialog().ok("Error connecting to device", result.decode())
            return False
        return True
    except CalledProcessError as procError:
        xbmcgui.Dialog().ok("Error connecting to device", procError.output.decode())
        return False

addon = xbmcaddon.Addon(id='script.scrcpy-launcher')

while True:
    opt = xbmcgui.Dialog().contextmenu(['Stream Device', 'Settings'])
    
    if opt == 0:
        addr = addon.getSetting('ipaddress')
        
        if adb_connect_to_device(addr):
            while True:
                try:
                    # Check if USB debugging was authorized
                    if arch == 'aarch64':
                        launch_command = "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/.kodi/addons/script.scrcpy-launcher/bin/lib_arm64 ~/.kodi/addons/script.scrcpy-launcher/bin/lib_arm64/adb devices"
                    elif arch == 'armhf':
                        launch_command = "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/.kodi/addons/script.scrcpy-launcher/bin/lib ~/.kodi/addons/script.scrcpy-launcher/bin/lib/adb devices"
                    else:
                        xbmcgui.Dialog().ok("Unsupported Architecture", f"Architecture {arch} is not supported.")
                        sys.exit()

                    result = subprocess.check_output(launch_command, shell=True).decode()
                    
                    if "unauthorized" in result:
                        xbmcgui.Dialog().ok("Unauthorized", "Please allow USB debugging connection on the Android device")
                    else:
                        break
                except CalledProcessError as procError:
                    xbmcgui.Dialog().ok("Error", f"Failed to execute command: {procError}")
                    break
            
            # Retrieve settings and construct launch command
            fps = addon.getSetting('fps')
            size = addon.getSetting('size')
            crop = addon.getSetting('crop')
            bitrate = addon.getSetting('bitrate')

            launch_command = [
                "bash", "~/.kodi/addons/script.scrcpy-launcher/bin/launch_scrcpy.sh",
                fps, size, crop, bitrate
            ]
            subprocess.Popen(launch_command, shell=False)

        sys.exit()

    elif opt == 1:
        addon.openSettings()
    else:
        sys.exit()

