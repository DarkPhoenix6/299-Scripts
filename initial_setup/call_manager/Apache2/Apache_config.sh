#!/bin/bash
#
######################################################################
#
#	Name:		 	Apache_config.sh
#	Author:			Chris Fedun 25/02/2017
#	Description:	Apache Configuration
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


#####Main


#Enable the SSL encryption module and the Rewrite module
a2enmod rewrite ssl

#Enable the virtual host for HTTPS
a2ensite default-ssl

#Change Max Upload size to 20Mb
sed -i 's/\(^upload_max_filesize = \).*/\120M/' /etc/php5/apache2/php.ini

#Backup original Apache configureation file 
cp /etc/apache2/apache2.conf /etc/apache2/apache2.conf_orig

#allow asterisk user access
sed -i 's/^\(User\|Group\).*/\1 asterisk/' /etc/apache2/apache2.conf
sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

service apache2 reload

exit

####### END :) #######

