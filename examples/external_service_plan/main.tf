resource "random_pet" "suffix" {}

resource "azurerm_resource_group" "this" {
  name     = "rg-external-asp-${random_pet.suffix.id}"
  location = "swedencentral"
}

resource "azurerm_service_plan" "external" {
  name                = "asp-external-${random_pet.suffix.id}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  os_type             = "Linux"
  sku_name            = "Y1"
}


module "external_service_plan" {
  source = "../.."

  resource_group_name           = azurerm_resource_group.this.name
  location                      = azurerm_resource_group.this.location
  function_app_name             = "fpn-ext-${random_pet.suffix.id}"
  scheduler_action              = "start"
  scheduler_ncrontab_expression = "0 0 7 * * 1-5"
  virtual_machine_schedule      = true
  existing_service_plan = {
    name                = azurerm_service_plan.external.name
    resource_group_name = azurerm_service_plan.external.resource_group_name
  }
  scheduler_tag = {
    tostop = "true"
  }
}
