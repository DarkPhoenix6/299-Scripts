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
Is_PI=$3
Country=$4
State=$5
City=$6
OrgName=$7
OU=$8
User_Name=$9

Setup_dir='/root/initial_setup/call_manager/'
First_boot="/var/log/firstboot.log"
Second_boot="/var/log/secondboot.log"
sound_src="/var/lib/asterisk/sounds/"
asterisk_SRC="/usr/local/src/"
root_db_pass=$( cat $Setup_dir\MYSQL/pass.txt )

##### Functions #####
function unpack_asterisk
{
	cp -r $Setup_dir\Asterisk_files/* $asterisk_SRC
	cd $asterisk_SRC
	tar -zxvf libpri-current.tar.gz
	tar -zxvf asterisk-14-current.tar.gz
	tar -zxvf jansson-2.7.tar.gz
	tar -zxvf dahdi-linux-complete-current.tar.gz
	tar -xjvf pjproject-2.6.tar.bz2
	tar -xzvf freepbx-13.0-latest.tgz
	
}

function install_iksemel
{
	###Google Voice support###
	echo "[+] Building and Installing iksemel..."
	cd $asterisk_SRC\iksemel
	./autogen.sh
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
	./contrib/scripts/install_prereq install-unpackaged 
	#compile with bundled PJsip Project
	./configure --with-pjproject-bundled
	./contrib/scripts/get_mp3_source.sh
	###for RPI change this to compile###
	sed -i '
	/\#   define PJ_M_NAME\t\t"armv4"/{
		N
			/\#   define PJ_HAS_PENTIUM\t0/ {
				N
					/\#   if !PJ_IS_LITTLE_ENDIAN && !PJ_IS_BIG_ENDIAN/ {
						N
							/\#   \terror Endianness must be declared for this processor/ {
								N
									/\#   endif/ {
										N
											s/\#   define PJ_M_NAME\t\t"armv4"\n\#   define PJ_HAS_PENTIUM\t0\n\#   if !PJ_IS_LITTLE_ENDIAN && !PJ_IS_BIG_ENDIAN\n\#   \terror Endianness must be declared for this processor\n\#   endif/\#   define PJ_M_NAME\t\t"armv4"\n\#   define PJ_HAS_PENTIUM\t0\n\#   define PJ_IS_LITTLE_ENDIAN\t1\n\#   define PJ_IS_BIG_ENDIAN\t0/
									}
							}
					}
			}	
	}
	' /usr/local/include/pj/config.h

	make menuselect.makeopts
	menuselect/menuselect --enable app_voicemail --enable format_mp3 --enable res_config_mysql \
	--enable app_mysql --enable cdr_mysql --enable res_pjsip_config_wizard \
	--enable EXTRA-SOUNDS-EN-GSM --enable res_pjproject menuselect.makeopts
	make && make install
	make config
	make install-logrotate
	if [ $Is_PI = $false ]; then 
		# 8 KHz
		cd $asterisk_SRC
		cp asterisk-core-sounds-en-wav-current.tar.gz $sound_src
		cp asterisk-extra-sounds-en-wav-current.tar.gz $sound_src
		cd $sound_src
		tar -zxvf asterisk-core-sounds-en-wav-current.tar.gz
		tar -zxvf asterisk-core-sounds-en-wav-current.tar.gz
		# Wideband Audio ( High Definition 'Wideband' )
		cd $asterisk_SRC
		cp asterisk-extra-sounds-en-g722-current.tar.gz $sound_src
		cp asterisk-core-sounds-en-g722-current.tar.gz $sound_src
		cd $sound_src
		tar asterisk-extra-sounds-en-g722-current.tar.gz
		tar asterisk-core-sounds-en-g722-current.tar.gz
	fi
	#Make Docs # not needed
	#make progdocs
	
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
function FreePBX_conf
{
cat >> /etc/systemd/system/freepbx.service << EOF
[Unit]
Description=FreePBX VoIP Server
After=mysql.service

 
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/sbin/fwconsole start
ExecStop=/usr/sbin/fwconsole stop
 
[Install]
WantedBy=multi-user.target
EOF

cat >> /etc/logrotate.d/asterisk << EOF
/var/spool/mail/asterisk
/var/log/asterisk/*log
/var/log/asterisk/messages
/var/log/asterisk/full
/var/log/asterisk/dtmf
/var/log/asterisk/freepbx_dbug
/var/log/asterisk/fail2ban {
        weekly
        missingok
        rotate 4
        #compress
        notifempty
        sharedscripts
        create 0640 asterisk asterisk
        postrotate
        /usr/sbin/asterisk -rx 'logger reload' > /dev/null 2> /dev/null || true
        endscript
        su root root
}
EOF

}
function install_FreePBX
{
	
	#useradd -m asterisk
	adduser asterisk --disabled-password --shell /sbin/nologin --gecos "Asterisk User"
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
	ldconfig
	update-rc.d -f asterisk remove
	cd $asterisk_SRC\freepbx
	./start_asterisk start
	./install -n --dbpass $root_db_pass
	# Minimal module install
	fwconsole ma upgrade framework core voicemail sipsettings infoservices \
	featurecodeadmin logfiles callrecording cdr dashboard
	#my options
	fwconsole ma upgrade configedit backup asteriskinfo bulkhandler callforward certman cxpanel \
	disa fw_langpacks languages asterisk-cli cidlookup \
	blacklist dahdiconfig digium_phones 
	fwconsole restart
	fwconsole reload
	fwconsole chown
	FreePBX_conf
}
function setup_tftp
{
cat >> /etc/xinetd.d/tftp << EOF
service tftp
{
protocol        = udp
port            = 69
socket_type     = dgram
wait            = yes
user            = nobody
server          = /usr/sbin/in.tftpd
server_args     = /tftpboot
disable         = no
}
EOF

mkdir /tftpboot
chmod 777 /tftpboot
systemctl restart xinetd
}
function clean_up
{
	rm /usr/local/src/*.tar.gz
	rm /usr/local/src/*.tar.bz2
	rm /usr/local/src/*.tgz
	rm /var/lib/asterisk/sounds/*.tar.gz
}
##### Main #####
unpack_asterisk
install_iksemel
install_DHADI
install_LibPRI
install_jansson
install_asterisk
install_FreePBX
setup_tftp
clean_up
exit
####### END :) #######