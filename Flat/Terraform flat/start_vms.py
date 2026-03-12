#!/usr/bin/env python3
import os

print("Starting server-web...")
os.system("VBoxManage startvm server-web --type headless")
print("Starting server-db...")
os.system("VBoxManage startvm server-db --type headless")
print("Starting server-applications...")
os.system("VBoxManage startvm server-applications --type headless")
