#!/bin/bash
#
######################################################################
#
#	Name:		 	iptables_mail.sh
#	Author:			Chris Fedun 20/03/2017
#	Description:	OpenVPN Access Server Configuration for Mail Server
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

cp /root/.my.cnf /etc/.my.cnf
chmod go-rwx /etc/.my.cnf

cd $Setup_dir\OpenVPNAS/
#Download OpenVPN AS
wget -O - https://github.com/DarkPhoenix6/299-Mail-Dependencies/blob/master/OpenVpn.tar.gz.partaa?raw=true > OpenVpn.tar.gz.partaa
wget -O - https://github.com/DarkPhoenix6/299-Mail-Dependencies/blob/master/OpenVpn.tar.gz.partab?raw=true > OpenVpn.tar.gz.partab

#Join the file
cat OpenVpn.tar.gz.parta* >OpenVpn.tar.gz
# Extract the files
tar -zxvf OpenVpn.tar.gz 

cd OpenVpn/



dpkg -i openvpn-as-2.1.4-Debian8.amd_64.deb




cat > cat > /etc/rc.local << EOF
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

service openvpnas start

exit 0

EOF

exit
####### END :) #######