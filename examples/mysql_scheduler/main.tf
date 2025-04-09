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

resource "azurerm_mysql_flexible_server" "to_stop" {
  count = 2

  name                   = "test-to-stop-${count.index}-${random_pet.suffix.id}"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  version                = "8.0.21"
  administrator_login    = "psqladmin"
  administrator_password = "H@Sh1CoR3!"
  zone                   = "1"
  sku_name               = "B_Standard_B1ms"

  storage {
    size_gb = 32
  }

  tags = {
    tostop = "true"
  }
}

resource "azurerm_mysql_flexible_server" "do_not_stop" {
  count = 2

  name                   = "test-do-not-stop-${count.index}-${random_pet.suffix.id}"
  resource_group_name    = azurerm_resource_group.test.name
  location               = azurerm_resource_group.test.location
  version                = "8.0.21"
  administrator_login    = "psqladmin"
  administrator_password = "H@Sh1CoR3!"
  zone                   = "1"
  sku_name               = "B_Standard_B1ms"

  storage {
    size_gb = 32
  }

  tags = {
    tostop = "false"
  }
}


module "stop_mysql" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  function_app_name             = "fpn-to-stop-${random_pet.suffix.id}"
  service_plan_name             = "spn-to-stop-${random_pet.suffix.id}"
  storage_account_name          = "santostop${random_id.suffix.hex}"
  scheduler_action              = "stop"
  scheduler_ncrontab_expression = "0 22 * * *"
  mysql_schedule                = true
  application_insights = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  }
  scheduler_tag = {
    tostop = "true"
  }
}

module "start_mysql" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  function_app_name             = "fpn-to-start-${random_pet.suffix.id}"
  service_plan_name             = "spn-to-start-${random_pet.suffix.id}"
  storage_account_name          = "santostart${random_id.suffix.hex}"
  scheduler_action              = "start"
  scheduler_ncrontab_expression = "0 7 * * *"
  mysql_schedule                = true
  application_insights = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  }
  scheduler_tag = {
    tostop = "true"
  }
}
