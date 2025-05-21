resource "random_pet" "suffix" {}

resource "random_id" "suffix" {
  byte_length = 6
}

resource "azurerm_resource_group" "test" {
  name     = "test-${random_pet.suffix.id}"
  location = "swedencentral"
}

resource "azurerm_storage_account" "test" {
  name                     = "test${random_id.suffix.hex}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

module "stop_virtual_machines" {
  source = "../../"

  resource_group_name                 = azurerm_resource_group.test.name
  location                            = azurerm_resource_group.test.location
  function_app_name                   = "fpn-to-stop-${random_pet.suffix.id}"
  service_plan_name                   = "spn-to-stop-${random_pet.suffix.id}"
  storage_account_name                = azurerm_storage_account.test.name
  storage_account_resource_group_name = azurerm_storage_account.test.resource_group_name
  scheduler_action                    = "stop"
  scheduler_ncrontab_expression       = "0 22 * * *"
  virtual_machine_schedule            = "true"
  custom_app_settings = {
    "test" = random_pet.suffix.id
  }
  scheduler_tag = {
    tostop = "true"
  }
}

module "start_virtual_machines" {
  source = "../../"

  resource_group_name                 = azurerm_resource_group.test.name
  location                            = azurerm_resource_group.test.location
  function_app_name                   = "fpn-to-start-${random_pet.suffix.id}"
  service_plan_name                   = "spn-to-start-${random_pet.suffix.id}"
  storage_account_name                = azurerm_storage_account.test.name
  storage_account_resource_group_name = azurerm_storage_account.test.resource_group_name
  scheduler_action                    = "start"
  scheduler_ncrontab_expression       = "0 7 * * *"
  virtual_machine_schedule            = "true"
  custom_app_settings = {
    "test" = random_pet.suffix.id
  }
  scheduler_tag = {
    tostop = "true"
  }
}
