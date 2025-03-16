resource "azurerm_virtual_network" "main" {
  name                = "${var.rg_name}-${var.network_name}-vnet"
  location            = var.rg_location
  resource_group_name = var.rg_name
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags = {
    environment = var.env
  }
}

# resource "azurerm_subnet" "example" {
#   count                = length(var.subnets)
#   name                 = "${var.rg_name}-${var.network_name}-subnet-${count.index+1}"
#   resource_group_name  = azurerm_resource_group.example.name
#   virtual_network_name = azurerm_virtual_network.example.name
#   address_prefixes     = ["10.0.1.0/24"]
#
#   delegation {
#     name = "delegation"
#
#     service_delegation {
#       name    = "Microsoft.ContainerInstance/containerGroups"
#       actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
#     }
#   }
# }


