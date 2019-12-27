#!/bin/bash
# Sailfish OS easy_pwn
#
# Copyright (C) 2020 <Giuseppe `r3vn` Corti>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# check privileges

if [ "$EUID" -ne 0 ]
then 
	echo "[!] run as root"
	exit 1
fi

# check args
if [ "$#" -ne 2 ] 
then
  echo "[!] usage: $0 [action] [destination-path]" 
  exit 1
fi

# set variables
PWN_SH=`readlink -f "$0"`
PWN_DIR=`dirname "$PWN_SH"`
ACTION="$1"
TARGET="$2"
KALI_IMG="https://build.nethunter.com/kalifs/kalifs-latest/kalifs-armhf-minimal.tar.xz"
PR_DIR=`dirname "$TARGET"`
CHROOT_NAME=`basename "$TARGET"`
CHROOT_PATH=`readlink -f "$TARGET"`
PWN_ICON=$PWN_DIR/src/kali-panel-menu.svg

check_mount() {
	# mount dev sys proc
	if mountpoint -q $TARGET/dev/
	then
		echo "[+] dev sys and proc mounted"
	else
		echo "[-] mounting dev sys and proc"
		# dev sys proc
		mount -t proc proc $TARGET/proc/
		mount --rbind /sys $TARGET/sys/
		mount --rbind /dev $TARGET/dev/

		# mount devpts and run
		mount --bind /dev/pts $TARGET/dev/pts
		mount --bind /run $TARGET/run
		
		sleep 2
	fi
}

update_pwn(){
	# deploy easy pwn
	echo "[-] easy_pwn deploy..."
	mkdir -p $TARGET/opt/easy_pwn
	cp -avr -T $PWN_DIR/deploy/easy_pwn $TARGET/opt/easy_pwn

	# deploy xfce configs
	echo "[-] user configs deploy..."
	mkdir -p $TARGET/root/.config
	cp -avr -T $PWN_DIR/deploy/configs $TARGET/root/.config

	# add execution permissions on /opt/easy_pwn
	chmod +x $TARGET/opt/easy_pwn/setup_desktop.sh
	chmod +x $TARGET/opt/easy_pwn/start_desktop.sh
}

install_icon(){
	echo "[-] installing $CHROOT_NAME.desktop in /home/nemo/.local/share/applications..."
	sed "s|XX_PWNPATH_XX|$PWN_DIR|g" $PWN_DIR/src/easy_pwn.desktop > /home/nemo/.local/share/applications/$CHROOT_NAME.desktop
	sed -i "s|XX_NAME_XX|$CHROOT_NAME|g" /home/nemo/.local/share/applications/$CHROOT_NAME.desktop 
	sed -i "s|XX_CHROOTPATH_XX|$CHROOT_PATH|g" /home/nemo/.local/share/applications/$CHROOT_NAME.desktop
	sed -i "s|XX_ICON_XX|$PWN_ICON|g" /home/nemo/.local/share/applications/$CHROOT_NAME.desktop

	sleep 1
}

# action switch
if [ "$ACTION" == "create" ]
then
	# create a new chroot

	if test -f "/tmp/kalifs-armhf-minimal.tar.xz"
	then
		echo "[+] found kalifs-armhf-minimal.tar.xz, skipping download"
	else
		# download latest kalifs armhf build from nethunter mirrors
		echo "[-] downloading latest kalifs armhf build from nethunter mirrors..."
		curl $KALI_IMG --output /tmp/kalifs-armhf-minimal.tar.xz
		sleep 1
	fi

	# untar kalifs archive
	echo "[-] unpacking kalifs-armhf-minimal..."
	xz -cd  /tmp/kalifs-armhf-minimal.tar.xz | tar xvf - -C $PR_DIR
	mv $PR_DIR/kali-armhf/ $TARGET/
	sleep 1

	# deploy easy_pwn
	update_pwn

	# add desktop launcher
	install_icon

	# mount dev sys proc
	check_mount

	echo "[+] done."
	echo "[-] chrooting..."

	# run kali-side script
	chroot $TARGET /opt/easy_pwn/setup_desktop.sh


elif [ "$ACTION" == "desktop" ]
then
	# start chroot desktop
	# mount dev sys proc
	check_mount

	echo "[?] select desktop orientation (default portrait): [p]ortrait, [l]andscape: "
	read DESKTOP_ORIENTATION

	if [ "$DESKTOP_ORIENTATION" == "l" ]
	then

		# set env on sfos qxcompositor
		mkdir -p /run/user/1001
		export $(dbus-launch)
		export XDG_RUNTIME_DIR=/run/user/1001

		# start qxcompositor
		echo "[-] starting qxcompositor..."
		qxcompositor --wayland-socket-name ../../display/wayland-1 &

		sleep 3

	fi

	echo "[+] done."
	echo "[-] chrooting..."

	# run kali-side script
	chroot $TARGET /opt/easy_pwn/start_desktop.sh $DESKTOP_ORIENTATION

elif [ "$ACTION" == "shell" ]
then
	# start chroot shell
	# mount dev sys proc
	check_mount

	echo "[+] done."
	echo "[-] chrooting..."

	# run kali-side script
	chroot $TARGET 

elif [ "$ACTION" == "update" ]
then
	# deploy easy_pwn
	update_pwn

	# install chroot icon
	install_icon

else
	echo "[!] wrong action"
fi