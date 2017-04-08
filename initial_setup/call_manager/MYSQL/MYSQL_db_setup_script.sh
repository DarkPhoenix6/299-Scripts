#!/bin/bash
#
######################################################################
#
#	Name:		 	MYSQL_db_setup_script.sh
#	Author:			Chris Fedun 18/01/2017
#	Description:	MYSQL DataBase Setup Script Configuration
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
Setup_dir='/root/initial_setup/call_manager/'
root_db_pass=$( cat $Setup_dir\MYSQL/pass.txt )

mysql --user=root --password=$root_db_pass < /root/My_List_of_SMS_gateways/SMS_Gateways.sql
 
exit
####### END :) #######

