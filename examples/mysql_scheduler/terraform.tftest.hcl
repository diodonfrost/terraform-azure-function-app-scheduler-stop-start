run "create_test_infrastructure" {
  command = apply

  variables {
    test_mode = true
  }

  assert {
    condition     = module.stop_mysql.resource_group_name == azurerm_resource_group.test.name
    error_message = "Invalid resource group name"
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
    condition     = module.start_mysql.function_app_name == "fpn-to-start-${random_pet.suffix.id}"
    error_message = "Invalid function app name"
  }

  assert {
    condition     = module.test_execution.mysql_1_to_stop_state == "Stopping\n"
    error_message = "Invalid state for mysql_1_to_stop"
  }

  assert {
    condition     = module.test_execution.mysql_2_to_stop_state == "Stopping\n"
    error_message = "Invalid state for mysql_2_to_stop"
  }

  assert {
    condition     = module.test_execution.mysql_1_do_not_stop_state == "Ready\n"
    error_message = "Invalid state for mysql_1_do_not_stop"
  }

  assert {
    condition     = module.test_execution.mysql_2_do_not_stop_state == "Ready\n"
    error_message = "Invalid state for mysql_2_do_not_stop"
  }
}
