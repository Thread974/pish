#!/bin/bash

IFACEINET=wlan0
IFACELOCAL=eth0

# start a dedicated dnsmasq instance
sudo killall dnsmasq
sudo service dnsmasq start

# Setup ip forwarding (do not setup multiple times)
FORW=$(cat /proc/sys/net/ipv4/ip_forward)
if [ "$FORW" = "1" ] ; then
	echo "Disabling ip forwarding to $IFACEINET"
	echo 0 | sudo tee /proc/sys/net/ipv4/ip_forward
	sudo iptables -t nat -D POSTROUTING -o $IFACEINET -j MASQUERADE 
else
	echo "No ip forwarding configured"
fi


