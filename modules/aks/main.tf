resource "azurerm_kubernetes_cluster" "main" {
  name                = "main"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  kubernetes_version  = "1.31.2"
  dns_prefix          = "dev"

  default_node_pool {
    name                 = "default"
    node_count           = 2
    vm_size              = "Standard_D4_v2"
    auto_scaling_enabled = false
    min_count            = null
    max_count            = null
    #pod_subnet_id = "/subscriptions/7b6c642c-6e46-418f-b715-e01b2f871413/resourceGroups/project-setup-1/providers/Microsoft.Network/virtualNetworks/project-setup-network/subnets/default"
    vnet_subnet_id = "/subscriptions/${var.subscription_id}/resourceGroups/project-setup-1/providers/Microsoft.Network/virtualNetworks/${var.virtual_network_name}/subnets/default"
    temporary_name_for_rotation = "p${formatdate("YYYYhhmm", timestamp())}"
  }



  aci_connector_linux {
    subnet_name = "/subscriptions/${var.subscription_id}/resourceGroups/project-setup-1/providers/Microsoft.Network/virtualNetworks/${var.virtual_network_name}/subnets/default"
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

