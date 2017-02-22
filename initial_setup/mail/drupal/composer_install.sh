#!/bin/sh
#
######################################################################
#
#	Name:		 		composer_install.sh
#	Author:				Chris Fedun 26/01/2017
#	Description:		Composer Setup script Configuration
#	Original Script:	https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
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
sudo -H -u www-data bash -c 'curl -sS https://getcomposer.org/installer' | sudo -H -u www-data bash -c 'php'
#sudo -H -u www-data bash -c php composer.phar
mv composer.phar /usr/local/bin/composer
ln -s /usr/local/bin/composer /usr/bin/composer


exit
####### END :) #######