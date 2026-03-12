#!/bin/bash

# Reset delle regole di iptables
sudo iptables -F
sudo iptables -X
sudo iptables -Z
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t nat -Z

# Consenti il traffico in ingresso e in uscita per le connessioni già stabilite
sudo iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Consenti il traffico in ingresso per SSH sulla porta 22 e HTTP sulla porta 80
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Consenti traffico di gestione su host-only
iptables -A FORWARD -i enp0s17 -o enp0s17 -j ACCEPT

# Abilita NAT
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

# Consenti ping in uscita (ICMP)
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT

# Consenti traffico HTTP/HTTPS in uscita per aggiornamenti apt-get
iptables -A OUTPUT -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -A OUTPUT -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT

# Consenti il traffico in ingresso per apt-get update
iptables -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp --dport 11371 -j ACCEPT

# Consenti il traffico in ingresso per le risposte di apt-get update
iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT

# Abilita il forwarding del traffico IP
sudo sysctl -w net.ipv4.ip_forward=1

# Salva le regole
iptables-save > /etc/iptables/rules.v4
