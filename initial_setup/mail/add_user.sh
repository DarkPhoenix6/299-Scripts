#!/bin/bash
#
######################################################################
#
#	Name:		 	add_user.sh
#	Author:			Chris Fedun 29/01/2017
#	Description:	MYSQL Email User Setup Script 
#	Usage:			./add_user.sh <username> <Password> <Domain>
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
#Arguements
MINPARAMS=3




function usage
{
    echo "usage: ./add_user.sh [[-u user ] [-p password] [-d domain] | [-h]]"
}

##### Main
UserName=
UserPass=
domain_name=

while [ "$1" != "" ]; do
    case $1 in
        -u | --user )           shift
                                UserName=$1
                                ;;
        -p | --password )    	shift
								UserPass=$1
                                ;;
		-d | --domain )    		shift
								domain_name=$1
								;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done
user_pass_hash=$(doveadm pw -s SHA256-CRYPT -p $UserPass )

mysql <<ADD_USER_MYSQL_SCRIPT

USE mailserver;

INSERT INTO \`mailserver\`.\`virtual_users\` ( \`id\` , \`domain_id\` , \`password\` , \`email\` )
 VALUES ('NULL', '1', "$user_pass_hash" , "$UserName\@$domain_name");
 
REPLACE INTO \`mailserver\`.\`virtual_aliases\` (\`id\`, \`domain_id\`, \`source\`, \`destination\`)
 VALUES ('NULL', '1', "$UserName@$domain_name", "$UserName@$domain_name");
 
ADD_USER_MYSQL_SCRIPT

exit
#######END :) #######