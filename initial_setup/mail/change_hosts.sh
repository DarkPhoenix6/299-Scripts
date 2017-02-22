#!/bin/bash
#
######################################################################
#
#	Name:		 	change_hosts.sh
#	Author:			Chris Fedun 19/02/2017
#	Description:	Hostname Configuration
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