#!/bin/bash
#
######################################################################
#
#	Name:		 	Certificate.sh
#	Author:			Chris Fedun 31/01/2017
#	Description:	Certificate Creation Script 
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
FQDN=$host_name.$domain_name
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
expect $Setup_dir\Certificate.exp "$Country" "$State" "$City" "$OrgName" "$OU" "$FQDN" "$User_Name" "$domain_name"
chmod go= $My_Key

exit
####### END :) #######

