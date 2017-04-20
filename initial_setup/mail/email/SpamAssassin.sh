#!/bin/bash
#
######################################################################
#
#	Name:		 	SpamAssassin.sh
#	Author:			Chris Fedun 31/01/2017
#	Description:	SpamAssassin Setup Script 
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
#
######################################################################
#####Constants#####
domain_name=$1
User_name=$2
Setup_dir='/root/initial_setup/mail/'

function fix_bug 
{
	sed -i '
	s/return if !defined \$_\[0\];/return undef if !defined \$_\[0\];/
	' /usr/share/perl5/Mail/SpamAssassin/Util.pm
}
function enc_scan
{
	postconf smtpd_milters=unix:/spamass/spamass.sock
	postconf milter_connect_macros="i j {daemon_name} v {if_name} _"
	
	sed -i '
		s/OPTIONS="--create-prefs --max-children 5 --helper-home-dir"/\#OPTIONS="--create-prefs --max-children 5 --helper-home-dir"\nOPTIONS="--create-prefs --max-children 5 --helper-home-dir -x -u vmail"/
	' /etc/default/spamassassin
	
	sed -i '
		s/CRON=0/\#CRON=0\nCRON=1/
	' /etc/default/spamassassin
	
	systemctl enable spamassassin
	adduser spamass-milter debian-spamd
	service spamassassin restart
	service spamass-milter restart
}

function send_to_junk_folder 
{
	sed -i '
	/  \#sieve_after2 = (etc...)/ a\
	sieve_after = /etc/dovecot/sieve-after

	' /etc/dovecot/conf.d/90-sieve.conf
	
	mkdir /etc/dovecot/sieve-after
	touch /etc/dovecot/sieve-after/spam-to-folder.sieve
	echo 'require ["fileinto","mailbox"];' > /etc/dovecot/sieve-after/spam-to-folder.sieve
    echo " " >> /etc/dovecot/sieve-after/spam-to-folder.sieve
	echo 'if header :contains "X-Spam-Flag" "YES" {' >> /etc/dovecot/sieve-after/spam-to-folder.sieve
	echo ' fileinto :create "INBOX/Junk";' >> /etc/dovecot/sieve-after/spam-to-folder.sieve
	echo ' stop;' >> /etc/dovecot/sieve-after/spam-to-folder.sieve
	echo '}' >> /etc/dovecot/sieve-after/spam-to-folder.sieve
	
	
	sievec /etc/dovecot/sieve-after/spam-to-folder.sieve
	
}

function PSAD_filter
{
	cp $Setup_dir\email/PSAD.sieve /etc/dovecot/sieve-after/
	chmod 644 /etc/dovecot/sieve-after/PSAD.sieve
	sievec /etc/dovecot/sieve-after/PSAD.sieve
}

function Fail2Ban_filter
{
	cp $Setup_dir\email/Fail2Ban.sieve /etc/dovecot/sieve-after/
	chmod 644 /etc/dovecot/sieve-after/Fail2Ban.sieve
	sievec /etc/dovecot/sieve-after/Fail2Ban.sieve
}

function subscribe_admin
{
	cat >> /var/vmail/$domain_name/$User_name/Maildir/subscriptions <<- EOF
	INBOX.PSAD
	INBOX.Fail2Ban
	EOF
}

##### Main
# Fix Debian bug #739738
fix_bug

#Enable spam scanning with SpamAssassin
enc_scan
 
#Send Spam to the Junk Folder
send_to_junk_folder

# Enable PSAD and Fail2Ban Filters
PSAD_filter
Fail2Ban_filter

# subscribe the admin to the newly created PSAD and Fail2Ban boxes
subscribe_admin

#service dovecot restart
exit
#######END :) #######