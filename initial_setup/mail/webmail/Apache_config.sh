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
	/\t\tSSLCertificateFile    \/etc\/ssl\/certs\/ssl-cert-snakeoil.pem/ {
		N
			/\t\tSSLCertificateKeyFile \/etc\/ssl\/private\/ssl-cert-snakeoil.key/ {
				N
					s:\t\tSSLCertificateFile\t/etc/ssl/certs/ssl-cert-snakeoil.pem\n\t\tSSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key:\t\t\#SSLCertificateFile\t/etc/ssl/certs/ssl-cert-snakeoil.pem\n\t\t\#SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key\n\t\tSSLCertificateFile\t/etc/ssl/My_Certs/certs/mailserver_crt.pem\n\t\tSSLCertificateKeyFile /etc/ssl/My_Certs/private/mailserver_key.pem:
			}
	}


' /etc/apache2/sites-available/default-ssl.conf

#Enable the SSL encryption module and the Rewrite module
a2enmod rewrite ssl

#Enable the virtual host for HTTPS
a2ensite default-ssl

service apache2 reload

sed -i "
	s|\t\#ServerName www.example.com|\tServerName mail.$domain_name\n\tServerAlias www.$domain_name\n\tRedirect permanent / https://www.$domain_name\/|
	s|\tDocumentRoot /var/www/html|\t\#DocumentRoot /var/www/html|
" /etc/apache2/sites-available/000-default.conf

service apache2 reload

exit

####### END :) #######
#	
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
