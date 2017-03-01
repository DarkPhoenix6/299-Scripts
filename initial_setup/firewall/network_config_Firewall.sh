#!/bin/bash
#
######################################################################
#
#	Name:		 	network_config_Firewall.sh
#	Author:			Chris Fedun 17/02/2017
#	Description:	Network Configuration for the Firewall
#
######################################################################
#####Constants#####
host_name=$1
domain_name=$2

function network_config
{

#####IP ADDRESS#####
echo "# interfaces(5) file used by ifup(8) and ifdown(8)

# Please note that this file is written to be used with dhcpcd
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'

# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback
# The primary network interface
auto eth0
allow-hotplug eth0
iface eth0 inet dhcp

# Virtual Internal interface 
up ip addr add 192.168.10.254/24 dev $IFACE label $IFACE:0
down ip addr del 192.168.10.254/24 dev $IFACE label $IFACE:0

allow-hotplug wlan0
iface wlan0 inet manual
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf

allow-hotplug wlan1
iface wlan1 inet manual
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf" > /etc/network/interfaces

#if ! /etc/init.d/networking restart
#then
#	if ! /etc/init.d/networking restart
#	then
#		reboot
#	fi
#fi
}

function change_name
{
echo "$host_name" > /etc/hostname

sed -i "
/127.0.1.1/ c\
127.0.1.1\t$host_name
" /etc/hosts
}
#####Main

network_config
change_name
exit
#######END :) #######