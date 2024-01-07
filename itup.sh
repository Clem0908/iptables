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
ip6tables -F

# Loopback interface
iptables -A INPUT -i lo -j ACCEPT
ip6tables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT

# Default policies
iptables -P INPUT DROP
ip6tables -P INPUT DROP
iptables -P OUTPUT ACCEPT
ip6tables -P OUTPUT ACCEPT
iptables -P FORWARD DROP
ip6tables -P FORWARD DROP

iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# SSH protect against spamming
iptables -A INPUT -p tcp --dport 22 -m recent --update --seconds 60 --hitcount 4 --set -j DROP
iptables -A INPUT -p tcp --dport 22 -m recent --set

# SSH
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
ip6tables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT

# HTTP
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
ip6tables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT

# HTTPS
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
ip6tables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT

# KDE Connect
iptables -A INPUT -p tcp --dport 1714:1764 -j ACCEPT 
ip6tables -A INPUT -p tcp --dport 1714:1764 -j ACCEPT 
iptables -A INPUT -p udp --dport 1714:1764 -j ACCEPT 
ip6tables -A INPUT -p udp --dport 1714:1764 -j ACCEPT 

# Other packets
iptables -A INPUT -j DROP
ip6tables -A INPUT -j DROP

# Saving the configuration
iptables-save -f /etc/iptables/iptables.rules
ip6tables-save -f /etc/iptables/iptables.rules

# systemd reload unit
systemctl restart iptables
