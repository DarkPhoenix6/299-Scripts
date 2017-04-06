#!/bin/sh
#
######################################################################
#
#	Name:		 		composer_install.sh
#	Author:				Chris Fedun 26/01/2017
#	Description:		Composer Setup script Configuration
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
WEBROOT=/var/www/html/drupal


# install composer
mkdir /home/www-data
chown -R www-data:www-data /home/www-data/
cd /home/www-data/
sudo -H -u www-data bash -c 'curl -sS https://getcomposer.org/installer' | sudo -H -u www-data bash -c 'php'

mv composer.phar /usr/local/bin/composer
ln -s /usr/local/bin/composer /usr/bin/composer


exit
####### END :) #######