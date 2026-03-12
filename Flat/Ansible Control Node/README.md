## 3-Legged Firewall - Deployment & Configuration Steps

You can deploy and configure your network architecture using two different approaches. Choose the method that best fits your needs.

---

### Option 1: Customize via `config.yaml` and Python Script

1. **Edit the Configuration File:**
   - Open the `config.yaml` file.
   - Customize it to define your desired network topology, virtual machines, and network interfaces.

2. **Generate Terraform Files:**
   - Run the provided Python script to automatically generate the necessary Terraform files:
     ```bash
     python3 generate_main_tf.py
     ```

3. **Deploy the Infrastructure with Terraform:**
   - Initialize and apply the Terraform configuration:
     ```bash
     terraform init
     terraform apply
     ```

---

### Option 2: Use the Provided `main.tf` File

1. **Deploy the Default Architecture:**
   - If you prefer to use the default setup, you can simply use the `main.tf` file provided in the repository.
   - Run the following commands:
     ```bash
     terraform init
     terraform apply
     ```

---

### After Terraform Deployment: Ansible Configuration

Once your virtual machines have been created by Terraform, you can configure them using Ansible from your Ansible Control Node.

1. **Copy SSH Key to Each VM:**
   - For each VM you want to manage with Ansible, copy your SSH public key:
     ```bash
     ssh-copy-id vagrant@<VM_IP>
     ```
   - Replace `<VM_IP>` with the IP address of each virtual machine.

2. **Run Ansible Playbook:**
   - Execute the Ansible playbook to set up and configure your environment by executing the following command:
     ```bash
     ansible-playbook flat-configuration.yml
     ```
