#!/bin/bash
#
######################################################################
#
#	Name:		 	initial_install_script.sh
#	Author:			Chris Fedun 18/01/2017
#	Description:	install script Configuration
#
######################################################################
#####Constants#####

host_name=$1
domain_name=$2
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

echo mysql-server-5.5 mysql-server/root_password password $SQL_root_passwd | debconf-set-selections
echo mysql-server-5.5 mysql-server/root_password_again password $SQL_root_passwd | debconf-set-selections
echo postfix postfix/protocols       select  all | debconf-set-selections
echo postfix postfix/chattr  boolean false | debconf-set-selections
echo postfix postfix/recipient_delim string  + | debconf-set-selections
echo postfix postfix/mynetworks      string  127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 | debconf-set-selections
echo postfix postfix/rfc1035_violation       boolean false | debconf-set-selections
echo postfix postfix/mailname        string  $domain_name | debconf-set-selections
echo postfix postfix/main_mailer_type        select  Internet Site | debconf-set-selections
echo postfix postfix/procmail        boolean true | debconf-set-selections
echo postfix postfix/mailbox_limit   string  0 | debconf-set-selections
echo postfix postfix/destinations    string  $domain_name, localhost.com, , localhost | debconf-set-selections



debconf-set-selections <<< "phpmyadmin phpmyadmin/setup-password       password $PHPMyAdmin_setup_passwd"
debconf-set-selections <<< "phpmyadmin phpmyadmin/password-confirm     password $PHPMyAdmin_setup_passwd"
debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PHPMyAdmin_user_passwd"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass     password $SQL_root_passwd"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass       password $PHPMyAdmin_user_passwd"
debconf-set-selections <<< "phpmyadmin phpmyadmin/database-type        select  mysql"
debconf-set-selections <<< "phpmyadmin phpmyadmin/setup-username       string  admin"
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install     boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/internal/skip-preseed        boolean false"
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-upgrade     boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-user     string  root"
debconf-set-selections <<< "phpmyadmin phpmyadmin/upgrade-backup       boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/db/dbname    string  phpmyadmin"
debconf-set-selections <<< "phpmyadmin phpmyadmin/db/app-user  string  phpmyadmin"
debconf-set-selections <<< "phpmyadmin phpmyadmin/purge        boolean false"
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-reinstall   boolean false"
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
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

##### PHP #####
echo "[+] Installing PHP..."
apt-get install php5 php-pear php5-mysql -y -q

##### MYSQL Database Setup #####
echo "[+] Setting up MYSQL Database..."
bash -x $Setup_dir\MYSQL/MYSQL_db_setup_script.sh $domain_name

##### Install BIND #####
#apt-get install bind9 bind9utils bind9-doc dnsutils -y -q
##### Postfix #####
echo "[+] Installing Postfix..."
apt-get install -q -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" postfix postfix-mysql
apt-get --purge remove 'exim4*' -y -q
apt-get install spamassassin spamass-milter -y -q
apt-get install swaks -y -q

##### Dovecot #####
echo "[+] Installing Dovecot..."
apt-get install dovecot-mysql dovecot-pop3d dovecot-imapd dovecot-managesieved dovecot-lmtpd -y -q

##### Roundcube #####
echo "[+] Installing Roundcube..."
export DEBIAN_FRONTEND=dialog
expect $Setup_dir\webmail/RoundCube.exp $SQL_root_passwd
export DEBIAN_FRONTEND=noninteractive

##### PHPMyAdmin #####
echo "[+] Installing PHPMyAdmin..."
apt-get install -q -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" phpmyadmin 

##### Certificate Setup #####
echo "[+] Configuring Certificates..."
bash -x $Setup_dir\Certificate.sh $domain_name

##### Apache Setup #####
echo "[+] Configuring Apache..."
bash -x $Setup_dir\webmail/Apache_config.sh $domain_name

##### Postfix Setup #####
echo "[+] Configuring Postfix..."
bash -x $Setup_dir\email/Postfix_setup_script.sh $domain_name


##### Dovecot Setup #####
echo "[+] Configuring Dovecot..."
bash -x $Setup_dir\email/Dovecot_setup_script.sh $domain_name

##### Install Drupal #####
echo "[+] Installing Drupal Dependicies..."
bash -x $Setup_dir\drupal/Drupal_setup.sh $domain_name

##### SpamAssassin #####
echo "[+] Configuring SpamAssassin..."
bash -x $Setup_dir\email/SpamAssassin.sh $domain_name

##### OpenDKIM #####
echo "[+] Configuring OpenDKIM..."
bash -x $Setup_dir\email/OpenDKIM.sh $domain_name

##### Roundcube Setup #####
echo "[+] Configuring Roundcube..."
bash -x $Setup_dir\webmail/RoundCube_config.sh $domain_name
}
#####Main
export DEBIAN_FRONTEND=noninteractive
if [ ! -f $First_boot ]; then
	touch $First_boot
#	bash $Setup_dir\ip_address_mail.sh
	bash -x /root/initial_setup/ip_address_mail_deb_test.sh $host_name $domain_name
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