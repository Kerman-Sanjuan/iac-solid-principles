# Single responsibility principle on Terraform

By definition, this principle states that a class or function should only have one responsibility. Even more, it should only have one reason to change.

This principle helps developers to reduce dependencies, easier management and better understanding of the business logic.

When working with IaC, this principle usually is related to ensuring that each module has one clear purpose and one reason to change.

For example:

```Terraform
#before/main.tf 
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
```

Probably, this hurts your eyes as much as it did mine. This code snippet violates the Single Responsibility Principle (SRP) in multiple ways and layers:

1. All the IaC is defined in a single file: This makes it not only hard to read and maintain, but also increases the likelihood that multiple unrelated changes will be needed in the same place.
2. Mixing different categories and lifecycles: The file defines networking, compute, and storage resources together, despite having distinct purposes and change frequencies.
3. No separation of concerns: Updating the virtual network would require modifying the same file that manages virtual machines, increasing the risk of unintended changes.
4. Poor reusability and scalability: Without modularization, it becomes difficult to reuse components in different projects or environments.

Now, time to refactor the code following the S principle:

```Terraform
# after/providers.tf
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
  required_version = "1.5.7"
}
# after/variables.tf
variable "resource_group_name" {}
variable "nic_name" {}
variable "location" {}
variable "vm_size" {}
variable "vm_name" {}
variable "storage_disk_name" {}
variable "storage_os_name" {}
variable "vnet_name" {}
variable "address_space" {}
variable "sbn_name" {}
# after/main.tf
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
```

Now, each module has its own responsibility as well as clear boundaries, ensuring better maintainability, reusability, and separation of concerns. The root module (main.tf) acts as the orchestrator, managing dependencies without tightly coupling infrastructure components.

Each module is self-contained and handles a specific aspect of the infrastructure, such as networking, compute, or storage. This modular approach allows updates to be made in a controlled manner, ensuring that:

* Each module can be updated independently without affecting the others.
Changes are made in the correct place, reducing the risk of unintended modifications.
* If a specific component, like the virtual network, needs an update, it can be modified without touching the VM or subnet configurations.
* The root module (main.tf) remains clean and only orchestrates deployments, without managing infrastructure logic directly.
