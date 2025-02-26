terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  subscription_id = "a906d619-0839-4738-a908-227a8b69d458"
}


provider "vault" {
  address = "http://vault-internal.azdevopsb82.online:8200"
  token   = var.token
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

