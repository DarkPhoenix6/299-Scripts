#!/bin/bash
#
######################################################################
#
#	Name:		 	Postfix_setup_script.sh
#	Author:			Chris Fedun 23/01/2017
#	Description:	Postfix Setup Script 
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
domain_name=$1
host_name=$2
Setup_dir='/root/initial_setup/mail/'
mailuser_passwd=$(cat $Setup_dir\email/mailuser_passwd.txt)
My_Cert="/etc/ssl/My_Certs/certs/mailserver_crt.pem"
My_Key="/etc/ssl/My_Certs/private/mailserver_key.pem"

##### Functions #####
function Create_config_files
{
	touch /etc/postfix/mysql-virtual-mailbox-domains.cf
	touch /etc/postfix/mysql-virtual-mailbox-maps.cf
	touch /etc/postfix/mysql-virtual-alias-maps.cf
	touch /etc/postfix/mysql-email2email.cf
}

function Create_mappings
{
	echo "user = mailuser" > /etc/postfix/mysql-virtual-mailbox-domains.cf
	echo "password = $mailuser_passwd" >> /etc/postfix/mysql-virtual-mailbox-domains.cf
	echo "hosts = 127.0.0.1" >> /etc/postfix/mysql-virtual-mailbox-domains.cf
	echo "dbname = mailserver" >> /etc/postfix/mysql-virtual-mailbox-domains.cf
	echo "query = SELECT 1 FROM virtual_domains WHERE name='%s'" >> /etc/postfix/mysql-virtual-mailbox-domains.cf

	echo "user = mailuser" > /etc/postfix/mysql-virtual-mailbox-maps.cf
	echo "password = $mailuser_passwd" >> /etc/postfix/mysql-virtual-mailbox-maps.cf
	echo "hosts = 127.0.0.1" >> /etc/postfix/mysql-virtual-mailbox-maps.cf
	echo "dbname = mailserver" >> /etc/postfix/mysql-virtual-mailbox-maps.cf
	echo "query = SELECT 1 FROM virtual_users WHERE email='%s'" >> /etc/postfix/mysql-virtual-mailbox-maps.cf

	echo "user = mailuser" > /etc/postfix/mysql-virtual-alias-maps.cf
	echo "password = $mailuser_passwd" >> /etc/postfix/mysql-virtual-alias-maps.cf
	echo "hosts = 127.0.0.1" >> /etc/postfix/mysql-virtual-alias-maps.cf
	echo "dbname = mailserver" >> /etc/postfix/mysql-virtual-alias-maps.cf
	echo "query = SELECT destination FROM virtual_aliases WHERE source='%s'" >> /etc/postfix/mysql-virtual-alias-maps.cf


	echo "user = mailuser" > /etc/postfix/mysql-email2email.cf
	echo "password = $mailuser_passwd" >> /etc/postfix/mysql-email2email.cf
	echo "hosts = 127.0.0.1" >> /etc/postfix/mysql-email2email.cf
	echo "dbname = mailserver" >> /etc/postfix/mysql-email2email.cf
	echo "query = SELECT email FROM virtual_users WHERE email='%s'" >> /etc/postfix/mysql-email2email.cf
	#Making Postfix get its information from the MySQL database
	postconf virtual_mailbox_domains=mysql:/etc/postfix/mysql-virtual-mailbox-domains.cf
	postconf virtual_mailbox_maps=mysql:/etc/postfix/mysql-virtual-mailbox-maps.cf
	postconf virtual_alias_maps=mysql:/etc/postfix/mysql-virtual-alias-maps.cf

	#For "catch-all addresses" uncomment following line
	#postconf virtual_alias_maps=mysql:/etc/postfix/mysql-virtual-alias-maps.cf,mysql:/etc/postfix/mysql-email2email.cf

	chgrp postfix /etc/postfix/mysql-*.cf
	chmod u=rw,g=r,o= /etc/postfix/mysql-*.cf

	#Tell Postfix to deliver emails to Dovecot using LMTP
	postconf virtual_transport=lmtp:unix:private/dovecot-lmtp
	
	#Set destinations
	postconf myhostname="$host_name.$domain_name"
	postconf mydestination="$host_name.$domain_name, localhost.$domain_name, , localhost"

}

function Enable_relay
{
	#Make Postfix use Dovecot for authentication
	postconf smtpd_sasl_type=dovecot
	postconf smtpd_sasl_path=private/auth
	postconf smtpd_sasl_auth_enable=yes

	#Enable encrypted traffic
	postconf smtpd_tls_security_level=may
	postconf smtpd_tls_auth_only=yes
	postconf smtpd_tls_cert_file=/etc/ssl/My_Certs/certs/mailserver_crt.pem
	postconf smtpd_tls_key_file=/etc/ssl/My_Certs/private/mailserver_key.pem
	#Increase TLS security
	postconf 'smtpd_tls_mandatory_protocols=!SSLv2,!SSLv3'

}
#####Main
#####Create Config Files#####
Create_config_files
#####Edit Config Files#####
Create_mappings

#####Enable Relaying with SMTP authentication#####
Enable_relay


#####Enable the submission port tcp 587#####

sed -i '
/\#tlsproxy  unix  -       -       -       -       0       tlsproxy/ a\
submission inet n - - - - smtpd\
\ -o syslog_name=postfix/submission\
\ -o smtpd_tls_security_level=encrypt\
\ -o smtpd_sasl_auth_enable=yes\
\ -o smtpd_sasl_type=dovecot\
\ -o smtpd_sasl_path=private/auth\
\ -o smtpd_sasl_security_options=noanonymous\
\ -o smtpd_sender_login_maps=mysql:/etc/postfix/mysql-email2email.cf\
\ -o smtpd_sender_restrictions=reject_sender_login_mismatch\
\ -o smtpd_sasl_local_domain=$myhostname\
\ -o smtpd_client_restrictions=permit_sasl_authenticated,reject\
\ -o smtpd_recipient_restrictions=reject_non_fqdn_recipient,reject_unknown_recipient_domain,permit_sasl_authenticated,reject
' /etc/postfix/master.cf


exit
####### END :) #######