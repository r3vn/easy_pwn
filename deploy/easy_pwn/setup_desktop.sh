#!/bin/bash
# easy_pwn : setup kali desktop

# add user 
echo "(chroot) [-] adding nemo user..."
adduser -u 100000 nemo
cp -avr /etc/skel/.* /home/nemo/
chown -R nemo:nemo /home/nemo
usermod -aG sudo,inet,input,audio,users,video nemo

# refresh apt
echo "(chroot) [-] updating repositories..."
apt update
sleep 1

# install packages
echo "(chroot) [-] installing kali desktop, default tools and matchbox's virtual keyboard..."
apt install -y kali-desktop-xfce xwayland matchbox-keyboard mousetweaks kali-linux-default
sleep 1

# clean apt
echo "(chroot) [-] cleaning apt cache..."
apt clean

# fixing sudo warning
echo -e "127.0.0.1\tSailfish" >> /etc/hosts

# done
echo "(chroot) [+] done! kali chroot is ready to use."
echo "(chroot) [+] Run 'easy_pwn destkop [kalifs-path]' to start the kali desktop, or"
echo "(chroot) [+] Run 'easy_pwn shell [kalifs-path]' to get the kali shell on fingerterm"
