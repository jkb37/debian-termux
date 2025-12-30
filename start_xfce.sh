#!/data/data/com.termux/files/usr/bin/bash

# Zabij stare procesy
kill -9 $(pgrep -f "termux.x11") 2>/dev/null

# Uruchom dźwięk (PulseAudio)
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1

# Przygotowanie sesji X11
export XDG_RUNTIME_DIR=${TMPDIR}
termux-x11 :0 >/dev/null 2>&1 &

# Czekaj na start serwera
sleep 2

# Uruchom aplikację Termux-X11 (Activity)
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
sleep 1

# Logowanie do Debiana i start XFCE
proot-distro login debian --shared-tmp -- /bin/bash -c "
    export DISPLAY=:0
    export PULSE_SERVER=127.0.0.1
    export XDG_RUNTIME_DIR=${TMPDIR}
    
    # Start usług systemowych
    sudo service dbus start
    
    # Start pulpitu jako jacob
    su - jacob -c 'dbus-launch --exit-with-session startxfce4'
"
