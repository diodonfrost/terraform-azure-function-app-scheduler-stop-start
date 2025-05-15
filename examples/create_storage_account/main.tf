resource "random_pet" "suffix" {}

resource "random_id" "suffix" {
  byte_length = 6
}

resource "azurerm_resource_group" "test" {
  name     = "test-${random_pet.suffix.id}"
  location = "swedencentral"
}

module "to_stop" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  function_app_name             = "fpn-to-stop-${random_pet.suffix.id}"
  service_plan_name             = "spn-to-stop-${random_pet.suffix.id}"
  create_storage_account        = true
  storage_account_name          = "tostop${random_id.suffix.hex}"
  scheduler_action              = "stop"
  scheduler_ncrontab_expression = "0 22 * * *"
  virtual_machine_schedule      = "true"
  scheduler_tag = {
    tostop = "true"
  }
}

module "to_start" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  function_app_name             = "fpn-to-start-${random_pet.suffix.id}"
  service_plan_name             = "spn-to-start-${random_pet.suffix.id}"
  create_storage_account        = true
  storage_account_name          = "tostart${random_id.suffix.hex}"
  scheduler_action              = "start"
  scheduler_ncrontab_expression = "0 7 * * *"
  virtual_machine_schedule      = "true"
  scheduler_tag = {
    tostop = "true"
  }
}
