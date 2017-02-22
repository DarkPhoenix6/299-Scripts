#!/bin/bash
#
######################################################################
#
#	Name:		 	add_user.sh
#	Author:			Chris Fedun 29/01/2017
#	Description:	MYSQL Email User Setup Script 
#	Usage:			./add_user.sh <username> <Password> <Domain>
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