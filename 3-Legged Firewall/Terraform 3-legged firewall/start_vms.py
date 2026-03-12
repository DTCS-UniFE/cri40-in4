#!/usr/bin/env python3
import os

print("Starting internet-fw...")
os.system("VBoxManage startvm internet-fw --type headless")
print("Starting subnet_a-nginx...")
os.system("VBoxManage startvm subnet_a-nginx --type headless")
print("Starting subnet_b-vm-01...")
os.system("VBoxManage startvm subnet_b-vm-01 --type headless")
print("Starting internal-fw...")
os.system("VBoxManage startvm internal-fw --type headless")
print("Starting dmz-suricata...")
os.system("VBoxManage startvm dmz-suricata --type headless")
print("Starting dmz-wazuh...")
os.system("VBoxManage startvm dmz-wazuh --type headless")
print("Starting dmz-db...")
os.system("VBoxManage startvm dmz-db --type headless")
print("Starting dmz-honeypot...")
os.system("VBoxManage startvm dmz-honeypot --type headless")
