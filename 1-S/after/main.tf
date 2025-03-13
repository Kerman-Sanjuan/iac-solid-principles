module "vm" {
  location            = var.location
  source              = "./modules/vm/"
  vm_name             = var.vm_name
  storage_os_name     = var.storage_os_name
  storage_disk_name   = var.storage_disk_name
  nic_name            = var.nic_name
  vm_size             = var.vm_size
  resource_group_name = var.resource_group_name
}

module "sbn" {
  source              = "./modules/subnet/"
  resource_group_name = var.resource_group_name
  sbn_name            = var.sbn_name
  vnet_name           = var.vnet_name
  location            = var.location
}

module "vnet" {
  source              = "./modules/vnet/"
  vnet_name           = var.vnet_name
  address_space       = var.address_space
  resource_group_name = var.resource_group_name
  location            = var.location
}
