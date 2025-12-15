##select existing resourcegroup
data "azurerm_resource_group" "Ecom" {
  name = var.azurerm_resource_group.name
}

##select existing Vnet

data "azurerm_virtual_network" "vnet"{
    name = var.az_vnet.name
    resource_group_name = data.azurerm_resource_group.Ecom.name
}


## select existing Subnet

data "azurerm_subnet" "Public" {
    name = var.Pub_subnet.name
    resource_group_name = data.azurerm_resource_group.Ecom.name
    virtual_network_name = data.azurerm_virtual_network.vnet.name
}
