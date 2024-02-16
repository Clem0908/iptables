#!/bin/zsh

if [ $(id -g) -ne 0 ]
then
	echo "You must be root to run this script."
	exit -1
fi

#Enable on boot
systemctl enable iptables

# Flush old tables
iptables -F

# Loopback interface
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Default policies
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD DROP

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# SSH protect against spamming
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent     --update --seconds 60 --hitcount 4 -j DROP
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent     --set

# SSH
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT

# HTTP
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT

# HTTPS
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT

# KDE Connect
iptables -A INPUT -p tcp --dport 1714:1764 -j ACCEPT 
iptables -A INPUT -p udp --dport 1714:1764 -j ACCEPT 

# Star Wars: Battlefront II (2005) - LAN
iptables -A INPUT -p udp --dport 3656 -j ACCEPT
iptables -A INPUT -p udp --dport 3658:3659 -j ACCEPT

# Other packets
iptables -A INPUT -j DROP

# Saving the configuration
iptables-save -f /etc/iptables/iptables.rules

# systemd reload unit
systemctl restart iptables

iptables -L
