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
  }
}




