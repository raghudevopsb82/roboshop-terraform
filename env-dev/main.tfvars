env = "dev"
# components = {
#
#   frontend = {
#     name      = "frontend"
#     vm_size   = "Standard_DS1_v2"
#     container = true
#   }
#
#   mongodb = {
#     name      = "mongodb"
#     vm_size   = "Standard_DS1_v2"
#     container = false
#   }
#
#   catalogue = {
#     name      = "catalogue"
#     vm_size   = "Standard_DS1_v2"
#     container = true
#   }
#
#   user = {
#     name      = "user"
#     vm_size   = "Standard_DS1_v2"
#     container = true
#   }
#
#   cart = {
#     name      = "cart"
#     vm_size   = "Standard_DS1_v2"
#     container = true
#   }
#
#   mysql = {
#     name      = "mysql"
#     vm_size   = "Standard_DS1_v2"
#     container = false
#   }
#
#   shipping = {
#     name      = "shipping"
#     vm_size   = "Standard_DS1_v2"
#     container = true
#   }
#
#   payment = {
#     name      = "payment"
#     vm_size   = "Standard_DS1_v2"
#     container = true
#   }
#
#   rabbitmq = {
#     name      = "rabbitmq"
#     vm_size   = "Standard_DS1_v2"
#     container = false
#   }
#
#   redis = {
#     name      = "redis"
#     vm_size   = "Standard_DS1_v2"
#     container = false
#   }
# }

databases = {

  mongodb = {
    name      = "mongodb"
    vm_size   = "Standard_DS1_v2"
    container = false
  }

  mysql = {
    name      = "mysql"
    vm_size   = "Standard_DS1_v2"
    container = false
  }

  rabbitmq = {
    name      = "rabbitmq"
    vm_size   = "Standard_DS1_v2"
    container = false
  }

  redis = {
    name      = "redis"
    vm_size   = "Standard_DS1_v2"
    container = false
  }
}

resource_group = {
  main = {
    name     = "roboshop-dev"
    location = "UK West"
  }
}

vnet = {
  main = {
    address_space = ["10.100.0.0/16"]
    dns_servers   = ["10.100.0.4", "10.100.0.5"]
    subnets       = ["10.100.1.0/24", "10.100.2.0/24"]
    peer_id       = "/subscriptions/a906d619-0839-4738-a908-227a8b69d458/resourceGroups/project-setup-1/providers/Microsoft.Network/virtualNetworks/main"
  }
}


aks = {
  main = {
    kubernetes_version = "1.31.5"
    name               = "dev-aks"
    default_node_pool = {
      name                 = "default"
      node_count           = 2
      vm_size              = "Standard_D2_v2"
      auto_scaling_enabled = true
      min_count            = 2
      max_count            = 10
    }
  }
}

subscription_id = "a906d619-0839-4738-a908-227a8b69d458"


