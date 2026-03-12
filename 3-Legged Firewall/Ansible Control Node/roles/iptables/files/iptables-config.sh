#!/bin/bash

# Reset delle regole di iptables
iptables -F
iptables -X
iptables -t nat -F
iptables -t mangle -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Consenti traffico locale su loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Consenti traffico SSH in entrata sull'interfaccia host-only
iptables -A INPUT -i enp0s17 -p tcp --dport 22 -j ACCEPT
iptables -A OUTPUT -o enp0s17 -p tcp --sport 22 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Consenti traffico DNS in uscita
iptables -A OUTPUT -o enp0s8 -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -o enp0s8 -p tcp --dport 53 -j ACCEPT

# Consenti risposte DNS in entrata
iptables -A INPUT -i enp0s8 -p udp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -i enp0s8 -p tcp --sport 53 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Blocca il traffico tra sottoreti diverse
iptables -A FORWARD -i enp0s9 -o enp0s10 -j DROP
iptables -A FORWARD -i enp0s10 -o enp0s9 -j DROP
iptables -A FORWARD -i enp0s9 -o enp0s16 -j DROP
iptables -A FORWARD -i enp0s16 -o enp0s9 -j DROP
iptables -A FORWARD -i enp0s10 -o enp0s16 -j DROP
iptables -A FORWARD -i enp0s16 -o enp0s10 -j DROP

# Consenti traffico FORWARD per comunicazioni all'interno della stessa sottorete
iptables -A FORWARD -i enp0s9 -o enp0s9 -j ACCEPT
iptables -A FORWARD -i enp0s10 -o enp0s10 -j ACCEPT
iptables -A FORWARD -i enp0s16 -o enp0s16 -j ACCEPT

# Consenti traffico di gestione su host-only
iptables -A FORWARD -i enp0s17 -o enp0s17 -j ACCEPT

# Abilita NAT per le subnet
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

# Consenti traffico FORWARD per e dalle subnet specificate verso Internet
iptables -A FORWARD -i enp0s9 -o enp0s8 -j ACCEPT
iptables -A FORWARD -i enp0s10 -o enp0s8 -j ACCEPT
iptables -A FORWARD -i enp0s16 -o enp0s8 -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s9 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s10 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i enp0s8 -o enp0s16 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Consenti traffico HTTP e HTTPS in uscita per apt-get
iptables -A OUTPUT -o enp0s8 -p tcp --dport 80 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -o enp0s8 -p tcp --dport 443 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT

# Consenti traffico HTTP e HTTPS in entrata in risposta a richieste in uscita
iptables -A INPUT -i enp0s8 -p tcp --sport 80 -m conntrack --ctstate ESTABLISHED -j ACCEPT
iptables -A INPUT -i enp0s8 -p tcp --sport 443 -m conntrack --ctstate ESTABLISHED -j ACCEPT

# Consenti ping in uscita
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT

iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT

# Salva le regole
iptables-save > /etc/iptables/rules.v4
