#!/bin/bash
#
######################################################################
#
#	Name:		 	<Script Name>
#	Author:			Chris Fedun <Date>
#	Description:	<description> 
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
##### Constants #####
host_name=$1
domain_name=$2
Country=$3
State=$4
City=$5
OrgName=$6
OU=$7
User_Name=$8
Setup_dir='/root/initial_setup/mail/'
First_boot="/var/log/firstboot.log"
Second_boot="/var/log/secondboot.log"
##### Functions #####
function Second_boot_install 
{

#####UPDATE#####
apt-get update -q
apt-get upgrade -y -q

#####install#####
apt-get install -y -q debconf-utils sudo
apt-get install pwgen curl php5-cli git quotatool expect -y -q

SQL_root_passwd=$(pwgen -s 20 1)
PHPMyAdmin_user_passwd=$(pwgen -s 20 1)
PHPMyAdmin_setup_passwd=$(pwgen -s 20 1)
#####New user
adduser --disabled-login --quiet --gecos "" nonroot
adduser --disabled-login --quiet --gecos "" server_admin 
adduser server_admin sudo
adduser www-data staff
#usermod  
#####deb_conf#####
debconf-set-selections <<< "openssh-server  openssh-server/permit-root-login        boolean true"


touch /root/.my.cnf
echo '[client]' >> /root/.my.cnf
echo "password=$SQL_root_passwd" >> /root/.my.cnf
chmod u=rw,go= /root/.my.cnf

touch $Setup_dir\MYSQL/pass.txt
echo "$SQL_root_passwd" >> $Setup_dir\MYSQL/pass.txt
chmod u=rw,go= $Setup_dir\MYSQL/pass.txt

touch $Setup_dir\PHPMyAdmin.txt
echo "$PHPMyAdmin_user_passwd" >> $Setup_dir\PHPMyAdmin.txt
chmod u=rw,go= $Setup_dir\PHPMyAdmin.txt

touch $Setup_dir\PHPMyAdmin-setup_password.txt
echo "$PHPMyAdmin_setup_passwd" >> $Setup_dir\PHPMyAdmin-setup_password.txt
chmod u=rw,go= $Setup_dir\PHPMyAdmin-setup_password.txt

echo 'deb http://http.debian.net/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list
apt-get update -q 1> /dev/null
apt-get dist-upgrade -y -q 
##### OpenSSH/OpenSSL/OpenDKIM #####

apt-get install -y -q ssh openssl openssh-server openssh-client opendkim opendkim-tools 

##### NTP #####
apt-get install ntp ntpdate -y -q
##### Apache and MYSQL Install #####
echo "[+] Installing Apache..."
apt-get update -q 1> /dev/null
echo "[+] Installing MYSQL..."
apt-get install -q -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" apache2 mysql-server


##### MYSQL Database Setup #####
echo "[+] Setting up MYSQL Database..."
bash -x $Setup_dir\MYSQL/MYSQL_db_setup_script.sh $domain_name

##### Install BIND #####
#apt-get install bind9 bind9utils bind9-doc dnsutils -y -q

##### Certificate Setup #####
echo "[+] Configuring Certificates..."
bash -x $Setup_dir\Certificate.sh $host_name $domain_name $Country $State $City "$OrgName" $OU $User_Name

##### Apache Setup #####
echo "[+] Configuring Apache..."
bash -x $Setup_dir\webmail/Apache_config.sh $domain_name

##### Firewall #####
echo "[+] Configuring Firewall..."
bash -x $Setup_dir\iptables_mail.sh
}
#####Main
export DEBIAN_FRONTEND=noninteractive
if [ ! -f $First_boot ]; then
	touch $First_boot
#	bash $Setup_dir\ip_address_mail.sh
	bash -x $Setup_dir\ip_address_CC_deb_test.sh $host_name $domain_name
#	FB_install
	
#	raspi-config --expand-rootfs
#	reboot
	touch $Second_boot
	Second_boot_install
	exit
elif [ -f $First_boot ] && [ ! -f $Second_boot ]; then
	touch $Second_boot
	Second_boot_install
else
	exit
fi


exit
####### END :) #######