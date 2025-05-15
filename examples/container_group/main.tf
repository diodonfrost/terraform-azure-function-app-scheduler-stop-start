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

resource "azurerm_container_group" "to_stop" {
  count = 2

  name                = "test-to-stop-${count.index}-${random_pet.suffix.id}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_address_type     = "None"
  os_type             = "Linux"

  container {
    name   = "hello-world"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu    = "0.5"
    memory = "1.5"
  }

  tags = {
    tostop = "true"
  }
}

resource "azurerm_container_group" "do_not_stop" {
  count = 2

  name                = "test-do-not-stop-${count.index}-${random_pet.suffix.id}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  ip_address_type     = "None"
  os_type             = "Linux"

  container {
    name   = "hello-world"
    image  = "mcr.microsoft.com/azuredocs/aci-helloworld:latest"
    cpu    = "0.5"
    memory = "1.5"
  }

  tags = {
    tostop = "false"
  }
}


module "stop_container_instances" {
  source = "../../"

  resource_group_name                 = azurerm_resource_group.test.name
  location                            = azurerm_resource_group.test.location
  function_app_name                   = "fpn-to-stop-${random_pet.suffix.id}"
  service_plan_name                   = "spn-to-stop-${random_pet.suffix.id}"
  storage_account_name                = azurerm_storage_account.test.name
  storage_account_resource_group_name = azurerm_storage_account.test.resource_group_name
  scheduler_action                    = "stop"
  scheduler_ncrontab_expression       = "0 22 * * *"
  container_group_schedule            = "true"
  application_insights = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  }
  scheduler_tag = {
    tostop = "true"
  }
}

module "start_container_instances" {
  source = "../../"

  resource_group_name                 = azurerm_resource_group.test.name
  location                            = azurerm_resource_group.test.location
  function_app_name                   = "fpn-to-start-${random_pet.suffix.id}"
  service_plan_name                   = "spn-to-start-${random_pet.suffix.id}"
  storage_account_name                = azurerm_storage_account.test.name
  storage_account_resource_group_name = azurerm_storage_account.test.resource_group_name
  scheduler_action                    = "start"
  scheduler_ncrontab_expression       = "0 7 * * *"
  container_group_schedule            = "true"
  application_insights = {
    enabled                    = true
    log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
  }
  scheduler_tag = {
    tostop = "true"
  }
}
