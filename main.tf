provider "azurerm" {
  version = "=2.34.0"
  features {}
}

# Backend using a state Terraform file in a storage account
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-cyclecloud-tf"
    storage_account_name = "sacyclecloudtf"
    container_name       = "terraform-state"
    key                  = "terraform.tfstate"
  }
}

data "azurerm_subscription" "current" {
}

# Create the resource group
resource "azurerm_resource_group" "acc_rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

# Create CycleCloud storage account 
resource "random_id" "storage_account" {
  byte_length = 8
}

resource "azurerm_storage_account" "acc_locker" {
  name                     = "${var.prefix}${lower(random_id.storage_account.hex)}sa" 
  resource_group_name      = azurerm_resource_group.acc_rg.name
  location                 = azurerm_resource_group.acc_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create the VNET
resource "azurerm_virtual_network" "acc_vnet" {
  name                = "${var.prefix}-network"
  location            = azurerm_resource_group.acc_rg.location
  resource_group_name = azurerm_resource_group.acc_rg.name
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet
resource "azurerm_subnet" "acc_subnet" {
  name                 = "${var.prefix}-subnet"
  virtual_network_name = azurerm_virtual_network.acc_vnet.name
  resource_group_name  = azurerm_resource_group.acc_rg.name
  address_prefixes     = ["10.0.0.0/24"]
  service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_network_security_group" "acc_subnet_nsg" {
    name                = "${var.prefix}-subnet-nsg"
    location            = azurerm_resource_group.acc_rg.location
    resource_group_name = azurerm_resource_group.acc_rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefixes    = list(var.cyclecloud_public_access_address_prefixes)
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefixes    = list(var.cyclecloud_public_access_address_prefixes)
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "HTTPS"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefixes    = list(var.cyclecloud_public_access_address_prefixes)
        destination_address_prefix = "*"
    }
}

# Connect the security group to the subnet
resource "azurerm_subnet_network_security_group_association" "acc_subnet_nsg_assign" {
    subnet_id                 = azurerm_subnet.acc_subnet.id
    network_security_group_id = azurerm_network_security_group.acc_subnet_nsg.id
}

# Create a public IP for the CycleServer
resource "azurerm_public_ip" "acc_public_ip" {
  name                         = "${var.prefix}-public-ip"
  location                     = azurerm_resource_group.acc_rg.location
  resource_group_name          = azurerm_resource_group.acc_rg.name
  #domain_name_label           = var.cyclecloud_dns_label
  allocation_method            = "Dynamic"
}

# Create the network interface
resource "azurerm_network_interface" "acc_nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.acc_rg.location
  resource_group_name = azurerm_resource_group.acc_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.acc_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.acc_public_ip.id
  }
}

# Create CycleCloud VM
resource "azurerm_virtual_machine" "acc_vm" {
  name                  = var.cyclecloud_computer_name
  resource_group_name   = azurerm_resource_group.acc_rg.name
  location              = azurerm_resource_group.acc_rg.location
  network_interface_ids = [azurerm_network_interface.acc_nic.id]
  vm_size               = var.machine_type
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.7"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.cyclecloud_computer_name}-osdisk"
    disk_size_gb      = "128"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = var.cyclecloud_computer_name
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = base64encode( <<CUSTOM_DATA
#cloud-config
#
# installs CycleCloud on the VM
#
yum_repos:
  azure-cli:
    baseurl: https://packages.microsoft.com/yumrepos/azure-cli
    enabled: true
    gpgcheck: true
    gpgkey: https://packages.microsoft.com/keys/microsoft.asc
    name: Azure CLI
  cyclecloud:
    baseurl: https://packages.microsoft.com/yumrepos/cyclecloud
    enabled: true
    gpgcheck: true
    gpgkey: https://packages.microsoft.com/keys/microsoft.asc
    name: Cycle Cloud
packages:
- java-1.8.0-openjdk-headless
- azure-cli
- cyclecloud8
write_files:
- content: |
    [{
        "AdType": "Application.Setting",
        "Name": "cycleserver.installation.initial_user",
        "Value": "${var.cyclecloud_username}"
    },
    {
        "AdType": "Application.Setting",
        "Name": "cycleserver.installation.complete",
        "Value": true
    },
    {
        "AdType": "AuthenticatedUser",
        "Name": "${var.cyclecloud_username}",
        "RawPassword": "${var.cyclecloud_password}",
        "Superuser": true
    }] 
  owner: root:root
  path: ./account_data.json
  permissions: '0644'
- content: |
    {
      "Name": "Azure",
      "Environment": "public",
      "AzureRMSubscriptionId": "${data.azurerm_subscription.current.subscription_id}",
      "AzureRMUseManagedIdentity": true,
      "Location": "westeurope",
      "RMStorageAccount": "${var.cyclecloud_storage_account}",
      "RMStorageContainer": "cyclecloud"
    }
  owner: root:root
  path: ./azure_data.json
  permissions: '0644'
runcmd:
- sed -i --follow-symlinks "s/webServerPort=.*/webServerPort=80/g" /opt/cycle_server/config/cycle_server.properties
- sed -i --follow-symlinks "s/webServerSslPort=.*/webServerSslPort=443/g" /opt/cycle_server/config/cycle_server.properties
- sed -i --follow-symlinks "s/webServerEnableHttps=.*/webServerEnableHttps=true/g" /opt/cycle_server/config/cycle_server.properties
- systemctl restart cycle_server
- sleep 60
- mv ./account_data.json /opt/cycle_server/config/data/
- /opt/cycle_server/cycle_server execute "update Application.Setting set Value = false where name == \"authorization.check_datastore_permissions\""
- unzip /opt/cycle_server/tools/cyclecloud-cli.zip
- ./cyclecloud-cli-installer/install.sh --system
- sleep 60
- /usr/local/bin/cyclecloud initialize --batch --url=https://localhost --verify-ssl=false --username="${var.cyclecloud_username}" --password="${var.cyclecloud_password}"
- /usr/local/bin/cyclecloud account create -f ./azure_data.json
  CUSTOM_DATA
  )
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = var.admin_key_data
    }
  }
}

# Assign role to the managed ID
resource "azurerm_role_assignment" "acc_mi_role" {
  scope                 = data.azurerm_subscription.current.id
  role_definition_name  = "Contributor"
  principal_id          = lookup(azurerm_virtual_machine.acc_vm.identity[0], "principal_id")
}
