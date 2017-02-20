#!/bin/bash
#
######################################################################
#
#	Name:		 	MYSQL_db_setup_script.sh
#	Author:			Chris Fedun 18/01/2017
#	Description:	MYSQL DataBase Setup Script Configuration
#
######################################################################
#####Constants#####
mailuser_passwd=$(pwgen -s 25)
drupaluser_passwd=$(pwgen -s 25)
domain_name=$1
Setup_dir='/root/initial_setup/mail/'
root_db_pass=$( cat $Setup_dir\MYSQL/pass.txt )
touch $Setup_dir\email/mailuser_passwd.txt
echo "$mailuser_passwd" >> $Setup_dir\email/mailuser_passwd.txt
chmod u=rw,go= $Setup_dir\email/mailuser_passwd.txt

touch $Setup_dir\drupal/drupaluser_passwd.txt
echo "$drupaluser_passwd" >> $Setup_dir\drupal/drupaluser_passwd.txt
chmod u=rw,go= $Setup_dir\drupal/drupaluser_passwd.txt

mysql --user=root --password=$root_db_pass << MYSQL_SCRIPT
CREATE DATABASE mailserver;

GRANT SELECT,INSERT,UPDATE,DELETE ON mailserver.* TO 'mailuser'@'127.0.0.1' IDENTIFIED BY "$mailuser_passwd";
USE mailserver;
CREATE TABLE IF NOT EXISTS \`virtual_domains\` (
 \`id\` int(11) NOT NULL auto_increment,
 \`name\` varchar(50) NOT NULL,
 PRIMARY KEY (\`id\`)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
 
USE mailserver;
CREATE TABLE IF NOT EXISTS \`virtual_users\` (
 \`id\` int(11) NOT NULL auto_increment,
 \`domain_id\` int(11) NOT NULL,
 \`email\` varchar(100) NOT NULL,
 \`password\` varchar(150) NOT NULL,
 PRIMARY KEY (\`id\`),
 UNIQUE KEY \`email\` (\`email\`),
 FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
 
USE mailserver;
CREATE TABLE IF NOT EXISTS \`virtual_aliases\` (
 \`id\` int(11) NOT NULL auto_increment,
 \`domain_id\` int(11) NOT NULL,
 \`source\` varchar(100) NOT NULL,
 \`destination\` varchar(100) NOT NULL,
 PRIMARY KEY (\`id\`),
 FOREIGN KEY (domain_id) REFERENCES virtual_domains(id) ON DELETE CASCADE
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
 
 REPLACE INTO \`mailserver\`.\`virtual_domains\` ( \`id\` , \`name\` ) VALUES ( '1', "$domain_name" );
 
CREATE DATABASE drupal;
CREATE USER drupaluser@localhost IDENTIFIED BY '$drupaluser_passwd';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,INDEX,ALTER,CREATE TEMPORARY TABLES,LOCK TABLES ON drupal.* TO drupaluser@localhost;
 FLUSH PRIVILEGES;
MYSQL_SCRIPT
 
exit
####### END :) #######