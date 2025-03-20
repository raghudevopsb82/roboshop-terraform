resource "azurerm_kubernetes_cluster" "main" {
  name                = var.name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  kubernetes_version  = "1.31.2"
  dns_prefix          = var.env

  default_node_pool {
    name                 = "p20250131"
    node_count           = 1
    vm_size              = "Standard_D4_v2"
    auto_scaling_enabled = false
    vnet_subnet_id = var.subnet_ids[0]
  }



  aci_connector_linux {
    subnet_name = var.subnet_ids[0]
  }


  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.100.0.0/24"
    dns_service_ip = "10.100.0.100"
  }

  identity {
    type = "SystemAssigned"

  }

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      #default_node_pool,
    ]
  }

}




resource "azurerm_kubernetes_cluster_node_pool" "main" {
  name                  = "main"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_D4_v2"
  node_count            = 2
  auto_scaling_enabled  = true
  min_count = 2
  max_count = 10
  vnet_subnet_id = var.subnet_ids[0]
}


resource "azurerm_role_assignment" "aks-to-acr" {
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = data.azurerm_container_registry.main.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "dns_zone_contributor" {
  principal_id   = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name = "DNS Zone Contributor"
  scope          = "/subscriptions/${var.subscription_id}/resourceGroups/project-setup-1/providers/Microsoft.Network/dnsZones/azdevopsb82.online"
}

