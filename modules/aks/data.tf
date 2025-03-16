data "azurerm_container_registry" "main" {
  name                = "roboshopb82new"
  resource_group_name = "project-setup-1"
}

data "vault_generic_secret" "az" {
  path = "infra/github-actions"
}

