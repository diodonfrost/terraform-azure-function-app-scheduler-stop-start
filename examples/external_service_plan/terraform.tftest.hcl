run "external_service_plan_test" {
  command = apply

  assert {
    condition     = module.external_service_plan.resource_group_name == azurerm_resource_group.this.name
    error_message = "Invalid resource group name"
  }

  assert {
    condition     = module.external_service_plan.function_app_name == "fpn-ext-${random_pet.suffix.id}"
    error_message = "Invalid function app name"
  }

  assert {
    condition     = module.external_service_plan.service_plan_name == azurerm_service_plan.external.name
    error_message = "Invalid service plan name"
  }

  assert {
    condition     = module.external_service_plan.service_plan_id == azurerm_service_plan.external.id
    error_message = "Invalid service plan id"
  }
}
