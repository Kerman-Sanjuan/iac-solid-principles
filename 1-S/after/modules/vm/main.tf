resource "azurerm_network_interface" "this" {
  name                = var.nic_name
  resource_group_name = var.resource_group_name
  location            = var.location
  ip_configuration {
    name                          = "ip_config"
    private_ip_address_allocation = "Static"
  }
}
resource "azurerm_virtual_machine" "this" {
  resource_group_name   = var.resource_group_name
  network_interface_ids = azurerm_network_interface.this.id
  vm_size               = var.vm_size
  location              = var.location
  name                  = var.vm_name
  storage_data_disk {
    create_option = ""
    name          = var.storage_disk_name
    lun           = 1

  }
  storage_os_disk {
    create_option = ""
    name          = var.storage_os_name
  }
}
