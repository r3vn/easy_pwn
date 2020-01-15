#!/bin/bash
# easy_pwn : [EXPERIMENTAL] start wireshark on wayland display

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
export QT_QPA_PLATFORM=wayland # force qt applications backend to Xwayland
export $(dbus-launch)

# Start kwin_wayland
#kwin_wayland --wayland-display ../../display/wayland-0 --socket ../../display/wayland-kwin & # --xwayland for xwayland support
#sleep 3

# set display for xwayland
#export DISPLAY=:0

# set display for wayland
#export WAYLAND_DISPLAY=../../display/wayland-kwin

# start wireshark
wireshark
