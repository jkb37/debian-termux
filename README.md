Termux + x11 + Debian with XCFE on Oneplus Pad 2

The "Not connected" problem:

1. Enable Developer options in settings
2. Enable wireless debugging
3. Set Suspend cached app processes off 
4. Get "Brevent" app fromm play store
5. Paste this line into the exec: "settings put global settings_enable_monitor_phantom_procs false"
6. Set power plan to maximum performance
7. Set Termux and Termux X11 battery optimizations off 

The "No sound" problem:
1. Set the line "exit-idle-time= -1"  in  /data/data/com.termux/files/usr/etc/pulse/daemon.conf
2. Delete the "#" from the front of the line "load-module module-aaudio-sink"  in  nano /data/data/com.termux/files/usr/etc/pulse/default.pa

