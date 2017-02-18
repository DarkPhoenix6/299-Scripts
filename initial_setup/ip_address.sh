#####IP ADDRESS#####
echo "# interfaces(5) file used by ifup(8) and ifdown(8)

# Please note that this file is written to be used with dhcpcd
# For static IP, consult /etc/dhcpcd.conf and 'man dhcpcd.conf'

# Include files from /etc/network/interfaces.d:
source-directory /etc/network/interfaces.d

auto lo
iface lo inet loopback

auto eth0
allow-hotplug eth0
iface eth0 inet static
address 192.168.10.253
netmask 255.255.255.0
gateway 192.168.10.254
broadcast 192.168.10.255
network 192.168.10.0
dns-nameservers 8.8.8.8 8.8.4.4


allow-hotplug wlan0
iface wlan0 inet manual" > /etc/network/interfaces

/etc/init.d/networking restart