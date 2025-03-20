# data "azurerm_resource_group" "main" {
#   name = "project-setup-1"
# }

data "vault_generic_secret" "ssh" {
  path = "infra/ssh"
}

