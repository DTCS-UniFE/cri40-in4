#!/usr/bin/env python3
import os

print("Stopping server-web...")
os.system("VBoxManage controlvm server-web poweroff || true")
print("Stopping server-db...")
os.system("VBoxManage controlvm server-db poweroff || true")
print("Stopping server-applications...")
os.system("VBoxManage controlvm server-applications poweroff || true")
