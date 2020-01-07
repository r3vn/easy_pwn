# easy_pwn

easy_pwn is a set of automated scripts designed to setup and run kali linux's chroot environment on Sailfish OS devices.
It allows to run a full-kali desktop (xfce4) on Xwayland with touch screen support (even undercover mode works), without VNC or other ugly stuff behind.
Currently a rogue access point script is implemented, feel free to contribute.

## Usage

```
easy_pwn.sh [action] [kali-rootfs-path] 
```
available actions:

- **create** download latest kalifs-armhf from nethunter's repositories, mount it,then install the following packages :
	- kali-desktop-xfce : kali default DE (undercover mode works too)
	- Xwayland : required to run X 
	- kali-linux-nethunter : nethunter's default tools metapackage
	- mousetweaks : for touch right-click attempt
	- matchbox-keyboard : default virtual keyboard
	- bettercap and bettercap-ui
- **script** let you run custom scripts, default available scripts are:
	- rogue_ap : set up an open access point, redirect traffic from wlan to mobile data and attach bettercap
- **desktop** set some required environment variables, chroot kali and start xfce desktop
- **shell** run chrooted shell session on fingerterm
- **update** update desktop icons and chroot with latest easy_pwn scripts
- **ssh** start a ssh server inside the chroot on port 2244
- **bettercap** start bettercap web-ui on 127.0.0.1
- **kill** kills all chroot processes
- **quit** umount chroot


## Requirements

 - qxcompositor (https://openrepos.net/content/elros34/qxcompositor), it is required by desktop landscape mode

## Screenshots

<p align="center">
	<img src="https://user-images.githubusercontent.com/635790/71604582-3a69f280-2b63-11ea-99f5-c48b5a849bf8.jpg" width="425px"> <img src="https://user-images.githubusercontent.com/635790/71604584-3a69f280-2b63-11ea-8d90-bcd404ea3de4.jpg" width="425px">
	<img src="https://user-images.githubusercontent.com/635790/71497108-0aff7100-2857-11ea-9b95-977d9ccb8adf.jpg" width="425px"> <img src="https://user-images.githubusercontent.com/635790/71497196-692c5400-2857-11ea-9b7c-25bd8d5eb6bb.jpg" width="425px">
</p>

## Examples

**create a kali-chroot**

```
$ git clone https://github.com/r3vn/easy_pwn.git
$ cd easy_pwn
$ devel-su
  (insert root password)
# ./easy_pwn.sh create /media/sdcard/sdname/chrootname
```

**start kali desktop**

After the "create" process, an icon called "chrootname" should appaer on sfos's app drawer, so the script can be executed directly from sfos as a normal application.

To start the script manually:
```
# ./easy_pwn.sh desktop /media/sdcard/sdname/chrootname
```

**start kali shell on fingerterm**

```
# ./easy_pwn.sh shell /media/sdcard/sdname/chrootname
```
It is also possible to start a desktop session, in portrait mode, from the shell by running "/opt/easy_pwn/start_desktop.sh" script.

**update scripts and icon**

It is strongly recommanded to update the chroot after an easy_pwn upgrade
```
# ./easy_pwn.sh update /media/sdcard/sdname/chrootname
```

**run rogue_ap script**

Make sure to have mobile data enabled and wifi enabled and not connected to any access point before proceed.
```
# ./easy_pwn.sh script /media/sdcard/sdname/chrootname rogue_ap
```


## todo / known issues

- ~~Audio doesn't work (fix in progress)~~
- included in the script ~~if your chroot is located under an external sdcard, you may need to remount the sd partition with suid enabled as follows~~
	```
	# mount -o remount,suid /media/sdcard/your-partition-name
	```
- Thunar file manager (kali default) crash the session, anyway nautilus works fine.
- mousetweaks longpress works with long double tab ~~No right click on touch-only devices (long press on nautilus seems to work)(fix in progress)~~
- "--root" on desktop mode to start a root session (without sound)
- firefox-esr tabs crash with sounds however chromium works very well
- multiarch support
- done. ~~custom scripts~~