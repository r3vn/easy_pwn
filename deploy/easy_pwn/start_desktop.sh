#!/bin/bash
# easy_pwn : start kali desktop

if [ "$1" == "l" ]
then
	# Landscape mode
	# connect to qxcompositor wayland socket
	export WAYLAND_DISPLAY=../../display/wayland-1
else
	# Portrait mode
	# connect to sfos wayland socket
	export WAYLAND_DISPLAY=../../display/wayland-0
fi

# set env
export XDG_RUNTIME_DIR=/run/user/1001
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/dbus/system_bus_socket"
export BROWSER="/usr/bin/firefox"
export LANG=C
export QT_QPA_PLATFORM=xcb # force qt applications backend to Xwayland
export $(dbus-launch)

# Start Xwayland window
/opt/easy_pwn/Xwayland &
sleep 3

# set display to xwayland
export DISPLAY=:0

# start xfce session
startxfce4 
