resource "azurerm_virtual_network" "main" {
  name                = "${var.rg_name}-vnet"
  location            = var.rg_location
  resource_group_name = var.rg_name
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags = {
    environment = var.env
  }
}

