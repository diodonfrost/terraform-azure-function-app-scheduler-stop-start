resource "random_pet" "suffix" {}

resource "random_id" "suffix" {
  byte_length = 6
}

resource "azurerm_resource_group" "terratest" {
  name     = "terratest-${random_pet.suffix.id}"
  location = "East US"
}

resource "azurerm_mysql_flexible_server" "to_stop" {
  count = 2

  name                   = "terratest-to-stop-${count.index}-${random_pet.suffix.id}"
  resource_group_name    = azurerm_resource_group.terratest.name
  location               = azurerm_resource_group.terratest.location
  version                = "8.0.21"
  administrator_login    = "psqladmin"
  administrator_password = "H@Sh1CoR3!"
  zone                   = "1"
  sku_name               = "GP_Standard_D2ds_v4"

  storage {
    size_gb = 32
  }

  tags = {
    tostop = "true"
  }
}

resource "azurerm_mysql_flexible_server" "do_not_stop" {
  count = 2

  name                   = "terratest-do-not-stop-${count.index}-${random_pet.suffix.id}"
  resource_group_name    = azurerm_resource_group.terratest.name
  location               = azurerm_resource_group.terratest.location
  version                = "8.0.21"
  administrator_login    = "psqladmin"
  administrator_password = "H@Sh1CoR3!"
  zone                   = "1"
  sku_name               = "GP_Standard_D2ds_v4"

  storage {
    size_gb = 32
  }

  tags = {
    tostop = "false"
  }
}


module "stop_mysql" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.terratest.name
  location                      = azurerm_resource_group.terratest.location
  function_app_name_prefix      = "fpn-to-stop-${random_pet.suffix.id}"
  service_plan_name             = "spn-to-stop-${random_pet.suffix.id}"
  storage_account_name          = "santostop${random_id.suffix.hex}"
  scheduler_action              = "stop"
  scheduler_ncrontab_expression = "0 22 * * *"
  mysql_schedule                = true
  scheduler_tag = {
    tostop = "true"
  }
}

module "start_mysql" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.terratest.name
  location                      = azurerm_resource_group.terratest.location
  function_app_name_prefix      = "fpn-to-start-${random_pet.suffix.id}"
  service_plan_name             = "spn-to-start-${random_pet.suffix.id}"
  storage_account_name          = "santostart${random_id.suffix.hex}"
  scheduler_action              = "start"
  scheduler_ncrontab_expression = "0 7 * * *"
  mysql_schedule                = true
  scheduler_tag = {
    tostop = "true"
  }
}
