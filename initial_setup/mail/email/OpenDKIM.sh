#!/bin/bash
#
######################################################################
#
#	Name:		 	OpenDKIM.sh
#	Author:			Chris Fedun 31/01/2017
#	Description:	OpenDKIM Setup Script 
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


function new_dir_and_files
{
sudo mkdir /etc/opendkim
sudo mkdir /etc/opendkim/keys
sudo mkdir /etc/opendkim/keys/$domain_name

sudo touch /etc/opendkim/TrustedHosts
sudo touch /etc/opendkim/SigningTable
sudo touch /etc/opendkim/KeyTable
}

#####Main
#Create new files and directories
new_dir_and_files
echo "AutoRestart             Yes" >> /etc/opendkim.conf
echo "AutoRestartRate         10/1h" >> /etc/opendkim.conf
echo "UMask                   002" >> /etc/opendkim.conf
echo "Syslog                  yes" >> /etc/opendkim.conf
echo "SyslogSuccess           Yes" >> /etc/opendkim.conf
echo "LogWhy                  Yes" >> /etc/opendkim.conf
echo " " >> /etc/opendkim.conf
echo "Canonicalization        relaxed/simple" >> /etc/opendkim.conf
echo " " >> /etc/opendkim.conf
echo "ExternalIgnoreList      refile:/etc/opendkim/TrustedHosts" >> /etc/opendkim.conf
echo "InternalHosts           refile:/etc/opendkim/TrustedHosts" >> /etc/opendkim.conf
echo "KeyTable                refile:/etc/opendkim/KeyTable" >> /etc/opendkim.conf
echo "SigningTable            refile:/etc/opendkim/SigningTable" >> /etc/opendkim.conf
echo " " >> /etc/opendkim.conf
echo "Mode                    sv" >> /etc/opendkim.conf
echo "PidFile                 /var/run/opendkim/opendkim.pid" >> /etc/opendkim.conf
echo "SignatureAlgorithm      rsa-sha256" >> /etc/opendkim.conf
echo " " >> /etc/opendkim.conf
echo "UserID                  opendkim:opendkim" >> /etc/opendkim.conf
echo " " >> /etc/opendkim.conf
echo "Socket                  inet:12301@localhost" >> /etc/opendkim.conf


#Connect the milter to Postfix
echo 'SOCKET="inet:12301@localhost"' >> /etc/default/opendkim

postconf 'milter_protocol = 2'
postconf 'milter_default_action = accept'
postconf 'smtpd_milters = unix:/spamass/spamass.sock, inet:localhost:12301'
postconf 'milter_connect_macros = i j {daemon_name} v {if_name} _'
postconf 'non_smtpd_milters = inet:localhost:12301'

#Specify the Trusted Hosts
echo "127.0.0.1" > /etc/opendkim/TrustedHosts
echo "localhost" >> /etc/opendkim/TrustedHosts
echo "192.168.0.1/24" >> /etc/opendkim/TrustedHosts
echo "" >> /etc/opendkim/TrustedHosts
echo "*.$domain_name" >> /etc/opendkim/TrustedHosts
echo '' >> /etc/opendkim/TrustedHosts
echo '#*.example.net' >> /etc/opendkim/TrustedHosts
echo '#*.example.org' >> /etc/opendkim/TrustedHosts

#create a Key Table
echo "mail._domainkey.$domain_name $domain_name:mail:/etc/opendkim/keys/$domain_name/mail.private" > /etc/opendkim/KeyTable
echo "" >> /etc/opendkim/KeyTable
echo "#mail._domainkey.example.com example.com:mail:/etc/opendkim/keys/example.com/mail.private" >> /etc/opendkim/KeyTable
echo "#mail._domainkey.example.net example.net:mail:/etc/opendkim/keys/example.net/mail.private" >> /etc/opendkim/KeyTable
echo "#mail._domainkey.example.org example.org:mail:/etc/opendkim/keys/example.org/mail.private" >> /etc/opendkim/KeyTable
#create a Signing table
echo "@$domain_name mail._domainkey.$domain_name" > /etc/opendkim/SigningTable
echo '' >> /etc/opendkim/SigningTable
echo '#*@example.com mail._domainkey.example.com' >> /etc/opendkim/SigningTable
echo '#*@example.net mail._domainkey.example.net' >> /etc/opendkim/SigningTable
echo '#*@example.org mail._domainkey.example.org' >> /etc/opendkim/SigningTable

#Generate the Public and Private keys

cd /etc/opendkim/keys/$domain_name
opendkim-genkey -s mail -d $domain_name
chown opendkim:opendkim mail.private

#
sudo service postfix restart
sudo service opendkim restart
exit
####### END :) #######