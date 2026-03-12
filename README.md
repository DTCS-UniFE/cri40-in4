# Automatic Deployment and Provisioning of IT Infrastructures with Terraform and Ansible

This repository provides a flexible and scalable framework for **rapidly deploying, configuring, and tearing down various network topologies** using **Terraform** and **Ansible**. Designed for cybersecurity testing, training, and research, it enables quick setup and teardown of isolated environments (cyber ranges).

---

## Supported Network Topologies

This project offers three fundamental network architectures, each serving distinct cybersecurity use cases:

### Flat Network

* Simple, straightforward environment.
* Ideal for basic tests, quick demonstrations, and low-complexity scenarios.

### 3-Legged Firewall

* Simulates segmented networks with Internal, DMZ, and External zones.
* Provides enhanced security scenarios and complex testing environments.

### Double Bastion

* Enhanced secure architecture using dual bastion hosts.
* Ideal for advanced cybersecurity scenarios demanding stringent access control and network segmentation.

---

## Quick Navigation

* [Key Features](#key-features)
* [Prerequisites](#prerequisites)
* [Getting Started](#getting-started)
* [Topology Customization](#topology-customization)
* [Deployment with Terraform](#deployment-with-terraform)
* [Configuration with Ansible](#configuration-with-ansible)
* [Disclaimer](#disclaimer)

---

## Key Features
[▲ Back to top](#automatic-deployment-and-provisioning-of-it-infrastructures-with-terraform-and-ansible)

* **Rapid Deployment**: Quickly create or destroy complex network topologies.
* **Automated Configuration**: Utilize Ansible to automatically configure virtual machines (VMs).
* **Flexibility & Scalability**: Easily modify and scale your network topology using intuitive YAML configuration files.

---

## Prerequisites
[▲ Back to top](#automatic-deployment-and-provisioning-of-it-infrastructures-with-terraform-and-ansible)

This setup is built and tested on the following stack:

- **Operating System (host):** [Ubuntu 22.04](https://releases.ubuntu.com/jammy/)
- **Terraform:** [v1.11.2](https://developer.hashicorp.com/terraform/install)
- **Terraform Provider:** VirtualBox by [terra-farm (v0.2.2-alpha.1)](https://registry.terraform.io/providers/terra-farm/virtualbox/latest/docs/resources/vm) (community-supported)
- **Virtualization Platform:** [VirtualBox 7.0.24 r167081](https://www.virtualbox.org/wiki/Changelog-7.0#v24)
- **Vagrant Box:** [bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box](https://portal.cloud.hashicorp.com/vagrant/discover/ubuntu/bionic64/versions/20230607.0.1)

### Disclaimer 
[▲ Back to top](#automatic-deployment-and-provisioning-of-it-infrastructures-with-terraform-and-ansible)

If you are using a newer version of VirtualBox (> 7.0.24), you might experience issues related to missing network connectivity.

To resolve this issue, you need to create a new NAT network. Follow these steps:

1. Open **Tools** in VirtualBox.
2. Click on the menu icon on the right to open the sliding menu.
3. Select **NAT Networks** from the top menu.
4. Click **Create**.
5. In the **NAT Networks** section, ensure **Enable DHCP** is checked.

After creating the NAT network, update the network adapter settings for each virtual machine:

1. Open the settings of the VM.
2. Navigate to the **Network** section.
3. Locate the adapter currently set to **NAT** and change it to **NAT Network**.
4. Enter the name of the NAT network you just created.

---

## Getting Started
[▲ Back to top](#automatic-deployment-and-provisioning-of-it-infrastructures-with-terraform-and-ansible)

### Step 1: Install Terraform
[▲ Back to top](#automatic-deployment-and-provisioning-of-it-infrastructures-with-terraform-and-ansible)

Follow the official [Terraform installation guide](https://developer.hashicorp.com/terraform/install).

1. Update the system: 
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
2. Download the binary file suitable for your system from: [HashiCorp](https://developer.hashicorp.com/terraform/install)

3. Use wget to download the file.  Open the terminal and use the following command, replacing the URL with the one you copied:
   ```bash
   wget https://releases.hashicorp.com/terraform/1.11.0/terraform_1.11.0_linux_amd64.zip
   ```

4. Check the directories in the $PATH.  Run the following command to see the directories included in your $PATH:
   ```bash
   echo $PATH	
   ```

5. Extract the folder  containing the Terraform executable to /usr/local/bin using the following command:
   ```bash
   sudo unzip terraform_1.11.0_linux_amd64.zip -d /usr/local/bin
   ```

6. Check the content of the directory. Verify that the Terraform file has been extracted correctly by running the following command:
   ```bash
   ls -l /usr/local/bin
   ```

7. Verify the installation by running the following command:
   ```bash
   terraform -version
   ```

### Step 2: Install Ansible
[▲ Back to top](#automatic-deployment-and-provisioning-of-it-infrastructures-with-terraform-and-ansible)

On your Ansible Control Node (recommended: Ubuntu 20.04 VM), run:

```bash
sudo apt update
sudo apt install software-properties-common
sudo apt-add-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

Edit the ansible.cfg file:
```bash
sudo nano ansible.cfg
```

By entering the following configuration:
```bash
[defaults]
inventory = /etc/ansible/hosts
host_key_checking = False
```

---

## Topology Customization
[▲ Back to top](#automatic-deployment-and-provisioning-of-it-infrastructures-with-terraform-and-ansible)

Customize your desired topology by editing the provided `config.yaml` file. Use the included Python script to generate the required Terraform files:

```bash
python3 generate_main_file.py
```

This script will generate:

- A customized main.tf file for Terraform deployment
- A Python script: start_vms.py for easily powering on your VMs
- A Python script: stop_vms.py for easily powering off your VMs
- A user_data file needed to create the infrastructure using the provider terra-farm
- topology.png that represents a diagram of the architecture that will be created using Terraform (the Host-Only network is not represented since every VM has it)

---

## Deployment with Terraform
[▲ Back to top](#automatic-deployment-and-provisioning-of-it-infrastructures-with-terraform-and-ansible)

Deploy the infrastructure quickly using Terraform:

```bash
terraform init
terraform apply
```

Measure deployment performance with:

```bash
time terraform apply
```

---

## Configuration with Ansible
[▲ Back to top](#automatic-deployment-and-provisioning-of-it-infrastructures-with-terraform-and-ansible)

After infrastructure deployment, configure your VMs:

1. **Set up SSH Keys**:

```bash
ssh-copy-id vagrant@<IP_fw-external>
```

Replace <IP_fw-external> with the actual IP address of the VM you want to controll using Ansible

Repeat this command for each VM you have created, replacing the IP accordingly. This step allows Ansible to connect to the remote nodes without requiring a password each time

**In case you receive the "permission denied (publickey)" error**, run the following commands from the terminal of the VM you have created using Terraform to enable SSH connection using PasswordAuthentication:

1. Enter the VM you tried to execute the command ssh-copy-id vagrant@<IP_fw-external>, by using the default credentials:
  - username: vagrant
  - password: vagrant

**Warning:** Clicking inside the VM window (black box) will "capture" the mouse pointer. To release the pointer, press the **right CTRL Key on the keyboard**


2. Edit the sshd_config file:
```bash
  sudo nano /etc/ssh/sshd_config
```
**Warning:** the keyboard is set to “us”, therefore:
- / corresponds to - on the “it” keyboard
- _ corresponds to ? on the “it” keyboard

3. Open the sshd_config file using a text editor, for this example nano. Press the key combination Ctrl + W and a search bar labeled "Search" will appear at the bottom of the page
Type PasswordAuthentication in the search bar and press “Enter”

4. The cursor will move to the first occurrence of “PasswordAuthentication” delete no and write yes

5. Press Ctrl + X to close the file. This will bring up a white bar at the bottom of the file asking whether to save the changes or not. Press y to save and then press Enter

6.	Restart the SSH service with the command:
```bash
sudo systemctl restart sshd
```

Then, from the terminal of the Ansible Control Node, enter again:
```bash
ssh-copy-id vagrant@<IP_VM-ext>
```
Once you've copied the SSH keys to all VMs, verify the configuration by running the following command from the terminal of your Ansible Control Node:
```bash
ansible all -m ping
```
If everything is set up correctly, this command should return a "pong" response from all the VMs

**In case you receive the "attempting to log in with the new key(s), to filter out any that are already installed" error**
1. Remove the existing SSH key:
```bash
sudo rm /etc/ssh/ssh_host_*
```
2. Regenerate the SSH host key for the OpenSSH server:
```bash
sudo dpkg-reconfigure openssh-server
```
3. Restart the SSH service:
```bash
sudo systemctl restart sshd
```
3. Verify that the SSH service is running:
```bash
sudo systemctl status sshd
```

Then, from the terminal of the Ansible Control Node, enter again:
```bash
ssh-copy-id vagrant@<IP_VM-ext>
```

By connecting in SSH to a controlled VM, you can check the status of the network interfaces that were previously created
As you can see, the network interfaces have been created, but they are in a "DOWN" state, meaning they are not active (only host-only UP)


```bash
ssh-copy-id vagrant@<VM_IP>
```

2. **Edit Ansible Inventory (`/etc/ansible/hosts`)**:

Define your VMs clearly to match your network setup:

Edit the hosts file:
```bash
sudo nano hosts
```

Add the following configuration, replacing the IP addresses and variables as needed to match your VMs setup:
```bash
[all]
fw-external ansible_host=192.168.56.x ansible_user=vagrant ansible_ssh_private_key_file=/home/samanta/.ssh/id_rsa ansible_sudo_pass=vagrant
```

For example:
- **fw-external:** name of the VM we want to connect to via SSH
- **ansible_host=192.168.56.x:** IP address of the host-only network interface of the VM we want to connect to. Modify the given address to match your VM
- **ansible_user=vagrant:** standard user since we are using Vagrant (do not modify)
- **ansible_ssh_private_key=/home/samanta/.ssh/id_rsa:** path to the SSH key on the "Ansible_control_node" VM
- **ansible_sudo_pass=vagrant:** standard password we are using for Vagrant (do not modify), required to execute "sudo" commands on “fw-external”

3. **Test Ansible connectivity**:

```bash
ansible all -m ping
```

---

For more details, refer to each topology's dedicated documentation within this repository.

[▲ Back to top](#automatic-deployment-and-provisioning-of-it-infrastructures-with-terraform-and-ansible)
