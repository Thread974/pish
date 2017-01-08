#!/bin/bash

IFACEINET=wlan0
IFACELOCAL=eth0

# Reduce wlan MTU to avoid a connection stall problem
# https://www.raspberrypi.org/forums/viewtopic.php?f=28&t=119483
sudo ifconfig wlan0 mtu 500 up

sudo ip addr add 10.1.1.2/16 dev $IFACELOCAL
sudo ip link set $IFACELOCAL up

# start a dedicated dnsmasq instance
sudo service dnsmasq stop
sudo dnsmasq -d -i $IFACELOCAL -z -F "10.1.1.12,10.1.1.15,255.255.0.0,10.1.255.255" &

# Setup ip forwarding (do not setup multiple times)
FORW=$(cat /proc/sys/net/ipv4/ip_forward)
if [ "$FORW" = "0" ] ; then
	echo "Enabling ip forwarding to $IFACEINET"
	echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
	sudo iptables -t nat -A POSTROUTING -o $IFACEINET -j MASQUERADE 
else
	echo 
fi


