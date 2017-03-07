#!/bin/bash
#
######################################################################
#
#	Name:		 	PW_change.sh
#	Author:			Chris Fedun 19/02/2017
#	Description:	Change Password
#	Credit to http://unix.stackexchange.com/questions/76313/change-password-of-a-user-in-etc-shadow
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
#apt-get install -y python-minimal

Saltsalt=$(pwgen -s 8 1)
User_name=chris
#New_Passwd=$2
New_Passwd='P@ssw0rd'
shadow_passwd=$(python -c "import crypt, getpass, pwd; \
         print crypt.crypt('$New_Passwd', '\$6\$$Saltsalt\$')")
#sed -r "s|$User_name:[^:].*:(.*)|$User_name:$shadow_passwd:\1|" /etc/shadow > /etc/shadow.new2
sed -ri "s|$User_name:[^:].*(:.*:.*:.*:.*:::)|$User_name:$shadow_passwd\1|" /etc/shadow 
