resource "random_pet" "suffix" {}

resource "random_id" "suffix" {
  byte_length = 6
}

resource "azurerm_resource_group" "test" {
  name     = "test-${random_pet.suffix.id}"
  location = "swedencentral"
}

resource "azurerm_log_analytics_workspace" "test" {
  name                = "test-${random_pet.suffix.id}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_virtual_network" "test" {
  name                = "test-${random_pet.suffix.id}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "test-${random_pet.suffix.id}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_linux_virtual_machine_scale_set" "to_stop" {
  count = 2

  name                = "test-to-stop-${count.index}-${random_pet.suffix.id}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_B1s"
  instances           = 2
  admin_username      = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.test.public_key_openssh
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "test-${count.index}"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.test.id
    }
  }

  tags = {
    tostop = "true"
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "do_not_stop" {
  count = 2

  name                = "test-do-not-stop-${count.index}-${random_pet.suffix.id}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  sku                 = "Standard_B1s"
  instances           = 2
  admin_username      = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.test.public_key_openssh
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "test-${count.index}"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.test.id
    }
  }

  tags = {
    tostop = "false"
  }
}

resource "tls_private_key" "test" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


module "stop_scale_sets" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  function_app_name             = "fpn-to-stop-${random_pet.suffix.id}"
  service_plan_name             = "spn-to-stop-${random_pet.suffix.id}"
  storage_account_name          = "santostop${random_id.suffix.hex}"
  scheduler_action              = "stop"
  scheduler_ncrontab_expression = "0 22 * * *"
  scale_set_schedule            = "true"
  application_insights = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  }
  scheduler_tag = {
    tostop = "true"
  }
}

module "start_scale_sets" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  function_app_name             = "fpn-to-start-${random_pet.suffix.id}"
  service_plan_name             = "spn-to-start-${random_pet.suffix.id}"
  storage_account_name          = "santostart${random_id.suffix.hex}"
  scheduler_action              = "start"
  scheduler_ncrontab_expression = "0 7 * * *"
  scale_set_schedule            = "true"
  application_insights = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  }
  scheduler_tag = {
    tostop = "true"
  }
}

module "test_execution" {
  source = "./test-execution"

  resource_group_name          = azurerm_resource_group.test.name
  stop_function_app_url        = module.stop_scale_sets.default_hostname
  stop_function_app_master_key = module.stop_scale_sets.function_app_master_key
  scale_set_1_to_stop_name     = azurerm_linux_virtual_machine_scale_set.to_stop[0].name
  scale_set_2_to_stop_name     = azurerm_linux_virtual_machine_scale_set.to_stop[1].name
  scale_set_1_do_not_stop_name = azurerm_linux_virtual_machine_scale_set.do_not_stop[0].name
  scale_set_2_do_not_stop_name = azurerm_linux_virtual_machine_scale_set.do_not_stop[1].name
}
