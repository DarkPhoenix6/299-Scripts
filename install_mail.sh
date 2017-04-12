#!/bin/bash
#
######################################################################
#
#	Name:		 	install_mail.sh
#	Author:			Chris Fedun 31/01/2017
#	Description:	        Install Script 
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
#apt-get install git -y
#cd /root/
#
##this removes any previous downloads of the installation packages
#rm -r 299-Scripts/ initial_setup/ README.md
#
#git -C /root/ clone https://github.com/DarkPhoenix6/299-Scripts.git
#cd /root/299-Scripts/
#git submodule update --init --recursive
#cp -a * ..
#cd ../
#rm -r 299-Scripts/
#touch /var/log/initial_setup.log


domain_name=fedun.ca
host_name=mail
Country=CA
State=BC
City=KELOWNA
OrgName="Chris Fedun Sec LTD"
OU=CF
FQDN=$host_name.$domain_name
User_Name=chris
User_pass=P@ssw0rd
Email=$User_Name@$domain_name
bash -x /root/initial_setup/mail/initial_install_script.sh $host_name $domain_name $Country $State $City "$OrgName" $OU $User_Name $User_pass &>> /var/log/initial_setup.log
chmod go= /var/log/initial_setup.log
exit
#######END :) #######