resource "random_pet" "suffix" {}

resource "random_id" "suffix" {
  byte_length = 6
}

resource "azurerm_resource_group" "terratest" {
  name     = "terratest-${random_pet.suffix.id}"
  location = "swedencentral"
}

resource "azurerm_container_group" "to_stop" {
  count = 2

  name                = "terratest-to-stop-${count.index}-${random_pet.suffix.id}"
  location            = azurerm_resource_group.terratest.location
  resource_group_name = azurerm_resource_group.terratest.name
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

  name                = "terratest-do-not-stop-${count.index}-${random_pet.suffix.id}"
  location            = azurerm_resource_group.terratest.location
  resource_group_name = azurerm_resource_group.terratest.name
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

  resource_group_name           = azurerm_resource_group.terratest.name
  location                      = azurerm_resource_group.terratest.location
  function_app_name             = "fpn-to-stop-${random_pet.suffix.id}"
  service_plan_name             = "spn-to-stop-${random_pet.suffix.id}"
  storage_account_name          = "santostop${random_id.suffix.hex}"
  scheduler_action              = "stop"
  scheduler_ncrontab_expression = "0 22 * * *"
  container_group_schedule      = "true"
  scheduler_tag = {
    tostop = "true"
  }
}

module "start_container_instances" {
  source = "../../"

  resource_group_name           = azurerm_resource_group.terratest.name
  location                      = azurerm_resource_group.terratest.location
  function_app_name             = "fpn-to-start-${random_pet.suffix.id}"
  service_plan_name             = "spn-to-start-${random_pet.suffix.id}"
  storage_account_name          = "santostart${random_id.suffix.hex}"
  scheduler_action              = "start"
  scheduler_ncrontab_expression = "0 7 * * *"
  container_group_schedule      = "true"
  scheduler_tag = {
    tostop = "true"
  }
}
