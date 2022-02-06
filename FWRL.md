# IPTABLES FIREWALL RULES GUIDE

Delete rules:

iptables -D "RULE-TO-DROP"
iptables -L --line-numbers --> iptabes -D INPUT/OUTPUT "num"


# **PHASE 1 BASIC FIREWALL SETUP** 

// Allow ALL incoming example of a service (ssh)

>iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
>iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

//Allow all incoming for MULTIPLE SERVICES

>iptables -A INPUT -p tcp -m multiport --dports 22,80,443 -m state --state NEW,ESTABLISHED -j ACCEPT
>iptables -A OUTPUT -p tcp -m multiport --sports 22,80,443 -m state --state ESTABLISHED -j ACCEPT

//Allow logging

>iptables -P INPUT DROP
>iptables -P OUTPUT DROP

//drop and accept

>iptables -P INPUT DROP
>iptables -P OUTPUT DROP


>iptables -P INPUT ACCEPT
>iptables -P OUTPUT ACCEPT


# ALLOW AND DISABLE INTERNET ACCESS

#inet

>iptables -I INPUT -p udp --sport 53 -s (dns server addr) -j ACCEPT
>iptables -I OUTPUT -p udp --dport 43 -d (dns server addr) -j ACCEPT

>iptables -I INPUT -p tcp -m multiport --sports 80,443 -j ACCEPT
>iptables -I OUTPUT -p tcp -m multiport --dports 80,443 -j ACCEPT

#nonet 

>iptables -D INPUT -p udp --sport 53 -s (dns server addr) -j ACCEPT
>iptables -D OUTPUT -p udp --dport 43 -d (dns server addr) -j ACCEPT

>iptables -D INPUT -p tcp -m multiport --sports 80,443 -j ACCEPT
>iptables -D OUTPUT -p tcp -m multiport --dports 80,443 -j ACCEPT


#DNS
>iptables -A INPUT -p udp --sport 53 -s 10.40.40.40, 10.40.40.30 -j ACCEPT 
>iptables -A OUTPUT -p udp --dport 53 -d 10.40.40.40, 10.40.40.30 -j ACCEPT

# ACCESSORY RULES

Client SSH (enable when sending over mysql database files, disable after)

>iptables -I INPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
>iptables -I OUTPUT -p tcp --sport 22 -m state --state NEW,ESTABLISHED -j ACCEPT

block a particular IP address:

>blocked_ip="x.x.x.x"
>iptables -A INPUT -s "$blocked_ip" -j DROP

allow loopback access
>iptables -A INPUT -i lo -j ACCEPT
>iptables -A OUTPUT -o lo -j ACCEPT

prevent DoS attack

>iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT