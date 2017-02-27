#!/bin/bash
#
######################################################################
#
#	Name:		 	<Script Name>
#	Author:			Chris Fedun 23/02/2017
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

Setup_dir='/root/initial_setup/call_manager/'
First_boot="/var/log/firstboot.log"
Second_boot="/var/log/secondboot.log"
##### Functions #####
function Second_boot_install 
{

#####UPDATE#####
apt-get update -q
apt-get upgrade -y -q

#####install#####
apt-get install -y -q debconf-utils sudo automake \
pwgen curl php5-cli git quotatool expect 

SQL_root_passwd=$(pwgen -s 20 1)

#####New user
adduser --disabled-login --quiet --gecos "" nonroot
adduser --disabled-login --quiet --gecos "" server_admin 
adduser server_admin sudo
adduser www-data staff
#usermod  
#####deb_conf#####
debconf-set-selections <<< "openssh-server  openssh-server/permit-root-login        boolean true"
debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password password $SQL_root_passwd"
debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password_again password $SQL_root_passwd"

touch /root/.my.cnf
echo '[client]' >> /root/.my.cnf
echo "password=$SQL_root_passwd" >> /root/.my.cnf
chmod u=rw,go= /root/.my.cnf

touch $Setup_dir\MYSQL/pass.txt
echo "$SQL_root_passwd" >> $Setup_dir\MYSQL/pass.txt
chmod u=rw,go= $Setup_dir\MYSQL/pass.txt



echo 'deb http://http.debian.net/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list
apt-get update -q 1> /dev/null
apt-get dist-upgrade -y -q 
##### OpenSSH/OpenSSL#####

apt-get install -y -q ssh openssl openssh-server openssh-client 

##### NTP #####
apt-get install ntp ntpdate -y -q
timedatectl set-timezone America/Vancouver
##### Apache and MYSQL Install #####
echo "[+] Installing Apache..."
apt-get update -q 1> /dev/null
echo "[+] Installing MYSQL..."
apt-get install -q -y -o Dpkg::Options::="--force-confdef" \
-o Dpkg::Options::="--force-confold" apache2 mysql-server

##### PHP #####
echo "[+] Installing PHP..."
apt-get install php5 php-pear php5-mysql -y -q

##### MYSQL Database Setup #####
echo "[+] Setting up MYSQL Database..."
#bash -x $Setup_dir\MYSQL/MYSQL_db_setup_script.sh $domain_name

##### Asterisk Dependicies #####
apt-get install build-essential subversion \
	libssl-dev libxml2-dev vim-nox gcc \
	linux-headers-`uname -r` libncurses5-dev libncursesw5-dev \
	mysql-client bison flex php5-curl php5-gd curl sox \
	libmysqlclient-dev mpg123 libnewt-dev sqlite3 \
	libsqlite3-dev pkg-config automake libtool autoconf git unixodbc-dev uuid uuid-dev \
	libasound2-dev libogg-dev libvorbis-dev  \
	libical-dev libneon27-dev libsrtp0-dev \
	libspandsp-dev sudo libmyodbc libusb-dev libeditline-dev libedit-dev \
	tftpd chkconfig libcurl4-gnutls-dev \
	xinetd e2fsprogs dbus xmlstarlet unixodbc -y -q


#apt-get install g++
#apt-get install libncurses-dev
#apt-get install uuid-dev
#apt-get install libjansson-dev libcurl4-openssl-dev
#apt-get install libxml2-dev postfix mailutils
#apt-get install libsqlite3-dev libcurl4-gnutls-dev
pear install Console_Getopt

##### Install Asterisk ##### 
bash -x $Setup_dir\Asterisk_install.sh

##### Install BIND #####
#apt-get install bind9 bind9utils bind9-doc dnsutils -y -q


##### Firewall #####
echo "[+] Configuring Firewall..."
#bash -x $Setup_dir\iptables_mail.sh
}
#####Main
export DEBIAN_FRONTEND=noninteractive
if [ ! -f $First_boot ]; then
	touch $First_boot
#	bash $Setup_dir\ip_address_mail.sh
	bash -x $Setup_dir\ip_address_call_man_deb_test.sh $host_name $domain_name
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