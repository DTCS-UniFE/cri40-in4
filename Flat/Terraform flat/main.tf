terraform {
  required_providers {
    virtualbox = {
      source = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

resource "virtualbox_vm" "server-web" {
  name      = "server-web"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "virtualbox_vm" "server-db" {
  name      = "server-db"
  image     = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
  cpus      = 1
  memory    = "512 mib"
  user_data = file("user_data")

  network_adapter {
    type           = "hostonly"
    host_interface = "vboxnet0"
  }
}

resource "virtualbox_vm" "server-applications" {
  name      = "server-applications"
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
    virtualbox_vm.server-web,
    virtualbox_vm.server-db,
    virtualbox_vm.server-applications,
  ]

  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm server-web poweroff || true
      sleep 5
      VBoxManage modifyvm server-web --nic2 nat
      VBoxManage startvm server-web --type headless
    EOT
  }

  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm server-db poweroff || true
      sleep 5
      VBoxManage modifyvm server-db --nic2 nat
      VBoxManage startvm server-db --type headless
    EOT
  }

  provisioner "local-exec" {
    command = <<-EOT
      VBoxManage controlvm server-applications poweroff || true
      sleep 5
      VBoxManage modifyvm server-applications --nic2 nat
      VBoxManage startvm server-applications --type headless
    EOT
  }
}

output "server-web_hostonly_ip" {
  value       = virtualbox_vm.server-web.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di server-web"
}

output "server-db_hostonly_ip" {
  value       = virtualbox_vm.server-db.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di server-db"
}

output "server-applications_hostonly_ip" {
  value       = virtualbox_vm.server-applications.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di server-applications"
}
