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

resource "azurerm_postgresql_flexible_server" "to_stop" {
  count = 2

  name                   = "test-to-stop-${count.index}-${random_pet.suffix.id}"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  version                = "15"
  administrator_login    = "psqladmin"
  administrator_password = "H@Sh1CoR3!"
  zone                   = "1"

  storage_mb = 32768

  sku_name = "B_Standard_B1ms"

  tags = {
    tostop = "true"
  }
}

resource "azurerm_postgresql_flexible_server" "do_not_stop" {
  count = 2

  name                   = "test-do-not-stop-${count.index}-${random_pet.suffix.id}"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  version                = "15"
  administrator_login    = "psqladmin"
  administrator_password = "H@Sh1CoR3!"
  zone                   = "1"

  storage_mb = 32768

  sku_name = "B_Standard_B1ms"

  tags = {
    tostop = "false"
  }
}


module "stop_postgresql" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  function_app_name             = "fpn-to-stop-${random_pet.suffix.id}"
  scheduler_action              = "stop"
  scheduler_ncrontab_expression = "0 22 * * *"
  postgresql_schedule           = true
  application_insights = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  }
  scheduler_tag = {
    tostop = "true"
  }
}

module "start_postgresql" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  function_app_name             = "fpn-to-start-${random_pet.suffix.id}"
  scheduler_action              = "start"
  scheduler_ncrontab_expression = "0 7 * * *"
  postgresql_schedule           = true
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
  stop_function_app_url        = module.stop_postgresql.default_hostname
  stop_function_app_master_key = module.stop_postgresql.function_app_master_key
  pg_1_to_stop_name            = azurerm_postgresql_flexible_server.to_stop[0].name
  pg_2_to_stop_name            = azurerm_postgresql_flexible_server.to_stop[1].name
  pg_1_do_not_stop_name        = azurerm_postgresql_flexible_server.do_not_stop[0].name
  pg_2_do_not_stop_name        = azurerm_postgresql_flexible_server.do_not_stop[1].name
}
