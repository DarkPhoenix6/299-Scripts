#!/bin/bash
#
######################################################################
#
#	Name:		 	Database_openvpn.sh
#	Author:			Chris Fedun 16/03/2017
#	Description:	Database for OpenVPN Access Server
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
DB=127.0.0.1
Setup_dir='/root/initial_setup/mail/'
root_db_pass=$( cat $Setup_dir\MYSQL/pass.txt )



mysql --user=root --password=$root_db_pass << MYSQL_SCRIPT

 
CREATE DATABASE IF NOT EXISTS \`as_certs\`;

CREATE DATABASE IF NOT EXISTS \`as_config\`;

CREATE DATABASE IF NOT EXISTS \`as_log\`;

CREATE DATABASE IF NOT EXISTS \`as_userprop\`;


MYSQL_SCRIPT
 
 
#mkdir /root/keyfiles_bak
#cp /usr/local/openvpn_as/etc/web-ssl/* /root/keyfiles_bak

service openvpnas restart

cd /usr/local/openvpn_as/scripts
./sacli --import GetActiveWebCerts

service openvpnas stop

cd /usr/local/openvpn_as/scripts
./dbcvt -t certs -s sqlite:////usr/local/openvpn_as/etc/db/certs.db -d mysql://$DB/as_certs
./dbcvt -t config -s sqlite:////usr/local/openvpn_as/etc/db/config.db -d mysql://$DB/as_config
./dbcvt -t log -s sqlite:////usr/local/openvpn_as/etc/db/log.db -d mysql://$DB/as_log
./dbcvt -t user_prop -s sqlite:////usr/local/openvpn_as/etc/db/userprop.db -d mysql://$DB/as_userprop

#change OpenVPNAS Database location to the MySQL 
# configuration DB
sed -i 's|config_db=sqlite:///~/db/config.db|config_db=mysql://127.0.0.1/as_config|' /usr/local/openvpn_as/etc/as.conf
# user properties DB
sed -i 's|user_prop_db=sqlite:///~/db/userprop.db|user_prop_db=mysql://127.0.0.1/as_userprop|'
# log DB
sed -i 's|log_db=sqlite:///~/db/log.db|log_db=mysql://127.0.0.1/as_log|'
# certificates database
sed -i 's|certs_db=sqlite:///~/db/certs.db|certs_db=mysql://127.0.0.1/as_certs|'


service openvpnas start


exit
####### END :) #######