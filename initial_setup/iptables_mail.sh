#!/bin/sh
#
######################################################################
#
#	Name:		 	iptables_mail.sh
#	Author:			Chris Fedun 17/12/2016
#	Description:	Base IPTABLES Firewall Configuration for Mail Server
#	Based on:		http://cipherdyne.org/LinuxFirewalls/ch01/
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
#####Constants#####
IPTABLES=/sbin/iptables
IP6TABLES=/sbin/ip6tables
MODPROBE=/sbin/modprobe
INT_NET=192.168.10.0/24
IFACE_INT=eth0
IFACE_EXT=eth0
DNS_SVR_IP=192.168.10.253
WEB_SVR_IP=192.168.10.253
EMAIL_SVR_IP=192.168.10.253
CALL_MANAGER=192.168.10.252
Setup_dir='/root/initial_setup/mail/'

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
$IPTABLES -A INPUT -p tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A INPUT -p udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
# SMTP and SMTPS #
$IPTABLES -A INPUT -p tcp --dport 25 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A INPUT -p tcp --dport 465 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A INPUT -p tcp --dport 587 -m conntrack --ctstate NEW -j ACCEPT
# IMAP and IMAPS #                     
$IPTABLES -A INPUT -p tcp --dport 143 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A INPUT -p tcp --dport 993 -m conntrack --ctstate NEW -j ACCEPT
# POP3 and POP3S #                     
$IPTABLES -A INPUT -p tcp --dport 110 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A INPUT -p tcp --dport 995 -m conntrack --ctstate NEW -j ACCEPT
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
# SMTP and SMTPS #
$IPTABLES -A OUTPUT -p tcp --dport 25 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 465 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 587 -m conntrack --ctstate NEW -j ACCEPT
# IMAP and IMAPS #                     
$IPTABLES -A OUTPUT -p tcp --dport 143 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 993 -m conntrack --ctstate NEW -j ACCEPT
# POP3 and POP3S #                     
$IPTABLES -A OUTPUT -p tcp --dport 110 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A OUTPUT -p tcp --dport 995 -m conntrack --ctstate NEW -j ACCEPT
$IPTABLES -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT

### Default OUTPUT LOG rule ###
$IPTABLES -A OUTPUT ! -o lo -j LOG --log-prefix "DROP " --log-ip-options --log-tcp-options

### Make sure that loopback traffic is accepted. ###
$IPTABLES -A OUTPUT -o lo -j ACCEPT







##### Forwarding #####
echo "[+] Enabling IP forwarding..."
echo 1 > /proc/sys/net/ipv4/ip_forward

### Save ###
echo "[+] Saving rules..."
iptables-save > ipt.save


exit

# END  :)
### EOF ###