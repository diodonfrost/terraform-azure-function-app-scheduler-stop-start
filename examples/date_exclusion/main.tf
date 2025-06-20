resource "random_pet" "suffix" {}

resource "random_id" "suffix" {
  byte_length = 6
}

resource "azurerm_resource_group" "test" {
  name     = "test-date-exclusion-${random_pet.suffix.id}"
  location = "swedencentral"
}

resource "azurerm_virtual_network" "test" {
  name                = "test-date-exclusion-${random_pet.suffix.id}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_subnet" "test" {
  name                 = "test-date-exclusion-${random_pet.suffix.id}"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "to_stop" {
  count = 2

  name                = "test-to-stop-${count.index}-${random_pet.suffix.id}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.test.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "to_stop" {
  count = 2

  name                = "test-to-stop-${count.index}-${random_pet.suffix.id}"
  resource_group_name = azurerm_resource_group.test.name
  location            = azurerm_resource_group.test.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.to_stop[count.index].id,
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

# Scheduler with date exclusions - stops VMs every weekday at 10 PM
module "stop_virtual_machines_with_exclusions" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  function_app_name             = "fpn-stop-exclusions-${random_pet.suffix.id}"
  scheduler_action              = "stop"
  scheduler_ncrontab_expression = "0 22 * * MON-FRI"
  virtual_machine_schedule      = "true"

  scheduler_tag = {
    tostop = "true"
  }
}

# Scheduler without exclusions - starts VMs every weekday at 7 AM but excludes holidays
module "start_virtual_machines" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  function_app_name             = "fpn-start-normal-${random_pet.suffix.id}"
  scheduler_action              = "start"
  scheduler_ncrontab_expression = "0 7 * * MON-FRI"
  virtual_machine_schedule      = "true"

  scheduler_excluded_dates = [
    "01-01",                         # New Year's Day
    "12-25",                         # Christmas Day
    "12-24",                         # Christmas Eve
    "07-04",                         # Independence Day (US)
    "11-24",                         # Thanksgiving (example date)
    "05-01",                         # Labor Day
    "12-31",                         # New Year's Eve
    formatdate("MM-DD", timestamp()) # Current date (for tests purposes)
  ]

  scheduler_tag = {
    tostop = "true"
  }
}
