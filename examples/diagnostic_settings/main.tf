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

resource "azurerm_storage_account" "test" {
  name                     = "test${random_id.suffix.hex}"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_eventhub_namespace" "test" {
  name                = "test-${random_pet.suffix.id}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  sku                 = "Basic"
  capacity            = 1
}

resource "azurerm_eventhub" "test" {
  name                = "acceptanceTestEventHub"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  partition_count     = 1
  message_retention   = 1
}

resource "azurerm_eventhub_namespace_authorization_rule" "test" {
  name                = "azure-function"
  namespace_name      = azurerm_eventhub_namespace.test.name
  resource_group_name = azurerm_resource_group.test.name
  listen              = false
  send                = true
  manage              = false
}

resource "azurerm_storage_account" "logs" {
  name                     = random_id.suffix.hex
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


module "to_event_hub" {
  source = "../../"

  resource_group_name                 = azurerm_resource_group.test.name
  location                            = azurerm_resource_group.test.location
  function_app_name                   = "fpn-to-event-hub-${random_pet.suffix.id}"
  service_plan_name                   = "spn-to-event-hub-${random_pet.suffix.id}"
  storage_account_name                = azurerm_storage_account.test.name
  storage_account_resource_group_name = azurerm_storage_account.test.resource_group_name
  scheduler_action                    = "stop"
  scheduler_ncrontab_expression       = "0 7 * * *"
  virtual_machine_schedule            = "true"
  diagnostic_settings = {
    name                           = "test-${random_pet.suffix.id}"
    eventhub_name                  = azurerm_eventhub.test.name
    eventhub_authorization_rule_id = azurerm_eventhub_namespace_authorization_rule.test.id
  }
  application_insights = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  }
  scheduler_tag = {
    tostop = "true"
  }
}

module "to_log_analytic" {
  source = "../../"

  resource_group_name                 = azurerm_resource_group.test.name
  location                            = azurerm_resource_group.test.location
  function_app_name                   = "fpn-to-log-analytic-${random_pet.suffix.id}"
  service_plan_name                   = "spn-to-log-analytic-${random_pet.suffix.id}"
  storage_account_name                = azurerm_storage_account.test.name
  storage_account_resource_group_name = azurerm_storage_account.test.resource_group_name
  scheduler_action                    = "stop"
  scheduler_ncrontab_expression       = "0 7 * * *"
  virtual_machine_schedule            = "true"
  diagnostic_settings = {
    name             = "test-${random_pet.suffix.id}"
    log_analytics_id = azurerm_log_analytics_workspace.test.id
  }
  application_insights = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  }
  scheduler_tag = {
    tostop = "true"
  }
}

module "to_storage_account" {
  source = "../../"

  resource_group_name                 = azurerm_resource_group.test.name
  location                            = azurerm_resource_group.test.location
  function_app_name                   = "fpn-to-storage-account-${random_pet.suffix.id}"
  service_plan_name                   = "spn-to-storage-account-${random_pet.suffix.id}"
  storage_account_name                = azurerm_storage_account.test.name
  storage_account_resource_group_name = azurerm_storage_account.test.resource_group_name
  scheduler_action                    = "stop"
  scheduler_ncrontab_expression       = "0 7 * * *"
  virtual_machine_schedule            = "true"
  diagnostic_settings = {
    name               = "test-${random_pet.suffix.id}"
    storage_account_id = azurerm_storage_account.logs.id
  }
  application_insights = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  }
  scheduler_tag = {
    tostop = "true"
  }
}
