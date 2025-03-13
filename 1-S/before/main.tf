terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
  required_version = "1.5.7"
}

variable "resource_group_name" {}
variable "nic_name" {}
variable "location" {}
variable "vm_size" {}
variable "vm_name" {}
variable "storage_disk_name" {}
variable "storage_os_name" {}

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
variable "vnet_name" {}
variable "address_space" {}
variable "sbn_name" {}
resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
}
resource "azurerm_subnet" "this" {
  virtual_network_name = azurerm_virtual_network.this.name
  name                 = var.sbn_name
  resource_group_name  = var.resource_group_name
}
