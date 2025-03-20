data "azurerm_resource_group" "default" {
  name = "project-setup-1"
}

data "vault_generic_secret" "ssh" {
  path = "infra/ssh"
}

