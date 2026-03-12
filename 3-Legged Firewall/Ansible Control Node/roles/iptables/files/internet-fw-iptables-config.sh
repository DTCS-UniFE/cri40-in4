#!/bin/bash

# Flush delle regole esistenti e impostazione delle politiche di default
iptables -F
iptables -X
iptables -t nat -F
iptables -t mangle -F

# Imposta le politiche di default su ACCEPT temporaneamente
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

# Consente il traffico in loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Consenti il traffico SSH da qualsiasi origine (modificare secondo le necessità)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# NAT per le subnet verso Internet
iptables -t nat -A POSTROUTING -o enp0s8 -j MASQUERADE

# Consenti traffico in uscita HTTP e HTTPS per gli aggiornamenti e altro
iptables -A OUTPUT -o enp0s8 -p tcp -m multiport --dports 80,443 -m state --state NEW,ESTABLISHED -j ACCEPT

# Consenti risposte ai pacchetti in uscita (connessioni già stabilite)
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Imposta le politiche di default per rifiutare tutto il traffico non esplicitamente permesso
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Salva le regole
iptables-save > /etc/iptables/rules.v4
