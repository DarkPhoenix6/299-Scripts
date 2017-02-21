#!/bin/sh
#
######################################################################
#
#	Name:		 	iptables.sh
#	Author:			Chris Fedun 17/12/2016
#	Description:	Base IPTABLES Firewall Configuration for Firewall Device
#	Based on:		http://cipherdyne.org/LinuxFirewalls/ch01/
#
######################################################################
#####Constants#####
IPTABLES=/sbin/iptables
IP6TABLES=/sbin/ip6tables
MODPROBE=/sbin/modprobe
INT_NET=192.168.10.0/24
IFACE_INT=eth0:0
IFACE_EXT=eth0
DNS_SVR_IP=192.168.10.253
WEB_SVR_IP=192.168.10.253
EMAIL_SVR_IP=192.168.10.253
CALL_MANAGER=192.168.10.252
Setup_dir='/root/initial_setup/'
### Flush existing rules and set chain policy settings to DROP. ###
echo "[+] Flushing existing iptables rules..."

$IPTABLES -F
$IPTABLES -F -t nat
$IPTABLES -X
$IPTABLES -P INPUT DROP
$IPTABLES -P OUTPUT DROP
$IPTABLES -P FORWARD DROP

### This policy does not handle IPv6 traffic except to DROP it. ###
echo "[+] Disabling IPv6 traffic..."

$IP6TABLES -P INPUT DROP
$IP6TABLES -P OUTPUT DROP
$IP6TABLES -P FORWARD DROP

### Load connection-tracking modules. ###
$MODPROBE ip_conntrack
$MODPROBE iptable_nat
$MODPROBE ip_conntrack_ftp
$MODPROBE ip_nat_ftp

##### INPUT chain #####
echo "[+] Setting up INPUT chain..."

### State tracking rules ###
$IPTABLES -A INPUT -m conntrack --ctstate INVALID -j LOG --log-prefix "DROP INVALID " --log-ip-options --log-tcp-options
$IPTABLES -A INPUT -m conntrack --ctstate INVALID -j DROP
$IPTABLES -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

### Anti-spoofing rules ###
$IPTABLES -A INPUT -i $IFACE_INT ! -s  $INT_NET -j LOG --log-prefix "SPOOFED PKT "
$IPTABLES -A INPUT -i $IFACE_INT ! -s  $INT_NET -j DROP

### ACCEPT rules ###
$IPTABLES -A INPUT -i $IFACE_INT -p tcp -s $INT_NET --dport 22 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A INPUT -i $IFACE_INT -p tcp -s $INT_NET --dport 8443 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

### Default INPUT LOG rule ###
$IPTABLES -A INPUT ! -i lo -j LOG --log-prefix "DROP " --log-ip-options --log-tcp-options

### Make sure that loopback traffic is accepted ###
$IPTABLES -A INPUT -i lo -j ACCEPT

##### OUTPUT chain #####
echo "[+] Setting up OUTPUT chain..."
### State tracking rules ###
$IPTABLES -A OUTPUT -m conntrack --ctstate INVALID -j LOG --log-prefix "DROP INVALID " --log-ip-options --log-tcp-options
$IPTABLES -A OUTPUT -m conntrack --ctstate INVALID -j DROP
$IPTABLES -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

### ACCEPT rules for allowing connections out. ###
$IPTABLES -A OUTPUT -p tcp --dport 21 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 25 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 43 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 4321 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A OUTPUT -p udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT

### Default OUTPUT LOG rule ###
$IPTABLES -A OUTPUT ! -o lo -j LOG --log-prefix "DROP " --log-ip-options --log-tcp-options

### Make sure that loopback traffic is accepted. ###
$IPTABLES -A OUTPUT -o lo -j ACCEPT

##### FORWARD chain #####
echo "[+] Setting up FORWARD chain..."

### State tracking rules ###
$IPTABLES -A FORWARD -m conntrack --ctstate INVALID -j LOG --log-prefix "DROP INVALID " --log-ip-options --log-tcp-options
$IPTABLES -A FORWARD -m conntrack --ctstate INVALID -j DROP
$IPTABLES -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

### Anti-spoofing rules ###
$IPTABLES -A FORWARD -i $IFACE_INT ! -s  $INT_NET -j LOG --log-prefix "SPOOFED PKT "
$IPTABLES -A FORWARD -i $IFACE_INT ! -s  $INT_NET -j DROP

### ACCEPT rules ###
$IPTABLES -A FORWARD -p tcp -i $IFACE_INT -s $INT_NET --dport 21 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A FORWARD -p tcp -i $IFACE_INT -s $INT_NET --dport 22 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A FORWARD -p tcp -i $IFACE_INT -s $INT_NET --dport 25 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A FORWARD -p tcp -i $IFACE_INT -s $INT_NET --dport 43 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A FORWARD -p tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A FORWARD -p tcp --dport 80 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A FORWARD -p tcp --dport 443 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A FORWARD -p tcp -i $IFACE_INT -s $INT_NET --dport 4321 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A FORWARD -p udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A FORWARD -p icmp --icmp-type echo-request -j ACCEPT
## Rules to allow conections to/from the internal Email server ##
# SMTP and SMTPS #
$IPTABLES -A FORWARD -p tcp --dport 25 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A FORWARD -p tcp --dport 465 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A FORWARD -p tcp --dport 587 -m conntrack --ctstate NEW -j ACCEPT
# IMAP and IMAPS #                     
$IPTABLES -A FORWARD -p tcp --dport 143 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A FORWARD -p tcp --dport 993 -m conntrack --ctstate NEW -j ACCEPT
# POP3 and POP3S #                     
$IPTABLES -A FORWARD -p tcp --dport 110 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A FORWARD -p tcp --dport 995 -m conntrack --ctstate NEW -j ACCEPT
##### allow SIP phone calls
$IPTABLES -A FORWARD -p tcp --dport 5060 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A FORWARD -p udp --dport 5060 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A FORWARD -p tcp --dport 5061 -m conntrack --ctstate NEW -j ACCEPT

### Default FORWARD LOG rule ###
$IPTABLES -A FORWARD ! -i lo -j LOG --log-prefix "DROP " --log-ip-options --log-tcp-options


##### NAT rules #####
echo "[+] Setting up NAT rules..."

$IPTABLES -t nat -A PREROUTING -p tcp --dport 80 -i $IFACE_EXT -j DNAT --to $WEB_SVR_IP\:80
$IPTABLES -t nat -A PREROUTING -p tcp --dport 443 -i $IFACE_EXT -j DNAT --to $WEB_SVR_IP\:443
$IPTABLES -t nat -A PREROUTING -p tcp --dport 53 -i $IFACE_EXT -j DNAT --to $DNS_SVR_IP\:53
$IPTABLES -t nat -A PREROUTING -p udp --dport 53 -i $IFACE_EXT -j DNAT --to $DNS_SVR_IP\:53
## Rules to nat conections to internal Email server ##
# SMTP and SMTPS #
$IPTABLES -t nat -A PREROUTING -p tcp --dport 25 -i $IFACE_EXT -j DNAT --to $EMAIL_SVR_IP\:25
$IPTABLES -t nat -A PREROUTING -p tcp --dport 465 -i $IFACE_EXT -j DNAT --to $EMAIL_SVR_IP\:465
$IPTABLES -t nat -A PREROUTING -p tcp --dport 587 -i $IFACE_EXT -j DNAT --to $EMAIL_SVR_IP\:587
# IMAP and IMAPS #
$IPTABLES -t nat -A PREROUTING -p tcp --dport 143 -i $IFACE_EXT -j DNAT --to $EMAIL_SVR_IP\:143
$IPTABLES -t nat -A PREROUTING -p tcp --dport 993 -i $IFACE_EXT -j DNAT --to $EMAIL_SVR_IP\:993
# POP3 and POP3S #
$IPTABLES -t nat -A PREROUTING -p tcp --dport 110 -i $IFACE_EXT -j DNAT --to $EMAIL_SVR_IP\:110
$IPTABLES -t nat -A PREROUTING -p tcp --dport 995 -i $IFACE_EXT -j DNAT --to $EMAIL_SVR_IP\:995
##### Rules to allow SIP phone calls
$IPTABLES -t nat -A PREROUTING -p tcp --dport 5060 -i $IFACE_EXT -j DNAT --to $CALL_MANAGER\:5060
$IPTABLES -t nat -A PREROUTING -p udp --dport 5060 -i $IFACE_EXT -j DNAT --to $CALL_MANAGER\:5060
$IPTABLES -t nat -A PREROUTING -p tcp --dport 5061 -i $IFACE_EXT -j DNAT --to $CALL_MANAGER\:5061
# POSTROUTING rule
$IPTABLES -t nat -A POSTROUTING -s $INT_NET -o $IFACE_EXT -j MASQUERADE


##### Forwarding #####
echo "[+] Enabling IP forwarding..."
echo 1 > /proc/sys/net/ipv4/ip_forward
##### Basic DDos Prevention #####
sudo bash $Setup_dir\ddos_protection.sh
### Save ###
echo "[+] Saving rules..."
iptables-save > ipt.save


exit

# END  :)
### EOF ###