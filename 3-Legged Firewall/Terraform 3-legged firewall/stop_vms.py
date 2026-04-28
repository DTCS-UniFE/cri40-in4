#!/usr/bin/env python3
import os

print("Stopping internet-fw...")
os.system("VBoxManage controlvm internet-fw poweroff || true")
print("Stopping subnet_a-nginx...")
os.system("VBoxManage controlvm subnet_a-nginx poweroff || true")
print("Stopping subnet_b-vm-01...")
os.system("VBoxManage controlvm subnet_b-vm-01 poweroff || true")
print("Stopping internal-fw...")
os.system("VBoxManage controlvm internal-fw poweroff || true")
print("Stopping dmz-suricata...")
os.system("VBoxManage controlvm dmz-suricata poweroff || true")
print("Stopping dmz-wazuh...")
os.system("VBoxManage controlvm dmz-wazuh poweroff || true")
print("Stopping dmz-db...")
os.system("VBoxManage controlvm dmz-db poweroff || true")
print("Stopping dmz-honeypot...")
os.system("VBoxManage controlvm dmz-honeypot poweroff || true")
