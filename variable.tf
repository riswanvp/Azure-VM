variable "Project" {
    type = string
    default = "webapp"
}

variable "env" {
    type = string
    default = "prod"  
}

variable "createdby" {
    type = string
    default = "Riswan"  
}


variable "azurerm_resource_group" {
    description = "azure resources"
    type = string
    default = "Ecom-prod" 
}

variable "location" {
    description = "region of resource going to launch"
    type = string
    default = "UAE North"
}

variable "az_vnet" {
    description = "virtual network that VM going to launch"
    type = string
    default = "AZ-UN-VNET-ECOM"
#  default = "eb9aa73a-127c-4491288"
}

variable "azurerm_subnet" {
    description = "Subnet"
    type = string
    default = "AZ-ECOM-External"
    ##172.21.4.0/24
}
variable "size" {
    description = "Size of the VM"
    type = string
    default = "Standard_D2s_v5"  
}
 
variable "ports" {
  description = "List of ports open"
  type = list(number)
  default = [80, 443, 8443, 9090 ]
}
