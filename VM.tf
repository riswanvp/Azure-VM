terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
  locals{
      default_tags = {
      Project     = "${var.project}"
      Environment = "${var.env}"
      CreatedBy   = "${var.createdby}"
      Date        = "${var.date}"
  }
}


## create public IP
resource "azurerm_public_ip" "vm" {
    name = "${var.az_vnet.name}-IP"
    location = var.location
    resource_group_name = data.azurerm_resource_group.Ecom.name
    allocation_method = "Static"
}

## Create NIC
resource "azurerm_network_interface" "vm_nic" {
  name                = "vm-nic" 
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = data.azurerm_resource_group.Ecom.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"

    ##Public Ip association
    public_ip_address_id = azurerm_public_ip.vm.id
  }
}


## NSG creation

resource "azurerm_network_security_group" "NSG" {
  name =  "${var.az_vnet.name}-${var.project}-${var.env}-nsg"
  resource_group_name = data.azurerm_resource_group.Ecom.name
  location = data.azurerm_virtual_network.vnet.location
}

resource "azurerm_network_security_rule" "inbound-open" {
  for_each = toset(var.ports)
  name = "Allow-Port-${each.value}"
  priority = 100 + each.key
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = each.value
  source_address_prefix = "*"
  destination_address_prefix  = "*"
  resource_group_name = data.azurerm_resource_group.Ecom.name
  network_security_group_name = azurerm_network_security_group.NSG.name
}  

resource "azurerm_network_security_rule" "Outbound" {
  name = "Outbound"
  priority = 100
  direction = "Outbound"
  access = "Allow"
  protocol = "*"
  source_port_range = "*"
  destination_port_range = "*"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  resource_group_name = data.azurerm_resource_group.Ecom.name
  network_security_group_name = azurerm_network_security_group.NSG.name
}


## Network intrerface association

resource "azurerm_network_interface_security_group_association" "nsg-nic-association" {
  network_interface_id = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.NSG.id
}


##VM creation
resource "azurerm_linux_virtual_machine" "name" {
  name = "${var.az_vnet.name}-${var.project}-${var.env}-VM"
  resource_group_name = data.azurerm_resource_group.Ecom.name
  location = data.azurerm_virtual_network.vnet.location
  size = var.size
  admin_username = "azureuser"
  #SSH key defining (using the key from locally created)
  admin_ssh_key {
    username = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  network_interface_ids = [ azurerm_network_interface.vm_nic.id ]
  os_disk {
    name = "${var.az_vnet.name}-${var.project}-${var.env}-VM-OS-disk"
    caching = "ReadWrite"
    storage_account_type = "Standard SSD ZRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "24_04-lts"
    version   = "latest"
  }
 # Trusted Launch security settings
  secure_boot_enabled           = true
  vtpm_enabled                  = true
}

