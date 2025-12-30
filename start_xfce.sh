#!/data/data/com.termux/files/usr/bin/bash

# 1. Czyszczenie starych procesów i plików tymczasowych
kill -9 $(pgrep -f "termux.x11") 2>/dev/null
pulseaudio -k 2>/dev/null
rm -rf $TMPDIR/.X11-unix
rm -rf $TMPDIR/runtime-jacob

# 2. Start dźwięku (PulseAudio)
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1

# 3. Przygotowanie i start serwera Termux-X11
export XDG_RUNTIME_DIR=${TMPDIR}
termux-x11 :0 -ac >/dev/null 2>&1 &

# Czekaj na start serwera i otwórz aplikację Termux-X11 na tablecie
sleep 2
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
sleep 1

# 4. Wejście do Debiana i start pulpitu
proot-distro login debian --shared-tmp -- bash <<-'EOF'
    # Ustawienie ścieżek systemowych
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    export DISPLAY=:0
    export PULSE_SERVER=127.0.0.1
    
    # Naprawa uprawnień dla D-Bus i środowiska graficznego
    export XDG_RUNTIME_DIR=/tmp/runtime-jacob
    mkdir -p $XDG_RUNTIME_DIR
    chmod 700 $XDG_RUNTIME_DIR
    chown jacob:jacob $XDG_RUNTIME_DIR
    
    # Start usług systemowych
    sudo service dbus restart
    
    # Logowanie na użytkownika jacob i start komponentów XFCE
    su - jacob <<-'EOT'
        export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
        export DISPLAY=:0
        export PULSE_SERVER=127.0.0.1
        export XDG_RUNTIME_DIR=/tmp/runtime-jacob
        export LIBGL_ALWAYS_SOFTWARE=1
        export SESSION_MANAGER=""

        dbus-launch --exit-with-session bash -c "
            xfsettingsd &
            xfwm4 --replace --compositor=off & 
            xfce4-panel & 
            xfdesktop & 
            wait
        "
EOT
EOF
