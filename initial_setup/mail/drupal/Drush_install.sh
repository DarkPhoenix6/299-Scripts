#!/bin/bash
#
######################################################################
#
#	Name:		 	Drush_inatall.sh
#	Author:			Chris Fedun 26/01/2017
#	Description:	Drush Setup script Configuration
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
SRC=/usr/local/src
WEBROOT=/var/www/html/drupal
domain_name=$1


# install drush dev-master
cd /home/www-data/
sudo -H -u www-data bash -c "git clone --depth 1 https://github.com/drush-ops/drush.git $SRC/drush"
cd $SRC/drush
sudo -H -u www-data bash -c "composer install"
ln -s $SRC/drush/drush /usr/local/bin/drush
ln -s $SRC/drush/drush.complete.sh /etc/bash_completion.d/drush

mkdir -p /etc/drush
cat > /etc/drush/drushrc.php << EOF
<?php
// by default use the drupal root directory
\$options['r'] = '$WEBROOT';
EOF



exit
####### END :) #######