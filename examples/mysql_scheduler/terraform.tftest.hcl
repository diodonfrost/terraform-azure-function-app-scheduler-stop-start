run "create_test_infrastructure" {
  command = apply

  assert {
    condition     = module.stop_mysql.resource_group_name == azurerm_resource_group.test.name
    error_message = "Invalid resource group name"
  }

  assert {
    condition     = module.stop_mysql.service_plan_name == "spn-to-stop-${random_pet.suffix.id}"
    error_message = "Invalid service plan name"
  }

  assert {
    condition     = module.stop_mysql.function_app_name == "fpn-to-stop-${random_pet.suffix.id}"
    error_message = "Invalid function app name"
  }

  assert {
    condition     = module.start_mysql.resource_group_name == azurerm_resource_group.test.name
    error_message = "Invalid resource group name"
  }

  assert {
    condition     = module.start_mysql.service_plan_name == "spn-to-start-${random_pet.suffix.id}"
    error_message = "Invalid service plan name"
  }

  assert {
    condition     = module.start_mysql.function_app_name == "fpn-to-start-${random_pet.suffix.id}"
    error_message = "Invalid function app name"
  }
}
