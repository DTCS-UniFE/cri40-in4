import os
import sys
import stat
import yaml
import networkx as nx
import matplotlib.pyplot as plt

CONFIG_PATH = "config.yaml"
VAGRANT_BOX_DEFAULT = "/home/samanta/Downloads/bionic-server-cloudimg-amd64-vagrant-20230607.0.1.box"
USER_DATA_PATH = "user_data"

def load_yaml(file_path):
    """Carica e restituisce il contenuto di un file YAML."""
    try:
        with open(file_path, "r") as f:
            return yaml.safe_load(f)
    except FileNotFoundError:
        print(f"Errore: '{file_path}' non trovato.")
        sys.exit(1)
    except yaml.YAMLError as e:
        print(f"Errore parsing YAML: {e}")
        sys.exit(1)

def create_user_data_file(path=USER_DATA_PATH):
    """Crea il file user_data con una sola riga #cloud-config se non esiste già."""
    if not os.path.exists(path):
        try:
            with open(path, "w") as f:
                f.write("#cloud-config\n")
            print(f"Creato file user_data: {path}")
        except OSError as e:
            print(f"Impossibile creare '{path}': {e}")
            sys.exit(1)
    else:
        print(f"File user_data già esistente: {path}")

def generate_network_topology_diagram(config, output_path="topology.png"):
    """Genera un diagramma di rete dalla configurazione delle VM, includendo solo le reti intnet e nat."""
    import networkx as nx
    import matplotlib.pyplot as plt

    G = nx.Graph()

    # Raccogli tutte le subnet di tipo intnet
    subnet_nodes = set()
    nat_present = False
    for vm in config.get("vms", []):
        for adapter in vm.get("network_adapters", []):
            if adapter.get("type") == "intnet" and adapter.get("intnet"):
                subnet_nodes.add(adapter.get("intnet"))
            elif adapter.get("type") == "nat":
                nat_present = True

    # Aggiungi nodi-subnet intnet
    for subnet in subnet_nodes:
        G.add_node(subnet, type='subnet')

    # Se almeno una VM ha NAT, aggiungi il nodo nat
    if nat_present:
        G.add_node("nat", type='subnet')

    # Aggiungi nodi-VM e archi verso le subnet e NAT
    for vm in config.get("vms", []):
        vm_name = vm.get("name")
        G.add_node(vm_name, type='vm')
        for adapter in vm.get("network_adapters", []):
            if adapter.get("type") == "intnet" and adapter.get("intnet"):
                G.add_edge(vm_name, adapter["intnet"])
            elif adapter.get("type") == "nat":
                G.add_edge(vm_name, "nat")

    # Layout e disegno
    pos = nx.spring_layout(G, seed=42)
    subnets = [n for n in G.nodes if G.nodes[n]['type'] == 'subnet']
    vms = [n for n in G.nodes if G.nodes[n]['type'] == 'vm']

    plt.figure(figsize=(13, 11))
    nx.draw_networkx_nodes(G, pos, nodelist=subnets, node_color='orchid', node_size=1600, label='Networks')
    nx.draw_networkx_nodes(G, pos, nodelist=vms, node_color='skyblue', node_size=1600, label='VM')
    nx.draw_networkx_edges(G, pos)
    nx.draw_networkx_labels(G, pos, font_size=13)
    plt.title("Network Topology")
    plt.legend(scatterpoints=1)
    plt.axis("off")
    plt.tight_layout()
    plt.savefig(output_path)
    plt.close()
    print(f"Creato diagramma di rete: {output_path}")

def generate_virtualbox_vm(vm):
    """Ritorna il blocco Terraform per una VM VirtualBox."""
    adapters = vm.get("network_adapters", [])
    hostonly = next((a for a in adapters if a.get("type") == "hostonly"), None)
    if not hostonly:
        raise ValueError(f"VM '{vm.get('name')}' deve avere un adapter hostonly.")
    return f"""
resource "virtualbox_vm" "{vm['name']}" {{
  name      = "{vm['name']}"
  image     = "{vm.get('image', VAGRANT_BOX_DEFAULT)}"
  cpus      = {vm.get('cpus')}
  memory    = "{vm.get('memory')}"
  user_data = file("{USER_DATA_PATH}")

  network_adapter {{
    type           = "hostonly"
    host_interface = "{hostonly['host_interface']}"
  }}
}}"""

def generate_provisioner(vm):
    """Ritorna il blocco provisioner Terraform per la configurazione di rete."""
    commands = [
        f"VBoxManage controlvm {vm['name']} poweroff || true",
        "sleep 5"
    ]
    for adapter in vm.get("network_adapters", []):
        nic = adapter.get("nic")
        if adapter.get("type") == "nat":
            commands.append(f"VBoxManage modifyvm {vm['name']} --nic{nic} nat")
        elif adapter.get("type") == "intnet":
            commands.append(f"VBoxManage modifyvm {vm['name']} --nic{nic} intnet --intnet{nic} {adapter['intnet']}")
    commands.append(f"VBoxManage startvm {vm['name']} --type headless")
    cmd_str = "\n      ".join(commands)
    return f"""
  provisioner "local-exec" {{
    command = <<-EOT
      {cmd_str}
    EOT
  }}"""

def generate_outputs(vm):
    """Ritorna il blocco output Terraform per l'indirizzo IPv4 host-only."""
    return f"""
output "{vm['name']}_hostonly_ip" {{
  value       = virtualbox_vm.{vm['name']}.network_adapter.0.ipv4_address
  description = "IP address della host-only interface di {vm['name']}"
}}"""

def generate_main_tf(vms, output_file="main.tf"):
    """Crea il file main.tf con tutti i resource Terraform."""
    with open(output_file, "w") as f:
        f.write("terraform {\n  required_providers {\n    virtualbox = {\n      source = \"terra-farm/virtualbox\"\n      version = \"0.2.2-alpha.1\"\n    }\n  }\n}\n")
        for vm in vms:
            f.write(generate_virtualbox_vm(vm) + "\n")
        f.write("\nresource \"null_resource\" \"configure_networks\" {\n  depends_on = [\n")
        for vm in vms:
            f.write(f"    virtualbox_vm.{vm['name']},\n")
        f.write("  ]\n")
        for vm in vms:
            f.write(generate_provisioner(vm) + "\n")
        f.write("}\n")
        for vm in vms:
            f.write(generate_outputs(vm) + "\n")
    print(f"Creato Terraform file: {output_file}")

def generate_start_script(vm_names, filename="start_vms.py"):
    """Crea lo script Python per l'avvio delle VM."""
    with open(filename, "w") as f:
        f.write("#!/usr/bin/env python3\n")
        f.write("import os\n\n")
        for name in vm_names:
            f.write(f'print("Starting {name}...")\n')
            f.write(f'os.system("VBoxManage startvm {name} --type headless")\n')
    os.chmod(filename, stat.S_IRWXU | stat.S_IRGRP | stat.S_IXGRP | stat.S_IROTH | stat.S_IXOTH)
    print(f"Script avvio creato: {filename}")

def generate_stop_script(vm_names, filename="stop_vms.py"):
    """Crea lo script Python per lo spegnimento delle VM."""
    with open(filename, "w") as f:
        f.write("#!/usr/bin/env python3\n")
        f.write("import os\n\n")
        for name in vm_names:
            f.write(f'print("Stopping {name}...")\n')
            f.write(f'os.system("VBoxManage controlvm {name} poweroff || true")\n')
    os.chmod(filename, stat.S_IRWXU | stat.S_IRGRP | stat.S_IXGRP | stat.S_IROTH | stat.S_IXOTH)
    print(f"Script spegnimento creato: {filename}")

def main():
    # Caricamento configurazione
    config = load_yaml(CONFIG_PATH)
    vms = config.get("vms", [])
    vm_names = [vm.get("name") for vm in vms]

    # Creazione automatica del file user_data
    create_user_data_file()

    # Generazione dei file
    generate_main_tf(vms)
    generate_network_topology_diagram(config)
    generate_start_script(vm_names)
    generate_stop_script(vm_names)

if __name__ == "__main__":
    main()
