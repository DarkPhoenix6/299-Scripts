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
My_Cert="/etc/ssl/My_Certs/certs/mailserver_crt.pem"
My_Key="/etc/ssl/My_Certs/private/mailserver_key.pem"
domain_name=$1
#####Main


#Enable the SSL encryption module and the Rewrite module
a2enmod rewrite ssl

#Enable the virtual host for HTTPS
a2ensite default-ssl

#create HTTPtoHTTPS
sed -i "
	s|\t\#ServerName www.example.com|\t\#ServerName www.example.com\n\tRewriteEngine On\n\tRewriteCond %{HTTPS} off\n\tRewriteRule (.*) https://%{SERVER_NAME}/\$1 [R,L]|
" /etc/apache2/sites-available/000-default.conf

#Set Certificate location
sed -i "
	/\t\tSSLCertificateFile\t\/etc\/ssl\/certs\/ssl-cert-snakeoil.pem/ {
		N
			/\t\tSSLCertificateKeyFile \/etc\/ssl\/private\/ssl-cert-snakeoil.key/ {
				N
					s:\t\tSSLCertificateFile\t/etc/ssl/certs/ssl-cert-snakeoil.pem\n\t\tSSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key:\t\t\#SSLCertificateFile\t/etc/ssl/certs/ssl-cert-snakeoil.pem\n\t\t\#SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key\n\t\tSSLCertificateFile\t$My_Cert\n\t\tSSLCertificateKeyFile $My_Key:
			}
	}


" /etc/apache2/sites-available/default-ssl.conf

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

