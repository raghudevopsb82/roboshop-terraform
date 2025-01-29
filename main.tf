module "databases" {
  for_each    = var.databases
  source      = "./modules/vm"
  component   = each.value["name"]
  vm_size     = each.value["vm_size"]
  env         = var.env
  vault_token = var.token
  container   = each.value["container"]
}

# module "aks" {
#   source = "./modules/aks"
# }
