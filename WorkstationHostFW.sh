#!/bin/bash

#HTTP,HTTPS
iptables -A INPUT -p tcp -m multiport --sports 80,443 -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

#DNS - ip addr would point to dns server and/or backup dns server
iptables -A INPUT -p udp --sport 53 -s 10.40.40.40,10.40.40.30 -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -d 10.40.40.40,10.40.40.30 -j ACCEPT

#LDAP User Auth - ip points to ad server
iptables -A INPUT -p tcp --sport 389 -s 10.40.40.40 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 389 -d 10.40.40.40 -j ACCEPT

#NTP
iptables -A INPUT -p udp --sport 123 -s 10.40.40.40 -j ACCEPT
iptables -A OUTPUT -p udp --dport 123 -d 10.40.40.40 - ACCEPT

#Logging
iptables -A INPUT -j LOG
iptables -A OUTPUT -j LOG

#Drop ALL
iptables -P INPUT DROP
iptables -P OUTPUT DROP
