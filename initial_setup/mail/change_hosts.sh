#!/bin/bash
#
######################################################################
#
#	Name:		 	change_hosts.sh
#	Author:			Chris Fedun 19/02/2017
#	Description:	Hostname Configuration
#
######################################################################
#####Constants#####
host_name=$1
domain_name=$2

echo "mail" > /etc/hostname

sed -i '
/127.0.1.1/ c\
127.0.1.1\tmail
' /etc/hosts

if ! /etc/init.d/hostname.sh start
then
	if ! /etc/init.d/hostname.sh start
	then
		reboot
	fi
fi