terraform {
  required_providers {
    virtualbox = {
      source = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

resource "virtualbox_vm" "internet_fw" {
  name      = "internet_fw"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "virtualbox_vm" "subnet_a_nginx" {
  name      = "subnet_a_nginx"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "virtualbox_vm" "subnet_b_vm_01" {
  name      = "subnet_b_vm_01"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "virtualbox_vm" "internal_fw_1" {
  name      = "internal_fw_1"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "virtualbox_vm" "internal_fw_2" {
  name      = "internal_fw_2"
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

resource "virtualbox_vm" "dmz-suricata" {
  name      = "dmz-suricata"
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
    virtualbox_vm.internet_fw,
    virtualbox_vm.subnet_a_nginx,
    virtualbox_vm.subnet_b_vm_01,
    virtualbox_vm.internal_fw_1,
    virtualbox_vm.internal_fw_2,
    virtualbox_vm.dmz-wazuh,
    virtualbox_vm.dmz-suricata,
    virtualbox_vm.dmz-db,
    virtualbox_vm.dmz-honeypot,
  ]

  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm internet_fw poweroff || true
      sleep 5
      VBoxManage modifyvm internet_fw --nic2 nat
      VBoxManage modifyvm internet_fw --nic3 intnet --intnet3 subnet_a
      VBoxManage startvm internet_fw --type headless
    EOT
  }

  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm subnet_a_nginx poweroff || true
      sleep 5
      VBoxManage modifyvm subnet_a_nginx --nic3 intnet --intnet3 subnet_a
      VBoxManage startvm subnet_a_nginx --type headless
    EOT
  }

  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm subnet_b_vm_01 poweroff || true
      sleep 5
      VBoxManage modifyvm subnet_b_vm_01 --nic4 intnet --intnet4 subnet_b
      VBoxManage startvm subnet_b_vm_01 --type headless
    EOT
  }

  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm internal_fw_1 poweroff || true
      sleep 5
      VBoxManage modifyvm internal_fw_1 --nic2 nat
      VBoxManage modifyvm internal_fw_1 --nic3 intnet --intnet3 subnet_a
      VBoxManage modifyvm internal_fw_1 --nic5 intnet --intnet5 subnet_dmz
      VBoxManage startvm internal_fw_1 --type headless
    EOT
  }

  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm internal_fw_2 poweroff || true
      sleep 5
      VBoxManage modifyvm internal_fw_2 --nic2 nat
      VBoxManage modifyvm internal_fw_2 --nic4 intnet --intnet4 subnet_b
      VBoxManage modifyvm internal_fw_2 --nic5 intnet --intnet5 subnet_dmz
      VBoxManage startvm internal_fw_2 --type headless
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
      VBoxManage controlvm dmz-suricata poweroff || true
      sleep 5
      VBoxManage modifyvm dmz-suricata --nic5 intnet --intnet5 subnet_dmz
      VBoxManage startvm dmz-suricata --type headless
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

output "internet_fw_hostonly_ip" {
  value       = virtualbox_vm.internet_fw.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di internet_fw"
}

output "subnet_a_nginx_hostonly_ip" {
  value       = virtualbox_vm.subnet_a_nginx.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di subnet_a_nginx"
}

output "subnet_b_vm_01_hostonly_ip" {
  value       = virtualbox_vm.subnet_b_vm_01.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di subnet_b_vm_01"
}

output "internal_fw_1_hostonly_ip" {
  value       = virtualbox_vm.internal_fw_1.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di internal_fw_1"
}

output "internal_fw_2_hostonly_ip" {
  value       = virtualbox_vm.internal_fw_2.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di internal_fw_2"
}

output "dmz-wazuh_hostonly_ip" {
  value       = virtualbox_vm.dmz-wazuh.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di dmz-wazuh"
}

output "dmz-suricata_hostonly_ip" {
  value       = virtualbox_vm.dmz-suricata.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di dmz-suricata"
}

output "dmz-db_hostonly_ip" {
  value       = virtualbox_vm.dmz-db.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di dmz-db"
}

output "dmz-honeypot_hostonly_ip" {
  value       = virtualbox_vm.dmz-honeypot.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di dmz-honeypot"
}
