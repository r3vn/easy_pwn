#!/bin/bash
# easy_pwn : setup kali desktop

echo "(chroot) [-] updating repositories..."
apt update
sleep 1

echo "(chroot) [-] installing kali desktop, default tools and matchbox's virtual keyboard..."
apt install -y kali-desktop-xfce xwayland matchbox-keyboard kali-linux-default
sleep 1

echo "(chroot) [-] cleaning apt cache..."
apt clean

echo "(chroot) [+] done! kali chroot is ready to use."
echo "(chroot) [+] Run 'easy_pwn destkop [kalifs-path]' to start the kali desktop, or"
echo "(chroot) [+] Run 'easy_pwn shell [kalifs-path]' to get the kali shell on fingerterm"
