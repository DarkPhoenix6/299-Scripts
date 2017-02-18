#!/bin/bash
#
######################################################################
#
#	Name:		 	Server2Server_VPN.sh
#	Author:			Chris Fedun 31/01/2017
#	Description:	Server2Server_VPN Configuration
#
######################################################################
#####Constants#####
domain_name=$1
apt-get update && apt-get install openvpn easy-rsa


mkdir /etc/openvpn/easy-rsa/
cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/

sed -i '

' /etc/openvpn/easy-rsa/var