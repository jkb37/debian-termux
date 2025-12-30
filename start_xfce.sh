#!/data/data/com.termux/files/usr/bin/bash

# 1. Czyszczenie starych procesów
kill -9 $(pgrep -f "termux.x11") 2>/dev/null
pulseaudio -k 2>/dev/null
rm -rf $TMPDIR/.X11-unix

# 2. Start dźwięku
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1

# 3. Przygotowanie X11
export XDG_RUNTIME_DIR=${TMPDIR}
termux-x11 :0 >/dev/null 2>&1 &

sleep 2
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
sleep 1

# 4. Start Debiana
proot-distro login debian --shared-tmp -- bash <<-'EOF'
    export DISPLAY=:0
    export PULSE_SERVER=127.0.0.1
    
    # Rozwiązanie problemu z UID i XDG_RUNTIME_DIR
    export XDG_RUNTIME_DIR=/tmp/runtime-jacob
    mkdir -p $XDG_RUNTIME_DIR
    chmod 700 $XDG_RUNTIME_DIR
    chown jacob:jacob $XDG_RUNTIME_DIR

    sudo service dbus start
    
    su - jacob <<-'EOT'
        export DISPLAY=:0
        export PULSE_SERVER=127.0.0.1
        export XDG_RUNTIME_DIR=/tmp/runtime-jacob
        export LIBGL_ALWAYS_SOFTWARE=1
        export SESSION_MANAGER=""

        dbus-launch --exit-with-session bash -c "
            xfsettingsd &
            xfwm4 --replace & 
            xfce4-panel & 
            xfdesktop & 
            wait
        "
EOT
EOF
