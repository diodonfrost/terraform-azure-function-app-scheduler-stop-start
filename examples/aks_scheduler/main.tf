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

resource "azurerm_application_insights" "test" {
  name                = "test-${random_pet.suffix.id}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  workspace_id        = azurerm_log_analytics_workspace.test.id
  application_type    = "other"
}

resource "azurerm_kubernetes_cluster" "to_stop" {
  count = 2

  name                = "to-stop-${count.index}-${random_pet.suffix.id}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "to-stop-${count.index}-${random_pet.suffix.id}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v5"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    tostop = "true"
  }
}

resource "azurerm_kubernetes_cluster" "do_not_stop" {
  count = 2

  name                = "do-not-stop-${count.index}-${random_pet.suffix.id}"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = "do-not-stop-${count.index}-${random_pet.suffix.id}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v5"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    tostop = "false"
  }
}

module "stop_aks_cluster" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  function_app_name             = "fpn-to-stop-${random_pet.suffix.id}"
  scheduler_action              = "stop"
  scheduler_ncrontab_expression = "0 0 22 * * 1-5"
  aks_schedule                  = "true"
  application_insights = {
    connection_string   = azurerm_application_insights.test.connection_string
    instrumentation_key = azurerm_application_insights.test.instrumentation_key
  }
  scheduler_tag = {
    tostop = "true"
  }
}

module "start_aks_cluster" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.test.name
  location                      = azurerm_resource_group.test.location
  function_app_name             = "fpn-to-start-${random_pet.suffix.id}"
  scheduler_action              = "start"
  scheduler_ncrontab_expression = "0 0 7 * * 1-5"
  aks_schedule                  = "true"
  application_insights = {
    connection_string   = azurerm_application_insights.test.connection_string
    instrumentation_key = azurerm_application_insights.test.instrumentation_key
  }
  scheduler_tag = {
    tostop = "true"
  }
}

module "test_execution" {
  count  = var.test_mode ? 1 : 0
  source = "./test-execution"

  resource_group_name          = azurerm_resource_group.test.name
  stop_function_app_url        = module.stop_aks_cluster.default_hostname
  stop_function_app_master_key = module.stop_aks_cluster.function_app_master_key
  aks_1_to_stop_name           = azurerm_kubernetes_cluster.to_stop[0].name
  aks_2_to_stop_name           = azurerm_kubernetes_cluster.to_stop[1].name
  aks_1_do_not_stop_name       = azurerm_kubernetes_cluster.do_not_stop[0].name
  aks_2_do_not_stop_name       = azurerm_kubernetes_cluster.do_not_stop[1].name
}
