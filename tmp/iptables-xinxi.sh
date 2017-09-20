#!/usr/bin/env bash

# Generated by iptables-save v1.4.7 on Wed Oct 21 10:50:06 2015
*nat
:PREROUTING ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A POSTROUTING -s 10.8.0.0/24 -j SNAT --to-source 10.170.149.224
COMMIT
# Completed on Wed Oct 21 10:50:06 2015
# Generated by iptables-save v1.4.7 on Wed Oct 21 10:50:06 2015
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [3613313:677971214]
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp -s 10.26.208.129 --dport 10050 -j ACCEPT


# nfs
-A INPUT -p tcp -m state --state NEW -m tcp --dport 111 -j ACCEPT
-A INPUT -p udp -m state --state NEW -m udp --dport 111 -j ACCEPT

-A INPUT -p tcp -m state --state NEW --dport 2049 -j ACCEPT
-A INPUT -p udp -m state --state NEW --dport 2049 -j ACCEPT
# nginx
-A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 8080 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 9091 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 1985 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 6080 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 9092 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 9095 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 8012 -j ACCEPT
-A INPUT -s 10.116.139.116/32 -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT
-A INPUT -s 10.116.67.225/32 -p tcp -m state --state NEW -m tcp --dport 3306 -j ACCEPT
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A FORWARD -j REJECT --reject-with icmp-host-prohibited
COMMIT
# Completed on Wed Oct 21 10:50:06 201


systemctl stop firewalld
systemctl disable firewalld
systemctl start iptables
systemctl enable iptables