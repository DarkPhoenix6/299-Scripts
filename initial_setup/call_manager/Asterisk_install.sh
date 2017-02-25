#!/bin/bash
#
######################################################################
#
#	Name:		 	<Script Name>
#	Author:			Chris Fedun 23/02/2017
#	Description:	<description> 
#	
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
##### Constants #####
host_name=$1
domain_name=$2
Country=$3
State=$4
City=$5
OrgName=$6
OU=$7
User_Name=$8
Setup_dir='/root/initial_setup/call_manager/'
First_boot="/var/log/firstboot.log"
Second_boot="/var/log/secondboot.log"
asterisk_SRC="/usr/local/src/"

##### Functions #####
function unpack_asterisk
{
	cp $Setup_dir\Asterisk_files/* $asterisk_SRC
	cd $asterisk_SRC
	tar -zxvf libpri-current.tar.gz
	tar -zxvf asterisk-14-current.tar.gz
	tar -zxvf jansson-2.7.tar.gz
	tar -zxvf dahdi-linux-complete-current.tar.gz
	tar -xjvf pjproject-2.6.tar.bz2
	tar -xzvf freepbx-13.0-latest.tgz
	rm /usr/local/src/*.tar.gz
	rm /usr/local/src/*.tar.bz2
	rm /usr/local/src/*.tgz

}

function install_iksemel
{
	###Google Voice support###
	echo "[+] Building and Installing iksemel..."
	cd $asterisk_SRC\iksemel
	./configure
	make
	make install
}
function install_DHADI
{
	### Install DHADI ###
	echo "[+] Building and Installing DHADI..."
	cd $asterisk_SRC\dahdi-linux-complete-2.11.1+2.11.1/
	make all && make install
	make config
	
}

function install_LibPRI
{
	### Install LibPRI ###
	echo "[+] Building and Installing LibPRI..."
	cd $asterisk_SRC\libpri-1.6.0/
	make && make install
}
function install_jansson
{
	echo "[+] Compile and Install jansson..."
	cd $asterisk_SRC\jansson-*
	autoreconf -i
	./configure
	make
	make install
}

function install_asterisk
{
	
	cd $asterisk_SRC\asterisk-14.3.0/

	./contrib/scripts/install_prereq install #expect
	./contrib/scripts/install_prereq install-unpackaged #expect	
	./configure --with-pjproject-bundled
	./contrib/scripts/get_mp3_source.sh
	###for RPI change this to compile###
	sed -i '
	/\#   if !PJ_IS_LITTLE_ENDIAN && !PJ_IS_BIG_ENDIAN/ {
		N
			/\#    \terror Endianness must be declared for this processor/ {
				N
					/\#   endif/ {
						N
							s/\#   if !PJ_IS_LITTLE_ENDIAN && !PJ_IS_BIG_ENDIAN\n\#    \terror Endianness must be declared for this processor\n\#   endif/\#   define PJ_IS_LITTLE_ENDIAN\t1\n\#   define PJ_IS_BIG_ENDIAN\t0/
					}
			}
	}
	' /usr/local/include/pj/config.h

	make menuselect.makeopts
	menuselect/menuselect --enable app_voicemail --enable format_mp3 --enable res_config_mysql \
	--enable app_mysql --enable cdr_mysql menuselect.makeopts
	make && make install
	make config
	#Make Docs # not needed
	#make progdocs
	ldconfig
	update-rc.d -f asterisk remove
}

function conf_ODBC
{
cat >> /etc/odbcinst.ini << EOF
[MySQL]
Description = ODBC for MySQL
Driver = /usr/lib/x86_64-linux-gnu/odbc/libmyodbc.so
Setup = /usr/lib/x86_64-linux-gnu/odbc/libodbcmyS.so
FileUsage = 1
  
EOF
	
cat >> /etc/odbc.ini << EOF
[MySQL-asteriskcdrdb]
Description=MySQL connection to 'asteriskcdrdb' database
driver=MySQL
server=localhost
database=asteriskcdrdb
Port=3306
Socket=/var/run/mysqld/mysqld.sock
option=3
  
EOF

}

function install_FreePBX
{
	
	useradd -m asterisk
	chown asterisk. /var/run/asterisk
	chown -R asterisk. /etc/asterisk
	chown -R asterisk. /var/{lib,log,spool}/asterisk
	chown -R asterisk. /usr/lib/asterisk
	rm -rf /var/www/html
	#Configure Apache2 #
	bash -x $Setup_dir\Apache2/Apache_config.sh
	# Configure ODBC #
	conf_ODBC
	# Install FreePBX#
	cd $asterisk_SRC\freepbx
	./start_asterisk start
	./install -n

	
}
##### Main #####
unpack_asterisk
install_iksemel
install_DHADI
install_LibPRI
install_jansson
install_asterisk
install_FreePBX

exit
####### END :) #######