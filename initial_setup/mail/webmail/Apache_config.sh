#!/bin/bash
#
######################################################################
#
#	Name:		 	Apache_config.sh
#	Author:			Chris Fedun 31/01/2017
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
#####Constants#####
My_Cert="/etc/ssl/My_Certs/certs/mailserver_crt.pem"
My_Key="/etc/ssl/My_Certs/private/mailserver_key.pem"
domain_name=$1
#####Main
sed -i "
	/\t\tSSLCertificateFile\t\/etc\/ssl\/certs\/ssl-cert-snakeoil.pem/ {
		N
			/\t\tSSLCertificateKeyFile \/etc\/ssl\/private\/ssl-cert-snakeoil.key/ {
				N
					s:\t\tSSLCertificateFile\t/etc/ssl/certs/ssl-cert-snakeoil.pem\n\t\tSSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key:\t\t\#SSLCertificateFile\t/etc/ssl/certs/ssl-cert-snakeoil.pem\n\t\t\#SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key\n\t\tSSLCertificateFile\t$My_Cert\n\t\tSSLCertificateKeyFile $My_Key:
			}
	}
" /etc/apache2/sites-available/default-ssl.conf

# Enable 
sed -ri "
	/<Directory \/var\/www\/>/ {
		N
			/\tOptions Indexes FollowSymLinks/ {
				N
					/\tAllowOverride None/ {
						s:(<Directory /var/www/>\n\tOptions Indexes FollowSymLinks\n\tAllowOverride) None:\1 All:
					}
			}
	}
" /etc/apache2/apache2.conf
#Enable the SSL encryption module and the Rewrite module
a2enmod rewrite ssl

#Enable the virtual host for HTTPS
a2ensite default-ssl

service apache2 reload

sed -i "
	s|\t\#ServerName www.example.com|\tServerName mail.$domain_name\n\tServerAlias www.$domain_name\n\tRedirect permanent / https://www.$domain_name\/|
	s|\tDocumentRoot /var/www/html|\t\#DocumentRoot /var/www/html|
" /etc/apache2/sites-available/000-default.conf
#set simple default webpage
mv /var/www/html/index.html /var/www/html/index.html.disable
cp /root/web_pages/HTML/index.html /var/www/html/index.html
service apache2 reload

exit

####### END :) #######
