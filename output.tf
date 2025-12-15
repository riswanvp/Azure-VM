output "vm_name" {
    description = "The virtual machine name"
    value = azurerm_linux_virtual_machine.name.name  
}

output "public_ip" {
    description = "The public IP of the VM"
    value = azurerm_public_ip.vm.ip_address
}
output "private" {
    description = "Private Ip of the VM"
    value = azurerm_network_interface.vm_nic.private_ip_address
}
