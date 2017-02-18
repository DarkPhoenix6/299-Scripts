#!/bin/bash
#
######################################################################
#
#	Name:		 	Fail2Ban.sh
#	Author:			Chris Fedun 31/01/2017
#	Description:	Fail2Ban Configuration
#
######################################################################
#####Constants#####
domain_name=$1
#comment entire file
awk '{ printf "# "; print; }' /etc/fail2ban/jail.conf | sudo tee /etc/fail2ban/jail.local
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local