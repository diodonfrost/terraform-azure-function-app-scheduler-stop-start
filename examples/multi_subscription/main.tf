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
  location            = azurerm_resource_group.subscription_2.location
  resource_group_name = azurerm_resource_group.subscription_2.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "test" {
  provider = azurerm.subscription_2

  name                = "test-${random_pet.suffix.id}"
  location            = azurerm_resource_group.subscription_2.location
  resource_group_name = azurerm_resource_group.subscription_2.name
  workspace_id        = azurerm_log_analytics_workspace.test.id
  application_type    = "other"
}

module "stop_virtual_machines" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.subscription_1.name
  location                      = azurerm_resource_group.subscription_1.location
  function_app_name             = "fpn-to-stop-${random_pet.suffix.id}"
  scheduler_action              = "stop"
  scheduler_ncrontab_expression = "0 0 22 * * 1-5"
  virtual_machine_schedule      = "true"
  application_insights = {
    connection_string   = azurerm_application_insights.test.connection_string
    instrumentation_key = azurerm_application_insights.test.instrumentation_key
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
  scheduler_ncrontab_expression = "0 0 7 * * 1-5"
  virtual_machine_schedule      = "true"
  application_insights = {
    connection_string   = azurerm_application_insights.test.connection_string
    instrumentation_key = azurerm_application_insights.test.instrumentation_key
  }
  subscription_ids = [
    var.subscription_1_id,
    var.subscription_2_id
  ]
  scheduler_tag = {
    tostop = "true"
  }
}
