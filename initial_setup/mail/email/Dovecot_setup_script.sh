#!/bin/bash
#
######################################################################
#
#	Name:		 	Dovecot_setup_script.sh
#	Author:			Chris Fedun 23/01/2017
#	Description:	Dovecot Setup Script 
#
######################################################################
#####Constants#####
conf_dir='/etc/dovecot/conf.d/'
Setup_dir='/root/initial_setup/mail/'
mailuser_passwd=$(cat $Setup_dir\email/mailuser_passwd.txt)
My_Cert="/etc/ssl/My_Certs/certs/mailserver_crt.pem"
My_Key="/etc/ssl/My_Certs/private/mailserver_key.pem"
domain_name=$1
#Setting up Dovecot

if [ ! -d "/var/vmail" ]; then
  mkdir /var/vmail
  groupadd -g 5000 vmail
  useradd -g vmail -u 5000 vmail -d /var/vmail -m
  chown -R vmail.vmail /var/vmail
  
 else
  groupadd -g 5000 vmail
  useradd -g vmail -u 5000 vmail -d /var/vmail -m
  chown -R vmail.vmail /var/vmail
fi

sed -i 's/\#disable_plaintext_auth = yes/\#disable_plaintext_auth = yes\ndisable_plaintext_auth = yes/' $conf_dir\10-auth.conf
sed -i 's/auth_mechanisms = plain/auth_mechanisms = plain login/' $conf_dir\10-auth.conf

sed -i 's/\#!include auth-sql.conf.ext/!include auth-sql.conf.ext/' $conf_dir\10-auth.conf
sed -i 's/!include auth-system.conf.ext/#!include auth-system.conf.ext/' $conf_dir\10-auth.conf

sed  -i '
/userdb [{]/ {
	N
		/  driver = sql/ {
			N
				/  args = \/etc\/dovecot\/dovecot-sql.conf.ext/ {
					N
						/[}]/ {
							N
								s_userdb {\n  driver = sql\n  args = /etc/dovecot/dovecot-sql.conf.ext\n}_userdb {\n  driver = static\n  args = uid=vmail gid=vmail home=/var/vmail/%d/%n\n  \# driver = sql\n  \# args = /etc/dovecot/dovecot-sql.conf.ext\n}_
							}
		}			
	}
}' $conf_dir\auth-sql.conf.ext


sed -i 's-mail_location = mbox:~/mail:INBOX=/var/mail/%u-\#mail_location = mbox:~/mail:INBOX=/var/mail/%u\nmail_location = maildir:/var/vmail/%d/%n/Maildir-' $conf_dir\10-mail.conf

sed -i '
/  \# The default however depends on the underlying mail storage format./ {
	N
		s_  \# The default however depends on the underlying mail storage format.\n  \#separator =_  \# The default however depends on the underlying mail storage format.\n  \#separator =\n  separator = /_
}' $conf_dir\10-mail.conf

sed -i '
/  \# Postfix smtp-auth/ {
	N
		/  \#unix_listener \/var\/spool\/postfix\/private\/auth [{]/ {
			N
				/  \#  mode = 0666/ {
					N
						/  \#[}]/ {
							N
								s:  \# Postfix smtp-auth\n  \#unix_listener /var/spool/postfix/private/auth {\n  \#  mode = 0666\n  \#}:  \# Postfix smtp-auth\n  unix_listener /var/spool/postfix/private/auth {\n    mode = 0660\n    user = postfix\n    group = postfix\n  }:
						}
				}
		}
}' $conf_dir\10-master.conf



sed -i 's/ssl = no/ssl = yes/' $conf_dir\10-ssl.conf
sed -i "
/\#ssl_key = <\/etc\/dovecot\/private\/dovecot.pem/ a\
ssl_cert = <$My_Cert\nssl_key = <$My_Key
" $conf_dir\10-ssl.conf

sed -i 's:namespace inbox {:namespace inbox {\n  mailbox INBOX/Junk {\n   auto = subscribe\n   special_use = \\Junk\n  }\n  mailbox INBOX/Trash {\n   auto = subscribe\n   special_use = \\Trash\n  }\n:' $conf_dir\15-mailboxes.conf

echo "driver = mysql" >> /etc/dovecot/dovecot-sql.conf.ext
echo "connect = host=127.0.0.1 dbname=mailserver user=mailuser password=$mailuser_passwd" >> /etc/dovecot/dovecot-sql.conf.ext 
echo "default_pass_scheme = SHA256-CRYPT" >> /etc/dovecot/dovecot-sql.conf.ext
echo "password_query = SELECT email as user, password FROM virtual_users WHERE email='%u';" >> /etc/dovecot/dovecot-sql.conf.ext




chown root:root /etc/dovecot/dovecot-sql.conf.ext
chmod go= /etc/dovecot/dovecot-sql.conf.ext

# Make Dovecot listen to Postfix LMTP Connections
sed -i '
/service lmtp {/ {
	N
		/  unix_listener lmtp {/ {
			N
				/    \#mode = 0666/ {
					N
						/  }/ {
							N
								s:service lmtp {\n  unix_listener lmtp {\n    \#mode = 0666\n  }:service lmtp {\n  unix_listener /var/spool/postfix/private/dovecot-lmtp {\n    group = postfix\n    mode = 0660\n    user = postfix\n  }:
						}
				}
		
		}
}' $conf_dir\10-master.conf
service dovecot restart

#Enable server-side mail rules
sed -i '
/  \#mail_plugins = \$mail_plugins/ a\
  mail_plugins = \$mail_plugins sieve
' $conf_dir\20-lmtp.conf

service dovecot restart

exit
#######END :) #######