#!/bin/bash
#
######################################################################
#
#	Name:		 	ip_address_mail.sh
#	Author:			Chris Fedun 15/02/2017
#	Description:	IP Configuration script Configuration
#
#	Copyright (C) 2017  Christopher Fedun
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.
######################################################################
Setup_dir='/root/initial_setup/mail/'
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
$Setup_dir\change_hosts.sh
if ! /etc/init.d/networking restart
then
	if ! /etc/init.d/networking restart
	then
		reboot
	fi
fi
exit
#######END :) #######