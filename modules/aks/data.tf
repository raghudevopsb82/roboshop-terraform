data "azurerm_container_registry" "main" {
  name                = "roboshopb82new"
  resource_group_name = data.azurerm_resource_group.default.name
}

data "vault_generic_secret" "az" {
  path = "infra/github-actions"
}

data "azurerm_subscription" "current" {}
data "azurerm_resource_group" "default" {
  name = "project-setup-1"
}

