module "databases" {
  for_each    = var.databases
  source      = "./modules/vm"
  component   = each.value["name"]
  vm_size     = each.value["vm_size"]
  env         = var.env
  vault_token = var.token
  container   = each.value["container"]
  rg_name     = lookup(lookup(module.resource_group, "main", null), "name", null)
  rg_location = lookup(lookup(module.resource_group, "main", null), "location", null)
  rg_id       = lookup(lookup(module.resource_group, "main", null), "id", null)
  subnet_ids  = lookup(lookup(module.vnet, "main", null), "subnet_ids", null)
}

module "aks" {
  for_each             = var.aks
  source               = "./modules/aks"
  vault_token          = var.token
  subscription_id      = var.subscription_id
  virtual_network_name = "main"
  env                  = var.env
  default_node_pool    = each.value["default_node_pool"]
  kubernetes_version   = each.value["kubernetes_version"]
  name                 = each.key
  rg_name              = lookup(lookup(module.resource_group, "main", null), "name", null)
  rg_location          = lookup(lookup(module.resource_group, "main", null), "location", null)
  rg_id                = lookup(lookup(module.resource_group, "main", null), "id", null)
  subnet_ids           = lookup(lookup(module.vnet, "main", null), "subnet_ids", null)
}


module "resource_group" {
  for_each = var.resource_group
  source   = "./modules/resource-group"
  name     = each.value["name"]
  location = each.value["location"]
}

module "vnet" {
  for_each      = var.vnet
  source        = "./modules/vnet"
  env           = var.env
  network_name  = each.key
  address_space = each.value["address_space"]
  dns_servers   = each.value["dns_servers"]
  subnets       = each.value["subnets"]
  peer_id       = each.value["peer_id"]
  rg_name       = lookup(lookup(module.resource_group, "main", null), "name", null)
  rg_location   = lookup(lookup(module.resource_group, "main", null), "location", null)
  rg_id         = lookup(lookup(module.resource_group, "main", null), "id", null)
}

