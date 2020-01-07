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
if [ "$#" -lt 2 ] 
then
	echo "[!] usage: $0 [action] [destination-path]" 
	exit 1
fi

# set variables
PWN_SH=`readlink -f "$0"`
PWN_DIR=`dirname "$PWN_SH"`
ACTION="$1"
TARGET="$2"
PR_DIR=`dirname "$TARGET"`
CHROOT_NAME=`basename "$TARGET"`
CHROOT_PATH=`readlink -f "$TARGET"`
PWN_ICON=$PWN_DIR/src/icon.png

# import default settings
. $PWN_DIR/settings.sh


kill_chroot() {
	# Find processes who's root folder is actually the chroot
	# https://askubuntu.com/a/552038

	echo "[!] WARNING : killing all chroot processes"

	for ROOT in $(find /proc/*/root)
	do
		# Check where the symlink is pointing to
		LINK=$(readlink -f $ROOT)

		# If it's pointing to the $CHROOT you set above, kill the process
		if echo $LINK | grep -q ${CHROOT_PATH%/}
		then
			PID=$(basename $(dirname "$ROOT"))
			echo "[!] killing $PID"

			# store logs on epw-session.log
			kill -9 $PID > /tmp/$CHROOT_NAME/epwn-session.log 2>&1
		fi
	done
	sleep 1

}

umount_all(){
	# umount the chroot
	if mountpoint -q $TARGET/dev/
	then
		umount -R $TARGET/dev/pts
		#umount -R $TARGET/run/display	
		umount -R $TARGET/run
		umount -R $TARGET/tmp/
		umount $TARGET/proc/
		umount -R $TARGET/dev/
		umount -R $TARGET/sys/
		umount -R $TARGET/var/lib/dbus
		umount -R /run/user/1001/pulse

		echo "[+] chroot umounted"

		sleep 2
	else
		echo "[-] chroot not mounted"
	fi
}

check_mount() {
	# mount dev sys proc
	if mountpoint -q $TARGET/dev/
	then
		echo "[+] chroot mounted"
	else
		echo "[-] mounting chroot..."

		SD_NAME="0"

		for dir in $(ls /run/media/$PWN_USER) 
		do
			if mountpoint -q "/run/media/$PWN_USER/$dir"
			then
				# chroot is located on sdcard
				# remounting the sdcard with suid enabled
				SD_NAME=$dir
			fi
		done

		if [ "$SD_NAME" != "0" ]
		then
			echo "[!] warning $CHROOT_NAME seems located on a partition mounted without suid enabled."
			echo "    we need to remount $SD_NAME with suid enabled in order to proceed."
			echo "[?] remount $SD_NAME with setuid enabled? [y/n]"

			read -p "[>] " SUID_SELECTION

			if [ "$SUID_SELECTION" == "y" ]
			then
				mount -o remount,suid /media/sdcard/$SD_NAME
				echo "[-] sdcard remounted."
				sleep 1
			else
				echo "[-] exit."
				exit 1
			fi

		fi

		# create nemo /run/user directory
		mkdir -p /run/user/1001
		chown -R $PWN_USER:$PWN_USER /run/user/1001

		# dev sys proc
		mount -t proc proc $TARGET/proc/
		mount --rbind --make-rslave /sys $TARGET/sys/
		mount --rbind --make-rslave /dev $TARGET/dev/

		# mount run
		mount --rbind --make-rslave /run $TARGET/run/

		# wayland 
		#mkdir -p $TARGET/run/display
		#mount --rbind --make-rslave /run/display $TARGET/run/display

		# pulseaudio
		mkdir -p $TARGET/run/user/1001/pulse
		mount --bind /run/user/100000/pulse /run/user/1001/pulse

		# dbus
		mkdir -p $TARGET/var/lib/dbus
		#mkdir -p $TARGET/run/dbus
		#mount --rbind --make-rslave /run/dbus $TARGET/run/dbus
		mount --rbind --make-rslave /var/lib/dbus $TARGET/var/lib/dbus

		# mount devpts 
		mount --bind --make-slave /dev/pts $TARGET/dev/pts

		# tmp directory
		mkdir -p /tmp/$CHROOT_NAME/
		chmod 1777 /tmp/$CHROOT_NAME/
		mount --bind --make-slave /tmp/$CHROOT_NAME $TARGET/tmp

		# replace chroot iptables binary with sailfish's iptables
		cp -ar /usr/sbin/iptables $CHROOT_PATH/usr/sbin/iptables

		# copy resolv.conf
		cp /etc/resolv.conf $TARGET/resolv.conf

		echo "[+] done."
		
		sleep 2
	fi
}

update_pwn(){
	# update easy_pwn kali scripts
	# deploy easy pwn
	echo "[-] easy_pwn deploy..."
	mkdir -p $TARGET/opt/easy_pwn
	cp -avr -T $PWN_DIR/deploy/easy_pwn $TARGET/opt/easy_pwn

	# deploy xfce configs
	echo "[-] user configs deploy..."
	mkdir -p $TARGET/home/$PWN_USER/.config
	cp -avr -T $PWN_DIR/deploy/configs $TARGET/home/$PWN_USER/.config

	# fix nemo user home permissions
	echo "[-] fixing permissions..."
	chown -R $PWN_USER:$PWN_USER $TARGET/home/$PWN_USER

	# add execution permissions on /opt/easy_pwn
	chmod +x $TARGET/opt/easy_pwn/setup_desktop.sh
	chmod +x $TARGET/opt/easy_pwn/start_desktop.sh

	# add execution permission on wizard.sh
	chmod +x $PWN_DIR/wizard.sh
}

install_icon(){
	# install .desktop icon on /home/nemo/.local/share/applications
	# overwriting the previous
	echo "[-] installing $CHROOT_NAME.desktop in /home/$PWN_USER/.local/share/applications..."
	sed "s|XX_PWNPATH_XX|$PWN_DIR|g" $PWN_DIR/src/easy_pwn.desktop > /home/$PWN_USER/.local/share/applications/$CHROOT_NAME.desktop
	sed -i "s|XX_NAME_XX|$CHROOT_NAME|g" /home/$PWN_USER/.local/share/applications/$CHROOT_NAME.desktop 
	sed -i "s|XX_CHROOTPATH_XX|$CHROOT_PATH|g" /home/$PWN_USER/.local/share/applications/$CHROOT_NAME.desktop
	sed -i "s|XX_ICON_XX|$PWN_ICON|g" /home/$PWN_USER/.local/share/applications/$CHROOT_NAME.desktop

	sleep 1
}

start_desktop(){
	# start chroot desktop
	DESKTOP_ORIENTATION="p" # default portrait

	if [ "$OR_LANDSCAPE" == true ]
	then
		DESKTOP_ORIENTATION="l"
		# set env on sfos qxcompositor
		#mkdir -p /run/user/1001
		#export $(dbus-launch)
		export XDG_RUNTIME_DIR=/run/user/100000
		# start qxcompositor
		echo "[-] starting qxcompositor..."
		su $PWN_USER -c "qxcompositor --wayland-socket-name ../../display/wayland-1" &

		sleep 3

	fi
		
	# start dbus
	#echo "[-] starting chroot's dbus..."
	#chroot $TARGET /etc/init.d/dbus start

	# run kali-side script
	echo "[-] chrooting..."
	# store chroot output on /tmp/easy_pwn/epwn-session.log
	chroot $TARGET su $PWN_USER -c "/opt/easy_pwn/start_desktop.sh $DESKTOP_ORIENTATION" >> /tmp/$CHROOT_NAME/epwn-session.log 2>&1
}

get_kali(){
	if test -f "/tmp/kalifs-armhf-minimal.tar.xz"
	then
		echo "[+] found kalifs-armhf-minimal.tar.xz, skipping download"
	else
		# download latest kalifs armhf build from nethunter mirrors
		echo "[-] downloading latest kalifs armhf build from nethunter mirrors..."

		# fix for connection issues
		ec=18;
		while [ $ec -ne 0 ] 
		do 
			curl --output /tmp/kalifs-armhf-minimal.tar.xz -O -C - $KALI_IMG 
			ec=$? 
		done
		 
		sleep 1
	fi

	# untar kalifs archive
	echo "[-] unpacking kalifs-armhf-minimal..."
	xz -cd  /tmp/kalifs-armhf-minimal.tar.xz | tar xvf - -C $PR_DIR
	mv $PR_DIR/kali-armhf/ $TARGET/
	sleep 1
}

# check extra args
for i; do 
	case "$i" in
		"--landscape")
			# enable landscape
			OR_LANDSCAPE=true

		;;
		"--root")
			# enable root session
			ROOT_SESSION=true
		;;
	esac
done

case "$ACTION" in
	"create")
		# create a new chroot
		# download and untar kali rootfs
		get_kali

		# deploy easy_pwn scripts on chroot
		update_pwn

		# add desktop launcher
		install_icon

		# mount dev sys proc
		check_mount

		# run setup-desktop on kali-side
		# requires username as first arg
		echo "[-] chrooting..."
		chroot $TARGET /opt/easy_pwn/setup_desktop.sh $PWN_USER
	;;

	"desktop")
		# start kali desktop
		# check mounts
		check_mount

		# start desktop
		start_desktop
	;;
	
	"ssh")
		# start sshd inside chroot
		# listen on: 0.0.0.0:224/tcp
		check_mount

		echo "[-] chrooting..."
		chroot $TARGET /usr/sbin/sshd -p2244

		echo "[+] SSHD enabled on tcp port 2244"
	;;

	"bettercap")
		# start bettercap webui
		# listen on: 127.0.0.1:80/tcp
		check_mount

		echo "[-] chrooting..."
		chroot $TARGET bettercap -caplet http-ui -iface wlan0
	;;

	"shell")
		# start chroot shell
		# mount dev sys proc
		check_mount

		# run kali-side script
		echo "[-] chrooting..."
		chroot $TARGET 
	;;

	"update")
		# deploy easy_pwn
		update_pwn

		# install chroot icon
		install_icon

		echo "[+] done."
	;;

	"kill")
		# experimental
		# kill chroot process
		kill_chroot

		echo "[+] done."
	;;

	"quit")
		# quit chroot
		kill_chroot

		echo "[-] umounting chroot..."
		umount_all

		echo "[+] kali session closed"
		sleep 3
		exit 1
	;;
	"script")
		# execute custom scripts
		# check mount
		check_mount

		# requires 3 args example: 
		# ./easy_pwn.sh script /media/sdcard/sdtest/epwn rougue_ap
		# check args
		if [ "$#" -lt 3 ] 
		then
			echo "[!] script require 3 arguments."
			echo "    usage: $0 script [destination-path] [script_name]" 
			exit 1
		fi

		# get requested script name
		SCRIPT_NAME="$3"

		# check if script main exist
		if [[ -f "$CHROOT_PATH/opt/easy_pwn/scripts/$SCRIPT_NAME/main.sh" ]]
		then
			# execute the script 
			echo "[-] loading $SCRIPT_NAME."
			chmod +x $CHROOT_PATH/opt/easy_pwn/scripts/$SCRIPT_NAME/main.sh

			echo "[-] chrooting..."
			chroot $TARGET /opt/easy_pwn/scripts/$SCRIPT_NAME/main.sh

		else
			echo "[!] script '$SCRIPT_NAME' not found."
		fi

	;;

	*)
		echo "[!] Usage: $0 {create|desktop|shell|update|kill|bettercap|ssh|quit} [kali-rootfs-path]"
		exit 1
esac