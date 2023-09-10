resource "random_pet" "suffix" {}

resource "random_id" "suffix" {
  byte_length = 6
}

resource "azurerm_resource_group" "terratest" {
  name     = "terratest-${random_pet.suffix.id}"
  location = "East US"
}

resource "azurerm_virtual_network" "terratest" {
  name                = "terratest-${random_pet.suffix.id}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.terratest.location
  resource_group_name = azurerm_resource_group.terratest.name
}

resource "azurerm_subnet" "terratest" {
  name                 = "terratest-${random_pet.suffix.id}"
  resource_group_name  = azurerm_resource_group.terratest.name
  virtual_network_name = azurerm_virtual_network.terratest.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "to_stop" {
  count = 3

  name                = "terratest-to-stop-${count.index}-${random_pet.suffix.id}"
  location            = azurerm_resource_group.terratest.location
  resource_group_name = azurerm_resource_group.terratest.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.terratest.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "to_stop" {
  count = 3

  name                = "terratest-to-stop-${count.index}-${random_pet.suffix.id}"
  resource_group_name = azurerm_resource_group.terratest.name
  location            = azurerm_resource_group.terratest.location
  size                = "Standard_B2ats_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.to_stop[count.index].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.terratest.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  tags = {
    tostop = "true"
  }
}

resource "azurerm_network_interface" "do_not_stop" {
  count = 2

  name                = "terratest-do-not-stop-${count.index}-${random_pet.suffix.id}"
  location            = azurerm_resource_group.terratest.location
  resource_group_name = azurerm_resource_group.terratest.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.terratest.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "do_not_stop" {
  count = 2

  name                = "terratest-do-not-stop-${count.index}-${random_pet.suffix.id}"
  resource_group_name = azurerm_resource_group.terratest.name
  location            = azurerm_resource_group.terratest.location
  size                = "Standard_B2ats_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.do_not_stop[count.index].id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.terratest.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  tags = {
    tostop = "false"
  }
}

resource "tls_private_key" "terratest" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


module "stop_virtual_machines" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.terratest.name
  location                      = azurerm_resource_group.terratest.location
  function_app_name_prefix      = "fpn-to-stop-${random_pet.suffix.id}"
  service_plan_name             = "spn-to-stop-${random_pet.suffix.id}"
  storage_account_name          = "santostop${random_id.suffix.hex}"
  scheduler_action              = "stop"
  scheduler_ncrontab_expression = "0 22 * * *"
  virtual_machine_schedule      = "true"
  scheduler_tag = {
    tostop = "true"
  }
}

module "start_virtual_machines" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.terratest.name
  location                      = azurerm_resource_group.terratest.location
  function_app_name_prefix      = "fpn-to-start-${random_pet.suffix.id}"
  service_plan_name             = "spn-to-start-${random_pet.suffix.id}"
  storage_account_name          = "santostart${random_id.suffix.hex}"
  scheduler_action              = "start"
  scheduler_ncrontab_expression = "0 7 * * *"
  virtual_machine_schedule      = "true"
  scheduler_tag = {
    tostop = "true"
  }
}
