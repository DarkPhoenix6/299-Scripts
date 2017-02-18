#!/bin/bash
#
######################################################################
#
#	Name:		 	bind9.sh
#	Author:			Chris Fedun 31/01/2017
#	Description:	Bind9 Configuration
#
######################################################################
#####Constants#####
domain_name=$1


cd /usr/local/src/
wget http://www.no-ip.com/client/linux/noip-duc-linux.tar.gz
tar xf noip-duc-linux.tar.gz
cd noip-2.1.9-1/
make install