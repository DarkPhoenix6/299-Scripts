#!/bin/bash
#
######################################################################
#
#	Name:		 	Certificate.sh
#	Author:			Chris Fedun 31/01/2017
#	Description:	Certificate Creation Script 
#	
######################################################################
#####Constants#####
My_Cert="/etc/ssl/My_Certs/certs/mailserver_crt.pem"
My_Key="/etc/ssl/My_Certs/private/mailserver_key.pem"
Setup_dir='/root/initial_setup/mail/'
domain_name=$1
Country=CA
State=BC
City=KELOWNA
OrgName="Chris Fedun Sec LTD"
OU=CF
FQDN=mail.$domain_name
User_Name=chris
Email=$User_Name@$domain_name

function new_dirs
{
	mkdir -p /etc/ssl/My_Certs/certs/
	mkdir -p /etc/ssl/My_Certs/private/
}
expect $Setup_dir\Certificate.exp $Country $State $City $OrgName $OU $FQDN $User_Name $domain_name
chmod go= $My_Key


#sudo apt-get install python-certbot-apache -t jessie-backports
#certbot --apache
#certbot --apache certonly
