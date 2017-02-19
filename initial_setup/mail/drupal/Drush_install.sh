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
##Create and/or navigate to a path for the single Composer Drush install.
#mkdir --parents /opt/drush-8.x
#cd /opt/drush-8.x
## Initialise a new Composer project that requires Drush.
#composer init --require=drush/drush:8.* -n
## Configure the path Composer should use for the Drush vendor binaries.
#composer config bin-dir /usr/local/bin
## Install Drush. 
#composer install

#git clone https://github.com/drush-ops/drush.git /usr/local/src/drush
#cd /usr/local/src/drush
#git checkout 7.0.0-alpha4  #or whatever version you want.
#ln -s /usr/local/src/drush/drush /usr/bin/drush
#composer install
#drush --version

# install drush dev-master

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
#######END :) #######