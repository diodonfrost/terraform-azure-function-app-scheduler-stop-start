resource "random_pet" "suffix" {}

resource "random_id" "suffix" {
  byte_length = 6
}

resource "tls_private_key" "test" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_log_analytics_workspace" "test" {
  provider = azurerm.subscription_2

  name                = "test-${random_pet.suffix.id}"
  location            = azurerm_resource_group.subscription_1.location
  resource_group_name = azurerm_resource_group.subscription_1.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "stop_virtual_machines" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.subscription_1.name
  location                      = azurerm_resource_group.subscription_1.location
  function_app_name             = "fpn-to-stop-${random_pet.suffix.id}"
  scheduler_action              = "stop"
  scheduler_ncrontab_expression = "0 22 * * *"
  virtual_machine_schedule      = "true"
  application_insights = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  }
  subscription_ids = [
    var.subscription_1_id,
    var.subscription_2_id
  ]
  scheduler_tag = {
    tostop = "true"
  }
}

module "start_virtual_machines" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.subscription_1.name
  location                      = azurerm_resource_group.subscription_1.location
  function_app_name             = "fpn-to-start-${random_pet.suffix.id}"
  scheduler_action              = "start"
  scheduler_ncrontab_expression = "0 7 * * *"
  virtual_machine_schedule      = "true"
  application_insights = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  }
  subscription_ids = [
    var.subscription_1_id,
    var.subscription_2_id
  ]
  scheduler_tag = {
    tostop = "true"
  }
}
