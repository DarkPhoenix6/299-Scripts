#!/bin/bash
#
######################################################################
#
#	Name:		 	<Script Name>
#	Author:			Chris Fedun <Date>
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
	tar -zxvf dahdi-linux-complete-current.tar.gz
	tar -xjvf pjproject-2.6.tar.bz2
	tar vxfz freepbx-13.0-latest.tgz
	rm /usr/local/src/*.tar.gz
	rm /usr/local/src/*.tar.bz2
	rm /usr/local/src/*.tar.tgz
	
}

function install_DHADI
{
	cd $asterisk_SRC\dahdi-linux-complete-2.11.1+2.11.1/
	make all && make install
	make config
	
}

function install_LibPRI
{
	cd $asterisk_SRC\libpri-1.6.0/
	make && make install
}
function install_asterisk
{
	cd $asterisk_SRC\asterisk-14.3.0/
	./contrib/scripts/get_mp3_source.sh
	./contrib/scripts/install_prereq install #expect
	./contrib/scripts/install_prereq install-unpackaged #expect
	###for RPI change this to compile###
	sed -i '
	/\#   if !PJ_IS_LITTLE_ENDIAN && !PJ_IS_BIG_ENDIAN/ {
		N
			/\#    \terror Endianness must be declared for this processor/ {
				N
					/\#   endif/ {
						N
							s/\#   if !PJ_IS_LITTLE_ENDIAN && !PJ_IS_BIG_ENDIAN\n\#    \terror Endianness must be declared for this processor\n\#   endif/\#   define PJ_IS_LITTLE_ENDIAN\t1\n\#   define PJ_IS_BIG_ENDIAN\t0
					}
			}
	}
	' /usr/include/pj/config.h
	./configure --with-pjproject-bundled
	make && make install
	#Make Do
	make progdocs
	
)
##### Main #####
unpack_asterisk
install_DHADI
install_LibPRI

exit
####### END :) #######