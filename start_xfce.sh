#!/data/data/com.termux/files/usr/bin/bash

# 1. Czyszczenie starych procesów
kill -9 $(pgrep -f "termux.x11") 2>/dev/null
pulseaudio -k 2>/dev/null

# 2. Start dźwięku
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1

# 3. Przygotowanie X11
export XDG_RUNTIME_DIR=${TMPDIR}
termux-x11 :0 >/dev/null 2>&1 &

# Czekaj na start serwera i otwórz aplikację
sleep 2
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
sleep 1

# 4. Start Debiana i XFCE jako jacob
proot-distro login debian --shared-tmp -- /bin/bash -c "
    export DISPLAY=:0
    export PULSE_SERVER=127.0.0.1
    export XDG_RUNTIME_DIR=${TMPDIR}

    # Naprawa uprawnień do katalogu tymczasowego
    sudo chmod 1777 /tmp
    
    # Start bazy komunikacji systemowej
    sudo service dbus start
    
    # Start sesji jako jacob (używamy pojedynczego cudzysłowu dla su)
    su - jacob -c '
        export DISPLAY=:0
        export PULSE_SERVER=127.0.0.1
        export XDG_RUNTIME_DIR=/tmp
        export LIBGL_ALWAYS_SOFTWARE=1
        
        # Wyłączamy sprawdzanie sesji przez menedżera okien
        export SESSION_MANAGER=\"\"

        dbus-launch --exit-with-session bash -c \"
            xfsettingsd &
            xfwm4 --replace & 
            xfce4-panel & 
            xfdesktop & 
            wait
        \"
    '
"
