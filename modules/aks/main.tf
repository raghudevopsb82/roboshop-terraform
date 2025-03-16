resource "azurerm_kubernetes_cluster" "main" {
  name                = var.name
  location            = var.rg_location
  resource_group_name = var.rg_name
  kubernetes_version  = var.kubernetes_version
  dns_prefix          = var.env

  default_node_pool {
    name                 = var.default_node_pool["name"]
    node_count           = var.default_node_pool["node_count"]
    vm_size              = var.default_node_pool["vm_size"]
    auto_scaling_enabled = var.default_node_pool["auto_scaling_enabled"]
    min_count            = var.default_node_pool["min_count"]
    max_count            = var.default_node_pool["max_count"]
    vnet_subnet_id       = var.subnet_ids[0]
  }



  aci_connector_linux {
    subnet_name = var.subnet_ids[0]

  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.101.0.0/24"
    dns_service_ip = "10.101.0.100"
  }

  identity {
    type = "SystemAssigned"

  }

  lifecycle {
    ignore_changes = [
      default_node_pool,
    ]
  }

}


resource "azurerm_role_assignment" "aks-to-acr" {
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = data.azurerm_container_registry.main.id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "dns_zone_contributor" {
  principal_id         = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name = "DNS Zone Contributor"
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/project-setup-1/providers/Microsoft.Network/dnsZones/azdevopsb82.online"
}

