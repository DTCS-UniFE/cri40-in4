terraform {
  required_providers {
    virtualbox = {
      source = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

resource "virtualbox_vm" "internet-fw" {
  name      = "internet-fw"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "virtualbox_vm" "subnet_a-nginx" {
  name      = "subnet_a-nginx"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "virtualbox_vm" "subnet_b-vm-01" {
  name      = "subnet_b-vm-01"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "virtualbox_vm" "internal-fw" {
  name      = "internal-fw"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "virtualbox_vm" "dmz-suricata" {
  name      = "dmz-suricata"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "1024 mib"
  user_data = file("user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "virtualbox_vm" "dmz-wazuh" {
  name      = "dmz-wazuh"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "virtualbox_vm" "dmz-db" {
  name      = "dmz-db"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "virtualbox_vm" "dmz-honeypot" {
  name      = "dmz-honeypot"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "null_resource" "configure_networks" {
  depends_on = [
    virtualbox_vm.internet-fw,
    virtualbox_vm.subnet_a-nginx,
    virtualbox_vm.subnet_b-vm-01,
    virtualbox_vm.internal-fw,
    virtualbox_vm.dmz-suricata,
    virtualbox_vm.dmz-wazuh,
    virtualbox_vm.dmz-db,
    virtualbox_vm.dmz-honeypot,
  ]

  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm internet-fw poweroff || true
      sleep 5
      VBoxManage modifyvm internet-fw --nic2 nat
      VBoxManage modifyvm internet-fw --nic3 intnet --intnet3 subnet_a
      VBoxManage startvm internet-fw --type headless
    EOT
  }

  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm subnet_a-nginx poweroff || true
      sleep 5
      VBoxManage modifyvm subnet_a-nginx --nic3 intnet --intnet3 subnet_a
      VBoxManage startvm subnet_a-nginx --type headless
    EOT
  }

  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm subnet_b-vm-01 poweroff || true
      sleep 5
      VBoxManage modifyvm subnet_b-vm-01 --nic4 intnet --intnet4 subnet_b
      VBoxManage startvm subnet_b-vm-01 --type headless
    EOT
  }

  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm internal-fw poweroff || true
      sleep 5
      VBoxManage modifyvm internal-fw --nic2 nat
      VBoxManage modifyvm internal-fw --nic3 intnet --intnet3 subnet_a
      VBoxManage modifyvm internal-fw --nic4 intnet --intnet4 subnet_b
      VBoxManage modifyvm internal-fw --nic5 intnet --intnet5 subnet_dmz
      VBoxManage startvm internal-fw --type headless
    EOT
  }

  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm dmz-suricata poweroff || true
      sleep 5
      VBoxManage modifyvm dmz-suricata --nic5 intnet --intnet5 subnet_dmz
      VBoxManage startvm dmz-suricata --type headless
    EOT
  }

  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm dmz-wazuh poweroff || true
      sleep 5
      VBoxManage modifyvm dmz-wazuh --nic5 intnet --intnet5 subnet_dmz
      VBoxManage startvm dmz-wazuh --type headless
    EOT
  }

  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm dmz-db poweroff || true
      sleep 5
      VBoxManage modifyvm dmz-db --nic5 intnet --intnet5 subnet_dmz
      VBoxManage startvm dmz-db --type headless
    EOT
  }

  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm dmz-honeypot poweroff || true
      sleep 5
      VBoxManage modifyvm dmz-honeypot --nic5 intnet --intnet5 subnet_dmz
      VBoxManage startvm dmz-honeypot --type headless
    EOT
  }
}

output "internet-fw_hostonly_ip" {
  value       = virtualbox_vm.internet-fw.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di internet-fw"
}

output "subnet_a-nginx_hostonly_ip" {
  value       = virtualbox_vm.subnet_a-nginx.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di subnet_a-nginx"
}

output "subnet_b-vm-01_hostonly_ip" {
  value       = virtualbox_vm.subnet_b-vm-01.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di subnet_b-vm-01"
}

output "internal-fw_hostonly_ip" {
  value       = virtualbox_vm.internal-fw.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di internal-fw"
}

output "dmz-suricata_hostonly_ip" {
  value       = virtualbox_vm.dmz-suricata.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di dmz-suricata"
}

output "dmz-wazuh_hostonly_ip" {
  value       = virtualbox_vm.dmz-wazuh.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di dmz-wazuh"
}

output "dmz-db_hostonly_ip" {
  value       = virtualbox_vm.dmz-db.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di dmz-db"
}

output "dmz-honeypot_hostonly_ip" {
  value       = virtualbox_vm.dmz-honeypot.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di dmz-honeypot"
}
