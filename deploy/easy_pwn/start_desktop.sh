#!/bin/bash
# easy_pwn : start kali desktop

# set env on sfos qxcompositor
#mkdir -p /run/user/1001
export XDG_RUNTIME_DIR=/run/user/100000

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

export $(dbus-launch)

# Start Xwayland window
/opt/easy_pwn/Xwayland &

sleep 3
export DISPLAY=:0

# force qt applications backend to Xwayland
export QT_QPA_PLATFORM=xcb 

# start xfce session
startxfce4
