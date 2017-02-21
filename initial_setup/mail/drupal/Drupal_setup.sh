#!/bin/bash
#
######################################################################
#
#	Name:		 	Drupal_setup.sh
#	Author:			Chris Fedun 26/01/2017
#	Description:	Drupal Setup script Configuration
##http://drupal.stackexchange.com/questions/162061/how-to-install-drush-8-properly-on-debian-8
######################################################################
#####Constants#####
domain_name=$1
root_db_pass=$( cat $Setup_dir\MYSQL/pass.txt )
drupal_admin_passwd=$(pwgen -s 25 1)
Setup_dir='/root/initial_setup/mail/'
SRC=/usr/local/src
WEBROOT=/var/www/drupal

touch $Setup_dir\drupal/drupal_Admin_passwd.txt
echo "$drupal_admin_passwd" >> $Setup_dir\drupal/drupal_Admin_passwd.txt
chmod u=rw,go= $Setup_dir\drupal/drupal_Admin_passwd.txt

chown -R www-data:www-data /var/www/
echo "[+] Installing Composer..."
sudo bash -x $Setup_dir\drupal/composer_install.sh $domain_name
echo "[+] Installing Drush..."
sudo bash -x $Setup_dir\drupal/Drush_install.sh $domain_name

# download latest drupal8 and install
echo "[+] Installing Drupal..."

drush dl drupal-8 --destination=$(dirname $WEBROOT)
mv $(dirname $WEBROOT)/drupal-8* $WEBROOT

# setup Database
#drush si standard --db-url=mysql://[db_user]:[db_pass]@[ip-address]/[db_name] --account-name=admin --account-pass=[useruser_pass] --site-name=Example
drush si standard --db-url=mysql://root:$root_db_pass@127.0.0.1/drupal --account-name=admin --account-pass=$drupal_admin_passwd

exit
####### END :) #######