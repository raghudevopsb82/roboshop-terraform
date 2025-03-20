resource "azurerm_virtual_network" "main" {
  name                = "${var.rg_name}-vnet"
  location            = var.rg_location
  resource_group_name = var.rg_name
  address_space       = var.address_space

  tags = {
    environment = var.env
  }
}


resource "azurerm_subnet" "main" {
  count               = length(var.subnets)
  name                 = "${var.rg_name}-vnet-subnet-${count.index+1}"
  virtual_network_name = azurerm_virtual_network.main.name
  location            = var.rg_location
  resource_group_name = var.rg_name
  address_prefixes     = var.subnets[count.index]
}


