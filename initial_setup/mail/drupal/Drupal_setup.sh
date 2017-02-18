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
Setup_dir='/root/initial_setup/mail/'
SRC=/usr/local/src
WEBROOT=/var/www/drupal
echo "[+] Installing Composer..."
sudo bash $Setup_dir\drupal/composer_install.sh $domain_name
echo "[+] Installing Drush..."
sudo bash $Setup_dir\drupal/Drush_inatall.sh $domain_name

# download latest drupal8 and install
echo "[+] Installing Drupal..."
sudo -H -u nonroot bash -c "drush dl drupal-8 --destination=$(dirname $WEBROOT)"
mv $(dirname $WEBROOT)/drupal-8* $WEBROOT
 

exit
#######END :) #######