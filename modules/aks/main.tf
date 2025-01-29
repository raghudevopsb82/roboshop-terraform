resource "azurerm_kubernetes_cluster" "main" {
  name                = "main"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  kubernetes_version  = "1.31.2"
  dns_prefix          = "dev"

  default_node_pool {
    name                 = "default"
    node_count           = 1
    vm_size              = "Standard_D2_v2"
    auto_scaling_enabled = true
    min_count            = 1
    max_count            = 10
    #pod_subnet_id = "/subscriptions/7b6c642c-6e46-418f-b715-e01b2f871413/resourceGroups/project-setup-1/providers/Microsoft.Network/virtualNetworks/project-setup-network/subnets/default"
    vnet_subnet_id = "/subscriptions/7b6c642c-6e46-418f-b715-e01b2f871413/resourceGroups/project-setup-1/providers/Microsoft.Network/virtualNetworks/project-setup-network/subnets/default"
  }

  aci_connector_linux {
    subnet_name = "/subscriptions/7b6c642c-6e46-418f-b715-e01b2f871413/resourceGroups/project-setup-1/providers/Microsoft.Network/virtualNetworks/project-setup-network/subnets/default"
  }


  identity {
    type = "SystemAssigned"

  }

}


