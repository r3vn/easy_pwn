# easy_pwn

easy_pwn is a set of automated scripts to setup and run chrooted kali desktop on Sailfish OS devices.

## Screenshots
todo

## Usage

```
easy_pwn.sh [action] [kali-rootfs-path]
```
Currently available actions:

- **create**, it download latest kalifs-armhf from nethunter's repositories,then chroot it and install the following packages :
	- kali-desktop-xfce : kali default DE (undercover mode works too)
	- Xwayland : required to run  X 
	- kali-linux-default : kali default tools metapackage
- **desktop** is meant to set some required environment variables, chroot kali and start xfce desktop
- **shell**, it run chrooted shell session on fingerterm
- **update** is meant to update desktop icons and chroot with latest easy_pwn scripts

## Requirements

 - qxcompositor (https://openrepos.net/content/elros34/qxcompositor), it is required in order to get landscape mode work

## Examples

**Create a kali-chroot**

```
$ git clone https://github.com/r3vn/easy_pwn.git
$ cd easy_pwn
$ devel-su
  (insert root password)
# ./easy_pwn.sh create /media/sdcard/epwn
```

**Start kali desktop**

"create" should create a "yourchrootname".desktop file in your /home/nemo/.local/share/applications/, so you should be able to launch the script directly from sfos's app drawner.
To start the script manually:

```
$ cd easy_pwn
$ devel-su
  (insert root password)
# ./easy_pwn.sh desktop /media/sdcard/epwn
```

**Start kali shell on fingerterm**

```
$ cd easy_pwn
$ devel-su
  (insert root password)
# ./easy_pwn.sh shell /media/sdcard/epwn
```

**Update scripts and icon**
```
$ cd easy_pwn
$ devel-su
  (insert root password)
# ./easy_pwn.sh update /media/sdcard/epwn
```

## todo / known issues

- Audio doesn't work (fix in progress)
- Thunar file manager (kali default) crash the session, anyway nautilus works fine.
- No right click on touch-only devices (long press on nautilus seems to work)(fix in progress)