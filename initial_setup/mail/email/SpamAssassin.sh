#!/bin/bash
#
######################################################################
#
#	Name:		 	SpamAssassin.sh
#	Author:			Chris Fedun 31/01/2017
#	Description:	SpamAssassin Setup Script 
#
######################################################################
#####Constants#####
domain_name=$1

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
	echo ' fileinto :create "INBOX.Junk";' >> /etc/dovecot/sieve-after/spam-to-folder.sieve
	echo ' stop;' >> /etc/dovecot/sieve-after/spam-to-folder.sieve
	echo '}' >> /etc/dovecot/sieve-after/spam-to-folder.sieve
	
	
	sievec /etc/dovecot/sieve-after/spam-to-folder.sieve
	
	service dovecot restart
	
}
##### Main
# Fix Debian bug #739738
fix_bug

#Enable spam scanning with SpamAssassin
enc_scan
 
#Send Spam to the Junk Folder
send_to_junk_folder

exit
#######END :) #######