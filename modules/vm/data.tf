data "azurerm_resource_group" "main" {
  name = "project-setup-1"
}

data "azurerm_subnet" "example" {
  name                 = "default"
  virtual_network_name = "project-setup-network"
  resource_group_name  = data.azurerm_resource_group.main.name
}

