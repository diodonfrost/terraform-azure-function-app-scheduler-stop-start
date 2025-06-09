run "create_test_infrastructure" {
  command = apply

  variables {
    test_mode = true
  }

  assert {
    condition     = module.stop_scale_sets.resource_group_name == azurerm_resource_group.test.name
    error_message = "Invalid resource group name"
  }

  assert {
    condition     = module.stop_scale_sets.function_app_name == "fpn-to-stop-${random_pet.suffix.id}"
    error_message = "Invalid function app name"
  }

  assert {
    condition     = module.start_scale_sets.resource_group_name == azurerm_resource_group.test.name
    error_message = "Invalid resource group name"
  }

  assert {
    condition     = module.start_scale_sets.function_app_name == "fpn-to-start-${random_pet.suffix.id}"
    error_message = "Invalid function app name"
  }

  assert {
    condition     = module.test_execution.to_stop_1_power_state == "deallocated" || module.test_execution.to_stop_1_power_state == "deallocating"
    error_message = "Scale Set 1 Power State is not deallocated"
  }

  assert {
    condition     = module.test_execution.to_stop_2_power_state == "deallocated" || module.test_execution.to_stop_2_power_state == "deallocating"
    error_message = "Scale Set 2 Power State is not deallocated"
  }

  assert {
    condition     = module.test_execution.do_not_stop_1_power_state == "running"
    error_message = "Scale Set 1 Do Not Stop Power State is not running"
  }

  assert {
    condition     = module.test_execution.do_not_stop_2_power_state == "running"
    error_message = "Scale Set 2 Do Not Stop Power State is not running"
  }
}
