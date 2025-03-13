resource "azurerm_subnet" "this" {
  virtual_network_name = var.vnet_name
  name                 = var.sbn_name
  resource_group_name  = var.resource_group_name
}
