resource "random_pet" "suffix" {}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "azurerm_resource_group" "test" {
  name     = "test-external-storage-${random_pet.suffix.id}"
  location = "swedencentral"
}

resource "azurerm_storage_account" "external" {
  name                     = "extst${replace(random_pet.suffix.id, "-", "")}${random_id.suffix.hex}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

module "stop_virtual_machines_with_external_storage" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  function_app_name             = "fpn-ext-storage-${random_pet.suffix.id}"
  scheduler_action              = "stop"
  scheduler_ncrontab_expression = "0 0 22 * * 1-5"
  virtual_machine_schedule      = false
  existing_storage_account = {
    name                = azurerm_storage_account.external.name
    resource_group_name = azurerm_storage_account.external.resource_group_name
  }
  scheduler_tag = {
    tostop = "true"
  }
}

module "start_virtual_machines_with_external_storage_auto_key" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  function_app_name             = "fpn-ext-auto-${random_pet.suffix.id}"
  scheduler_action              = "start"
  scheduler_ncrontab_expression = "0 0 7 * * 1-5"
  virtual_machine_schedule      = false
  existing_storage_account = {
    name                = azurerm_storage_account.external.name
    resource_group_name = azurerm_storage_account.external.resource_group_name
  }
  scheduler_tag = {
    tostop = "true"
  }
}
