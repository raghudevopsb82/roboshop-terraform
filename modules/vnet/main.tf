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

resource "azurerm_subnet" "main" {
  count                = length(var.subnets)
  name                 = "${var.rg_name}-${var.network_name}-subnet-${count.index+1}"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnets[count.index]]
}


resource "azurerm_nat_gateway" "main" {
  name                    = "${var.rg_name}-${var.network_name}-ngw"
  location            = var.rg_location
  resource_group_name = var.rg_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
}

resource "azurerm_public_ip" "main" {
  name                = "${var.rg_name}-${var.network_name}-ngw"
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "main" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.main.id
}

resource "azurerm_route_table" "main" {
  count               = length(var.subnets)
  name                = "${var.rg_name}-${var.network_name}-subnet-${count.index+1}"
  location            = var.rg_location
  resource_group_name = var.rg_name

  route {
    name           = "default"
    address_prefix = var.address_space[0]
    next_hop_type  = "VnetLocal"
  }

  tags = {
    environment = var.env
  }
}

resource "azurerm_subnet_nat_gateway_association" "main" {
  count          = length(var.subnets)
  subnet_id      = azurerm_subnet.main[count.index].id
  nat_gateway_id = azurerm_nat_gateway.main.id
}

resource "azurerm_subnet_route_table_association" "main" {
  count          = length(var.subnets)
  subnet_id      = azurerm_subnet.main[count.index].id
  route_table_id = azurerm_route_table.main[count.index].id
}



