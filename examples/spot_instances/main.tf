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

resource "azurerm_network_interface" "to_stop" {
  name                = "test-to-stop-${random_pet.suffix.id}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "to_stop" {
  name                = "test-to-stop-${random_pet.suffix.id}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  size                = "Standard_D2s_v4"
  priority            = "Spot"
  eviction_policy     = "Deallocate"
  max_bid_price       = -1
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.to_stop.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.test.public_key_openssh
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

resource "tls_private_key" "test" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


module "stop_virtual_machines" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  function_app_name             = "fpn-to-stop-${random_pet.suffix.id}"
  service_plan_name             = "spn-to-stop-${random_pet.suffix.id}"
  storage_account_name          = "santostop${random_id.suffix.hex}"
  scheduler_action              = "stop"
  scheduler_ncrontab_expression = "0 22 * * *"
  virtual_machine_schedule      = "true"
  application_insights = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  }
  scheduler_tag = {
    tostop = "true"
  }
}

module "start_virtual_machines" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  function_app_name             = "fpn-to-start-${random_pet.suffix.id}"
  service_plan_name             = "spn-to-start-${random_pet.suffix.id}"
  storage_account_name          = "santostart${random_id.suffix.hex}"
  scheduler_action              = "start"
  scheduler_ncrontab_expression = "0 7 * * *"
  virtual_machine_schedule      = "true"
  application_insights = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  }
  scheduler_tag = {
    tostop = "true"
  }
}
