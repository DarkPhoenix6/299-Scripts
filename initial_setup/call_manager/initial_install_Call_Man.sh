#!/bin/bash
#
######################################################################
#
#	Name:		 	initial_install_Call_Man.sh
#	Author:			Chris Fedun 23/02/2017
#	Description:	install script Configuration
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

Setup_dir='/root/initial_setup/call_manager/'
First_boot="/var/log/firstboot.log"
Second_boot="/var/log/secondboot.log"
Third_boot="/var/log/thirdboot.log"
Fourth_boot="/var/log/fourthboot.log"
##### Functions #####
function Second_boot_install 
{
#echo "
##
#
## deb cdrom:[Debian GNU/Linux 8.7.1 _Jessie_ - Official amd64 NETINST Binary-1 20170116-10:57]/ jessie main
#
##deb cdrom:[Debian GNU/Linux 8.7.1 _Jessie_ - Official amd64 NETINST Binary-1 20170116-10:57]/ jessie main
#
#deb http://mirror.it.ubc.ca/debian/ jessie main
#deb-src http://mirror.it.ubc.ca/debian/ jessie main
#
#deb http://security.debian.org/ jessie/updates main
#deb-src http://security.debian.org/ jessie/updates main
#
## jessie-updates, previously known as 'volatile'
#deb http://mirror.it.ubc.ca/debian/ jessie-updates main
#deb-src http://mirror.it.ubc.ca/debian/ jessie-updates main" >> /etc/apt/sources.list

##### Add Jessie Backports #####
echo 'deb http://http.debian.net/debian jessie-backports main' > /etc/apt/sources.list.d/jessie-backports.list
#####UPDATE#####

apt-get update -q
apt-get upgrade -y -q
apt-get dist-upgrade -y -q

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
debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v4 boolean true"
debconf-set-selections <<< "iptables-persistent iptables-persistent/autosave_v6 boolean true"
touch /root/.my.cnf
echo '[client]' >> /root/.my.cnf
echo "password=$SQL_root_passwd" >> /root/.my.cnf
chmod u=rw,go= /root/.my.cnf

touch $Setup_dir\MYSQL/pass.txt
echo "$SQL_root_passwd" >> $Setup_dir\MYSQL/pass.txt
chmod u=rw,go= $Setup_dir\MYSQL/pass.txt


##### OpenSSH/OpenSSL#####

apt-get install -y -q ssh openssl openssh-server openssh-client 

##### Certificate Setup #####
echo "[+] Configuring Certificates..."
bash -x $Setup_dir\Certificate.sh "$host_name" "$domain_name" "$Country" "$State" "$City" "$OrgName" "$OU" "$User_Name"

##### NTP #####
apt-get install ntp ntpdate -y -q
timedatectl set-timezone America/Vancouver
##### Apache and MYSQL Install #####
echo "[+] Installing Apache..."
#apt-get update -q 1> /dev/null
echo "[+] Installing MYSQL..."
apt-get install -q -y -o Dpkg::Options::="--force-confdef" \
-o Dpkg::Options::="--force-confold" apache2 mysql-server

##### PHP #####
echo "[+] Installing PHP..."
apt-get install php5 php-pear php5-mysql -y -q
}

function third_boot_config
{
##### MYSQL Database Setup #####
echo "[+] Setting up MYSQL Database..."
#bash -x $Setup_dir\MYSQL/MYSQL_db_setup_script.sh $domain_name

##### Asterisk Dependicies #####
apt-get install build-essential subversion \
	libssl-dev libxml2-dev vim-nox gcc \
	linux-headers-`uname -r` libncurses5-dev libncursesw5-dev \
	mysql-client bison flex php5-curl php5-gd curl sox \
	libmysqlclient-dev mpg123 libnewt-dev sqlite3 \
	libsqlite3-dev pkg-config automake libtool autoconf git \
	unixodbc-dev uuid uuid-dev libasound2-dev libogg-dev \
	libvorbis-dev  libtool-bin libical-dev libneon27-dev \
	libsrtp0-dev autotools-dev libspandsp-dev sudo libmyodbc \
	libusb-dev libeditline-dev libedit-dev \
	tftpd chkconfig libcurl4-gnutls-dev xinetd \
	e2fsprogs dbus xmlstarlet unixodbc python-minimal \
	python-tk python-doc libpython-stdlib python-sphinx \
	python-docutils debhelper dh-python python-all \
	python-setuptools libpython-all-dev libpython-all-dbg \
	python-pip ipcalc -y -q


#apt-get install g++
#apt-get install libncurses-dev
#apt-get install uuid-dev
#apt-get install libjansson-dev libcurl4-openssl-dev
#apt-get install libxml2-dev postfix mailutils
#apt-get install libsqlite3-dev libcurl4-gnutls-dev
pear install Console_Getopt
}

function fourth_boot_config
{
##### Install Asterisk ##### 
bash -x $Setup_dir\Asterisk_install.sh $host_name $domain_name "true"

##### Install BIND #####
#apt-get install bind9 bind9utils bind9-doc dnsutils -y -q


##### Firewall #####
echo "[+] Configuring Firewall..."
bash -x $Setup_dir\iptables_callMan.sh

##### Persistent Firewall #####
echo "[+] Configuring Persistent Firewall..."

apt-get -q -y -o Dpkg::Options::="--force-confdef" \
-o Dpkg::Options::="--force-confold" install iptables-persistent

##### Fail2Ban
apt-get install -y -q fail2ban
bash -x $Setup_dir\Fail2Ban/Fail2Ban_callman.sh

##### PSAD
apt-get -y -q install psad
bash -x $Setup_dir\PSAD.sh $domain_name $host_name

##### Secure MYSQL
expect $Setup_dir\MYSQL/mysql_secure.exp $SQL_root_passwd
}


#####Main
export DEBIAN_FRONTEND=noninteractive
if [ ! -f $First_boot ]; then

	touch $First_boot
	####Use only if ip address is NOT set by dhcp
#	bash $Setup_dir\ip_address_mail.sh
#	bash -x $Setup_dir\ip_address_call_man_deb_test.sh $host_name $domain_name
#	FB_install
	
	#raspi-config --expand-rootfs
#	reboot
	#touch $Second_boot
	#Second_boot_install
	touch $Second_boot
	Second_boot_install
	touch $Third_boot
	third_boot_config
	touch $Fourth_boot
	fourth_boot_config
	reboot
	exit
elif [ -f $First_boot ] && [ ! -f $Second_boot ]; then
	touch $Second_boot
	Second_boot_install
	root_db_pass=$( cat $Setup_dir\MYSQL/pass.txt )
	touch $Third_boot
	third_boot_config
	touch $Fourth_boot
	fourth_boot_config
	reboot
elif [ -f $First_boot ] && [ -f $Second_boot ] && [ ! -f $Third_boot ]; then
	root_db_pass=$( cat $Setup_dir\MYSQL/pass.txt )
	touch $Third_boot
	third_boot_config
	touch $Fourth_boot
	fourth_boot_config
	reboot
elif [ -f $First_boot ] && [ -f $Second_boot ] && [ -f $Third_boot ] && [ ! -f $Fourth_boot ]; then
	root_db_pass=$( cat $Setup_dir\MYSQL/pass.txt )
	touch $Fourth_boot
	fourth_boot_config
	reboot
	exit
#elif [ -f $First_boot ] && [ -f $Second_boot ] && [ ! -f $Third_boot ]; then	
	#touch $Third_boot
	#third_boot_config
else
	exit
fi


exit
####### END :) #######