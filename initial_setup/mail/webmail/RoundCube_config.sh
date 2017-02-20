#!/bin/bash
#
######################################################################
#
#	Name:		 	RoundCube_config.sh
#	Author:			Chris Fedun 31/01/2017
#	Description:	RoundCube Configuration
#
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
\                ServerName mail.$domain_name:443\n                ServerAlias www.$domain_name:443\n                Include /etc/phpmyadmin/apache.conf\n                Include /etc/roundcube/apache.conf\n                Alias /webmail /var/lib\/roundcube/
" /etc/apache2/sites-available/default-ssl.conf

sed -i "
s:\$config\['default_host'\] = '';://\$config\['default_host'\] = '';\n\$config\['default_host'\] = 'localhost';:
" /etc/roundcube/config.inc.php

#Plugins
sed -i "
/'archive',/ {
	N
		/'zipdownload',/ {
			N
				a\
				'managesieve',\n'password',
		}
}
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
	
	s:\$config\['password_query'\] = 'SELECT update_passwd(%c, %u)';:\$config\['password_query'\] = \"UPDATE virtual_users SET password=CONCAT('{SHA256-CRYPT}', ENCRYPT (%p, CONCAT('$5$', SUBSTRING(SHA(RAND()), -16)))) WHERE email=%u;\";:

" /etc/roundcube/plugins/password/config.inc.php

exit
####### END :) #######


