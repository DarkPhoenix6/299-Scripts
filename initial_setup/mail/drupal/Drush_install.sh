#!/bin/bash
#
######################################################################
#
#	Name:		 	Drush_inatall.sh
#	Author:			Chris Fedun 26/01/2017
#	Description:	Drush Setup script Configuration
#
######################################################################
SRC=/usr/local/src
WEBROOT=/var/www/drupal
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