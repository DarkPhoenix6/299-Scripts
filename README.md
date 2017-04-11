# 299-Scripts

The Call Manager Script does the following:

1.	Downloads Asterisk and required dependencies that need to be built from source.
2.	Installs dependencies that don’t need to be compiled.
3.	Uses pwgen to create secure passwords for the mail_user, drupal_user, MySQL root password, the Drupal admin password. Save the passwords to files readable only by the root user
4.	It creates self-signed certificates
5.	Creates the Email-to-SMS database and imports the data.
6.	Unpackages Asterisk and its dependencies, DHADI, LibPRI, Jansson, Iksemel, PJProject, and FreePBX.
7.	Then moves the unpacked files to the correct location.
8.	It then compiles and installs Iksemel. 
9.	It then does the same to DHADI, then LibPRI, then Jansson.
10.	It then executes an Expect script to install and configure Asterisk’s prerequisites.
11.	Then it edits the PJProject to allow compilation on the Raspberry Pi.
12.	It then compiles the PJProject, compiles Asterisk.
13.	Configures asterisk install options, and installs PJProject and Asterisk.
14.	It configures log rotation for asterisk.
15.	It configures the system rc files.
16.	it prepares to install FreePBX,
17.	adding a system user named “asterisk” and disables login and disables the password.
18.	It changes the owner of the /var/run/asterisk directory to asterisk.
19.	It Recursively changes the owner of the /etc/asterisk, /var/lib/asterisk, /var/log/asterisk, /var/spool/asterisk, and /usr/lib/asterisk directories and their contents to the asterisk user.
20.	It removes the /var/www/html folder. It is not needed.
21.	It configures Apache2;
22.	It enables Apache’s SSL and rewrite modules and enables the HTTPS virtual host.
23.	For security, it creates a HTTP to HTTPS rewrite for secure web access.
24.	Configures Apache to use the certificates that were created earlier.
25.	It changes the max-upload size to 20 Mb to allow larger Music-on-Hold files.
26.	It backups the original Apache configuration file. 
27.	Then it allows the asterisk user to be the user that apache uses.
28.	It then configures database access via ODBC.
29.	It then prevents asterisk from starting at boot, and it ensures asterisk is running.
30.	It then installs FreePBX and sets up the database installs necessary modules and some other helpful modules.
31.	It then fixes permissions and corrects owners, reloads configuration and enables FreePBX to start Asterisk, and enables FreePBX to start at boot.
32.	It configures xinetd as a TFTP server to give the client the option of using IP-phones. 
33.	It then removes any leftover archives.
34.	It then configures chains in iptables to chains to log dropped packets in the filter and mangle tables. Rules are created to allow only necessary ports and services, limit ICMP, prevent most basic DDoS attacks, allow communication via the internal interface to the mail server, drop invalid packets, drop suspicious packets, limit connections and NEW connections, etc.
35.	It configures persistent iptables
36.	It installs fail2ban and Configures Fail2Ban to ban an IP address for 20 minutes after 3 after 6 failed login attempts within 30 minutes by default. Configures email notifications. Configures jails to monitor SSH logins, xinetd, Apache, Apache Overflows, Apache nohome, Asterisk TCP, Asterisk UDP,
37.	Installs and configures PSAD to monitor iptables logs to detect scan or attack attempts, sets autoban actions, configures logging, updates PSAD signatures, sets ban times, configures danger levels, configures notifications, enables auto-IDS, sets minimum Danger Level for Auto-IDS activation,
38.	Runs MySQL secure installation script.

The Web/Email Server Script does the following: