terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  subscription_id = "7b6c642c-6e46-418f-b715-e01b2f871413"
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

