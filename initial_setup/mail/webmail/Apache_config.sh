#!/bin/bash
#
######################################################################
#
#	Name:		 	Apache_config.sh
#	Author:			Chris Fedun 31/01/2017
#	Description:	Apache Configuration
#
######################################################################
#####Constants#####
My_Cert="/etc/ssl/My_Certs/certs/mailserver_crt.pem"
My_Key="/etc/ssl/My_Certs/private/mailserver_key.pem"
domain_name=$1
#####Main
sed -i '
	/		                SSLCertificateFile    \/etc\/ssl\/certs\/ssl-cert-snakeoil.pem/ {
		N
			/		                SSLCertificateKeyFile \/etc\/ssl\/private\/ssl-cert-snakeoil.key/ {
				N
					s:		                SSLCertificateFile    /etc/ssl/certs/ssl-cert-snakeoil.pem\n		                SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key:		                \#SSLCertificateFile    /etc/ssl/certs/ssl-cert-snakeoil.pem\n						\#SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key\n						SSLCertificateFile /etc/ssl/My_Certs/certs/mailserver_crt.pem\n						SSLCertificateKeyFile /etc/ssl/My_Certs/private/mailserver_key.pem:
			}
	}


' /etc/apache2/sites-available/default-ssl.conf

#Enable the SSL encryption module
a2enmod ssl
#Enable the virtual host for HTTPS
a2ensite default-ssl

service apache2 reload

sed -i "
	s|		\#ServerName www.example.com|        ServerName mail.$domain_name\n        ServerAlias www.$domain_name\n        Redirect permanent / https://www.$domain_name\/|
	s|        DocumentRoot /var/www/html|        \#DocumentRoot /var/www/html|
" /etc/apache2/sites-available/000-default.conf

service apache2 reload

exit

####### END :) #######
	
#						SSLCertificateFile    /etc/ssl/certs/ssl-cert-snakeoil.pem
#						SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
#		                #SSLCertificateFile    /etc/ssl/certs/ssl-cert-snakeoil.pem
#						#SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
#						SSLCertificateFile /etc/ssl/My_Certs/certs/mailserver_crt.pem
#						SSLCertificateKeyFile /etc/ssl/My_Certs/private/mailserver_key.pem
#		
#		#ServerName www.example.com
#
#        ServerAdmin webmaster@localhost
#        DocumentRoot /var/www/html
#
#
#        ServerName mail.cfedun.com
#        ServerAlias www.cfedun.com
#        Redirect permanent / https://www.cfedun.com/
#        ServerAdmin webmaster@localhost
#        #DocumentRoot /var/www/html
