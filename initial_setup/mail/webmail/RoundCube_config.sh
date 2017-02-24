#!/bin/bash
#
######################################################################
#
#	Name:		 	RoundCube_config.sh
#	Author:			Chris Fedun 31/01/2017
#	Description:	RoundCube Configuration
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
#####Constants#####
Setup_dir='/root/initial_setup/mail/'
My_Cert="/etc/ssl/My_Certs/certs/mailserver_crt.pem"
My_Key="/etc/ssl/My_Certs/private/mailserver_key.pem"
domain_name=$1
mailuser_passwd=$(cat $Setup_dir\email/mailuser_passwd.txt)
#####Main

sed -i "
/ServerAdmin webmaster@localhost/ a\
\\t\tServerName mail.$domain_name:443\n\t\tServerAlias www.$domain_name:443\n\t\tInclude /etc/phpmyadmin/apache.conf\n\t\tInclude /etc/roundcube/apache.conf\n\t\tAlias /webmail /var/lib\/roundcube/
" /etc/apache2/sites-available/default-ssl.conf

sed -i "
s:\$config\['default_host'\] = '';://\$config\['default_host'\] = '';\n\$config\['default_host'\] = 'localhost';:
" /etc/roundcube/config.inc.php

#Plugins
sed -i "
/'zipdownload',/ a\
'managesieve',\n'password',
" /etc/roundcube/config.inc.php

echo "\$config['session_lifetime'] = 60;" >> /etc/roundcube/config.inc.php


#configure the managesieve plugin
cp /usr/share/roundcube/plugins/managesieve/config.inc.php.dist /etc/roundcube/plugins/managesieve/config.inc.php
#Configure the password plugin
cp /usr/share/roundcube/plugins/password/config.inc.php.dist /etc/roundcube/plugins/password/config.inc.php
sed -i "
	s:\$config\['password_minimum_length'\] = 0;:\$config\['password_minimum_length'\] = 10;:
	s:\$config\['password_force_save'\] = false;:\$config\['password_force_save'\] = true;:
	s|\$config\['password_db_dsn'\] = '';|\$config\['password_db_dsn'\] = 'mysql://mailuser:$mailuser_passwd@127.0.0.1/mailserver';|
	
	s:\$config\['password_query'\] = 'SELECT update_passwd(%c, %u)';:\$config\['password_query'\] = \"UPDATE virtual_users SET password=CONCAT('{SHA256-CRYPT}', ENCRYPT (%p, CONCAT('\$5$', SUBSTRING(SHA(RAND()), -16)))) WHERE email=%u;\";:

" /etc/roundcube/plugins/password/config.inc.php

exit
####### END :) #######


