# resource "azurerm_public_ip" "main" {
#   name                = "${var.component}-${var.env}-ip"
#   location            = data.azurerm_resource_group.main.location
#   resource_group_name = data.azurerm_resource_group.main.name
#   allocation_method   = "Static"
#
#   tags = {
#     component = "${var.component}-${var.env}-ip"
#   }
# }

resource "azurerm_network_interface" "main" {
  name                = "${var.component}-${var.env}-nic"
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_ids[0]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "main" {
  name                = "${var.component}-${var.env}-nsg"
  location            = var.rg_location
  resource_group_name = var.rg_name

  security_rule {
    name                       = "default-deny"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.bastion_node
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "db-port"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.port
    source_address_prefixes    = var.subnets_cidr
    destination_address_prefix = "*"
  }

  tags = {
    component = "${var.component}-${var.env}-nsg"
  }
}


resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_dns_a_record" "main" {
  name                = "${var.component}-${var.env}"
  zone_name           = "azdevopsb82.online"
  resource_group_name = data.azurerm_resource_group.default.name
  ttl                 = 10
  records             = [azurerm_network_interface.main.private_ip_address]
}


resource "azurerm_virtual_machine" "main" {
  depends_on            = [azurerm_network_interface_security_group_association.main, azurerm_dns_a_record.main]
  name                  = "${var.component}-${var.env}"
  location            = var.rg_location
  resource_group_name = var.rg_name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = var.vm_size

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true


  storage_image_reference {
    id = "/subscriptions/${var.subscription_id}/resourceGroups/compute-gallery/providers/Microsoft.Compute/galleries/LDORHEL9/images/la-rhel9-devops-practice/versions/1.0.0"
  }

  storage_os_disk {
    name              = "${var.component}-${var.env}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = var.component
    admin_username = data.vault_generic_secret.ssh.data["admin_username"]
    admin_password = data.vault_generic_secret.ssh.data["admin_password"]
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    component         = "${var.component}-${var.env}"
    prometheus_scrape = "true"
  }
}

locals {
  component = var.container ? "${var.component}-docker" : var.component
}

resource "null_resource" "ansible" {

  depends_on = [azurerm_virtual_machine.main]

  provisioner "remote-exec" {

    connection {
      type     = "ssh"
      user     = data.vault_generic_secret.ssh.data["admin_username"]
      password = data.vault_generic_secret.ssh.data["admin_password"]
      host     = azurerm_network_interface.main.private_ip_address
    }

    inline = [
      "sudo dnf install python3.12-pip -y",
      "sudo pip3.12 install ansible hvac",
      "ansible-pull -i localhost, -U https://github.com/raghudevopsb82/roboshop-ansible roboshop.yml -e app_name=${local.component} -e ENV=${var.env} -e vault_token=${var.vault_token}"
    ]
  }
}

