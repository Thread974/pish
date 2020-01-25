#!/bin/bash

if [ "$#" = "2" ] ; then
	IFACEINET=$1
	IFACELOCAL=$2
elif expr $(basename $0) : "share-.*-.*\.sh" ; then
	IFACEINET=$(expr $(basename $0) : "share-\(.*\)-.*\.sh")
	IFACELOCAL=$(expr $(basename $0) : "share-.*-\(.*\)\.sh")
else
	echo "usage: $0 <if_inet> <if_lan>"
	exit 1
fi

# On pi, reduce wlan MTU to avoid a connection stall problem
# https://www.raspberrypi.org/forums/viewtopic.php?f=28&t=1194o83
if [ -f /boot/LICENCE.broadcom ] ; then
	PLATFORM=raspberrypi
fi
if [ "$PLATFORM" = "raspberrypi" -a "$IFACEINET" = "wlan0" ] ; then
	sudo ifconfig $INET mtu 500 up
fi

# Setup ip forwarding (do not setup multiple times)
FORWARD=$(cat /proc/sys/net/ipv4/ip_forward)
if [ "$FORWARD" = "0" ] ; then
	sudo ip addr add 10.1.1.2/16 dev $IFACELOCAL
	sudo ip link set $IFACELOCAL up

	# start a dedicated dnsmasq instance
	sudo apt install dnsmasq-base ||:
	sudo dnsmasq -d -i $IFACELOCAL -z -F "10.1.1.12,10.1.1.15,255.255.0.0,10.1.255.255" &

	echo "Enabling ip forwarding from $IFACENET to $IFACELOCAL"
	echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null
	sudo iptables -A FORWARD -o $IFACELOCAL -j ACCEPT
	sudo iptables -t nat -A POSTROUTING -o $IFACEINET -j MASQUERADE
else
	echo "Disabling ip forwarding from $IFACENET to $IFACELOCAL"
	echo 0 | sudo tee /proc/sys/net/ipv4/ip_forward > /dev/null
	sudo iptables -D FORWARD -o $IFACELOCAL -j ACCEPT
	sudo iptables -t nat -D POSTROUTING -o $IFACEINET -j MASQUERADE

	sudo killall dnsmasq

	sudo ip addr del 10.1.1.2/16 dev $IFACELOCAL
fi


