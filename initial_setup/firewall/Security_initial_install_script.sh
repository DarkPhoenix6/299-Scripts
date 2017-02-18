#!/bin/bash
#
######################################################################
#
#	Name:		 	Security_initial_install_script.sh
#	Author:			Chris Fedun 06/02/2017
#	Description:	install script Configuration
#
######################################################################
#####Constants#####
export DEBIAN_FRONTEND=noninteractive
domain_name=$1
Setup_dir='/root/initial_setup/'
First_boot="/var/log/firstboot.log"
Second_boot="/var/log/secondboot.log"
function FB_install
{
#####install#####
apt-get install -y -q debconf-utils sudo
apt-get install pwgen curl git -y -q

#####New user
adduser --disabled-login --quiet --gecos "" nonroot
adduser --disabled-login --quiet --gecos "" server_admin 
adduser server_admin sudo
}

#####deb_conf#####
debconf-set-selections <<< "openssh-server  openssh-server/permit-root-login        boolean true"



#####Main
#####UPDATE#####
apt-get update -q
apt-get upgrade -y -q

if [ ! -f $First_boot ]; then
	touch $First_boot
	FB_install
	network_config_Firewall.sh
	$Setup_dir\iptables_Firewall.sh
	raspi-config --expand-rootfs
	reboot
	
	exit

elif [ -f $First_boot && ! -f $Second_boot ]; 
	touch $Second_boot
	
	
else
	exit
fi
exit
#######END :) #######


