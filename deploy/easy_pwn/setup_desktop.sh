#!/bin/bash
# easy_pwn : setup kali desktop

# get user
PWN_USER=$1

# add user 
echo "(chroot) [-] adding $PWN_USER user..."
adduser -u 100000 $PWN_USER
cp -avr /etc/skel/.* /home/$PWN_USER/
chown -R $PWN_USER:$PWN_USER /home/$PWN_USER
usermod -aG sudo,inet,input,audio,users,video $PWN_USER

# refresh apt
echo "(chroot) [-] updating repositories..."
apt update
sleep 1

# install packages
echo "(chroot) [-] installing packages (it will take a while)..."	
# 1st line is for desktop stuff
# 2nd line for kali-linux metapackages
# 3rd line for easy_pwn additional tools
apt install -y kali-desktop-xfce xwayland matchbox-keyboard mousetweaks connman-gtk \
				kali-linux-nethunter \
				bettercap bettercap-ui     
sleep 1

# clean apt
echo "(chroot) [-] cleaning apt cache..."
apt clean

# fixing sudo warnings
echo -e "127.0.0.1\tSailfish" >> /etc/hosts

# done
echo "(chroot) [+] done! kali chroot is ready to use."
echo "(chroot) [+] Run 'easy_pwn destkop [kalifs-path]' to start the kali desktop, or"
echo "(chroot) [+] Run 'easy_pwn shell [kalifs-path]' to get the kali shell on fingerterm"
