#!/bin/bash
#
######################################################################
#
#	Name:		 	Certificate.sh
#	Author:			Chris Fedun 31/01/2017
#	Description:	Certificate Creation Script 
#	
######################################################################
##### Constants #####
My_Cert="/etc/ssl/My_Certs/certs/mailserver_crt.pem"
My_Key="/etc/ssl/My_Certs/private/mailserver_key.pem"
Setup_dir='/root/initial_setup/mail/'
host_name=$1
domain_name=$2
Country=$3
State=$4
City=$5
OrgName=$6
OU=$7
FQDN=$hostname.$domain_name
User_Name=$8
Email=$User_Name@$domain_name

##### Functions #####
function new_dirs
{
	mkdir -p /etc/ssl/My_Certs/certs/
	mkdir -p /etc/ssl/My_Certs/private/
}
##### Main #####
new_dirs
expect $Setup_dir\Certificate.exp $Country $State $City $OrgName $OU $FQDN $User_Name $domain_name
chmod go= $My_Key

exit
####### END :) #######
#sudo apt-get install python-certbot-apache -t jessie-backports
#certbot --apache
#certbot --apache certonly
