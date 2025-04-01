resource "random_pet" "suffix" {}

resource "random_id" "suffix" {
  byte_length = 6
}

resource "azurerm_resource_group" "terratest" {
  name     = "terratest-${random_pet.suffix.id}"
  location = "swedencentral"
}

resource "azurerm_postgresql_flexible_server" "to_stop" {
  count = 2

  name                   = "terratest-to-stop-${count.index}-${random_pet.suffix.id}"
  resource_group_name    = azurerm_resource_group.terratest.name
  location               = azurerm_resource_group.terratest.location
  version                = "15"
  administrator_login    = "psqladmin"
  administrator_password = "H@Sh1CoR3!"
  zone                   = "1"

  storage_mb = 32768

  sku_name = "GP_Standard_D2s_v3"

  tags = {
    tostop = "true"
  }
}

resource "azurerm_postgresql_flexible_server" "do_not_stop" {
  count = 2

  name                   = "terratest-do-not-stop-${count.index}-${random_pet.suffix.id}"
  resource_group_name    = azurerm_resource_group.terratest.name
  location               = azurerm_resource_group.terratest.location
  version                = "15"
  administrator_login    = "psqladmin"
  administrator_password = "H@Sh1CoR3!"
  zone                   = "1"

  storage_mb = 32768

  sku_name = "GP_Standard_D2s_v3"

  tags = {
    tostop = "false"
  }
}


module "stop_postgresql" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.terratest.name
  location                      = azurerm_resource_group.terratest.location
  function_app_name             = "fpn-to-stop-${random_pet.suffix.id}"
  service_plan_name             = "spn-to-stop-${random_pet.suffix.id}"
  storage_account_name          = "santostop${random_id.suffix.hex}"
  scheduler_action              = "stop"
  scheduler_ncrontab_expression = "0 22 * * *"
  postgresql_schedule           = true
  scheduler_tag = {
    tostop = "true"
  }
}

module "start_postgresql" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.terratest.name
  location                      = azurerm_resource_group.terratest.location
  function_app_name             = "fpn-to-start-${random_pet.suffix.id}"
  service_plan_name             = "spn-to-start-${random_pet.suffix.id}"
  storage_account_name          = "santostart${random_id.suffix.hex}"
  scheduler_action              = "start"
  scheduler_ncrontab_expression = "0 7 * * *"
  postgresql_schedule           = true
  scheduler_tag = {
    tostop = "true"
  }
}
