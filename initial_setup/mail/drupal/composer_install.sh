#!/bin/sh
#
######################################################################
#
#	Name:		 		composer_install.sh
#	Author:				Chris Fedun 26/01/2017
#	Description:		Composer Setup script Configuration
#	Original Script:	https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
######################################################################
domain_name=$1
SRC=/usr/local/src
WEBROOT=/var/www/drupal
#EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
#cd /usr/src
#php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
#ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")
#
#if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
#then
#    >&2 echo 'ERROR: Invalid installer signature'
#    rm composer-setup.php
#    exit 1
#fi
#
#php composer-setup.php --quiet
#RESULT=$?
#rm composer-setup.php
#mv composer.phar /usr/local/bin/composer
#ln -s /usr/local/bin/composer /usr/bin/composer
#exit $RESULT

# install composer
mkdir /home/www-data
chown -R www-data:www-data /home/www-data/
cd /home/www-data/
sudo -H -u www-data bash -c 'curl -sS https://getcomposer.org/installer | php'
mv composer.phar /usr/local/bin/composer
rm composer-setup.php
ln -s /usr/local/bin/composer /usr/bin/composer


exit
#######END :) #######