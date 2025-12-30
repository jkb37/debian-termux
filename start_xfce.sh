#!/data/data/com.termux/files/usr/bin/bash

# 1. Czyszczenie
kill -9 $(pgrep -f "termux.x11") 2>/dev/null
pulseaudio -k 2>/dev/null
rm -rf $TMPDIR/.X11-unix
rm -rf $TMPDIR/runtime-jacob

# 2. Start audio i X11
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
export XDG_RUNTIME_DIR=${TMPDIR}
termux-x11 :0 -ac >/dev/null 2>&1 &

sleep 2
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
sleep 1

# 3. Start Debiana
proot-distro login debian --shared-tmp -- bash <<-'EOF'
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
    export DISPLAY=:0
    export PULSE_SERVER=127.0.0.1
    export XDG_RUNTIME_DIR=/tmp/runtime-jacob
    
    mkdir -p $XDG_RUNTIME_DIR
    chmod 700 $XDG_RUNTIME_DIR
    chown jacob:jacob $XDG_RUNTIME_DIR
    
    sudo service dbus restart
    
    su - jacob <<-'EOT'
        export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
        export DISPLAY=:0
        export PULSE_SERVER=127.0.0.1
        export XDG_RUNTIME_DIR=/tmp/runtime-jacob
        export LIBGL_ALWAYS_SOFTWARE=1
        
        # Startujemy dbus-session i trzymamy sesję przy życiu
        dbus-launch --exit-with-session bash -c "
            xfsettingsd &
            xfwm4 &
            xfce4-panel &
            xfdesktop &
            # Ta linia sprawia, że skrypt nie zgaśnie, dopóki go nie zabijesz w Termuxie
            tail -f /dev/null
        "
	EOT
EOF
