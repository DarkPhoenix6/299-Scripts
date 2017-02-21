#!/bin/bash
#
######################################################################
#
#	Name:		 	ip_address_mail.sh
#	Author:			Chris Fedun 15/02/2017
#	Description:	IP Configuration script Configuration
#
######################################################################
Setup_dir='/root/initial_setup/mail/'
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

# The secondary network interface
auto eth1
allow-hotplug eth1
iface eth0 inet static
address 192.168.10.253
netmask 255.255.255.0
gateway 192.168.10.254
broadcast 192.168.10.255
network 192.168.10.0
dns-nameservers 8.8.8.8 8.8.4.4


allow-hotplug wlan0
iface wlan0 inet manual" > /etc/network/interfaces

}

#####Main

network_config
$Setup_dir\change_hosts.sh $host_name $domain_name
if ! /etc/init.d/networking restart
then
	if ! /etc/init.d/networking restart
	then
		reboot
	fi
fi
exit
#######END :) #######