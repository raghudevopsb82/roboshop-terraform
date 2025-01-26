resource "azurerm_kubernetes_cluster" "main" {
  name                = "main"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  kubernetes_version  = "1.31.2"
  dns_prefix          = "dev"

#   default_node_pool {
#     name       = "default"
#     node_count = 1
#     vm_size    = "Standard_D2_v2"
#   }

  agent_pool_profile {
    name            = "default"
    enable_cluster_autoscaler = true
    min_count       = 1
    max_count       = 3
    vm_size         = "Standard_D2_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  identity {
    type = "SystemAssigned"

  }

  auto_scaling_enabled = true


}


