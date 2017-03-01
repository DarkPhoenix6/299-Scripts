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
domain_name=$2
host_name=$1
Setup_dir='/root/initial_setup/firewall/'
First_boot="/var/log/firstboot.log"
Second_boot="/var/log/secondboot.log"
function FB_install
{
echo "
#

# deb cdrom:[Debian GNU/Linux 8.7.1 _Jessie_ - Official amd64 NETINST Binary-1 20170116-10:57]/ jessie main

#deb cdrom:[Debian GNU/Linux 8.7.1 _Jessie_ - Official amd64 NETINST Binary-1 20170116-10:57]/ jessie main

deb http://mirror.it.ubc.ca/debian/ jessie main
deb-src http://mirror.it.ubc.ca/debian/ jessie main

deb http://security.debian.org/ jessie/updates main
deb-src http://security.debian.org/ jessie/updates main

# jessie-updates, previously known as 'volatile'
deb http://mirror.it.ubc.ca/debian/ jessie-updates main
deb-src http://mirror.it.ubc.ca/debian/ jessie-updates main" >> /etc/apt/sources.list
#####install#####
apt-get install -y -q debconf-utils sudo
pwgen curl git -y -q
apt
#####New user
adduser --disabled-login --quiet --gecos "" nonroot
adduser --disabled-login --quiet --gecos "" server_admin 
adduser server_admin sudo
}

#####deb_conf#####
#debconf-set-selections <<< "openssh-server  openssh-server/permit-root-login        boolean true"



#####Main
#####UPDATE#####
apt-get update -q
apt-get upgrade -y -q

export DEBIAN_FRONTEND=noninteractive
if [ ! -f $First_boot ]; then
	touch $First_boot
#	bash $Setup_dir\ip_address_mail.sh
	bash -x $Setup_dir\network_config_Firewall.sh $host_name $domain_name
	FB_install
	
	#raspi-config --expand-rootfs
	reboot
	#touch $Second_boot
	#Second_boot_install
	exit
elif [ -f $First_boot ] && [ ! -f $Second_boot ]; then
	touch $Second_boot
	Second_boot_install
	sed -i "
	/exit 0/ i\
	bash $Setup_dir\iptables_Firewall.sh
	" /etc/rc.local
else
	exit
fi
exit
#######END :) #######


