resource "random_pet" "suffix" {}

resource "random_id" "suffix" {
  byte_length = 6
}

resource "azurerm_resource_group" "terratest" {
  name     = "terratest-${random_pet.suffix.id}"
  location = "East US"
}

resource "azurerm_virtual_network" "terratest" {
  name                = "terratest-${random_pet.suffix.id}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.terratest.location
  resource_group_name = azurerm_resource_group.terratest.name
}

resource "azurerm_subnet" "terratest" {
  name                 = "terratest-${random_pet.suffix.id}"
  resource_group_name  = azurerm_resource_group.terratest.name
  virtual_network_name = azurerm_virtual_network.terratest.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_kubernetes_cluster" "to_stop" {
  count = 2

  name                = "terratest-to-stop-${count.index}-${random_pet.suffix.id}"
  location            = azurerm_resource_group.terratest.location
  resource_group_name = azurerm_resource_group.terratest.name
  dns_prefix          = "to-stop-${count.index}-${random_pet.suffix.id}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    tostop = "true"
  }
}

resource "azurerm_kubernetes_cluster" "do_no_not" {
  count = 2

  name                = "terratest-do-not-stop-${count.index}-${random_pet.suffix.id}"
  location            = azurerm_resource_group.terratest.location
  resource_group_name = azurerm_resource_group.terratest.name
  dns_prefix          = "do-not-stop-${count.index}-${random_pet.suffix.id}"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    tostop = "false"
  }
}

module "stop_virtual_machines" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.terratest.name
  location                      = azurerm_resource_group.terratest.location
  function_app_name             = "fpn-to-stop-${random_pet.suffix.id}"
  service_plan_name             = "spn-to-stop-${random_pet.suffix.id}"
  storage_account_name          = "santostop${random_id.suffix.hex}"
  scheduler_action              = "stop"
  scheduler_ncrontab_expression = "0 22 * * *"
  aks_schedule                  = "true"
  scheduler_tag = {
    tostop = "true"
  }
}

module "start_virtual_machines" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.terratest.name
  location                      = azurerm_resource_group.terratest.location
  function_app_name             = "fpn-to-start-${random_pet.suffix.id}"
  service_plan_name             = "spn-to-start-${random_pet.suffix.id}"
  storage_account_name          = "santostart${random_id.suffix.hex}"
  scheduler_action              = "start"
  scheduler_ncrontab_expression = "0 7 * * *"
  aks_schedule                  = "true"
  scheduler_tag = {
    tostop = "true"
  }
}
