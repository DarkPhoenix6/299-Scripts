#!/bin/bash
#
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


domain_name=$1
host_name=mail
Country=CA
State=BC
City=KELOWNA
OrgName="Chris Fedun Sec LTD"
OU=CF
FQDN=$host_name.$domain_name
User_Name=chris
Email=$User_Name@$domain_name
bash -x /root/initial_setup/mail/initial_install_script.sh $host_name $domain_name $Country $State $City "$OrgName" $OU $User_Name &>> /var/log/initial_setup.log
exit
#######END :) #######
