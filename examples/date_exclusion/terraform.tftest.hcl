run "create_test_infrastructure" {
  command = apply

  variables {
    test_mode = true
  }

  assert {
    condition     = module.stop_virtual_machines_with_exclusions.resource_group_name == azurerm_resource_group.test.name
    error_message = "Invalid resource group name"
  }

  assert {
    condition     = module.stop_virtual_machines_with_exclusions.function_app_name == "fpn-stop-exclusions-${random_pet.suffix.id}"
    error_message = "Invalid function app name"
  }

  assert {
    condition     = module.start_virtual_machines.function_app_name == "fpn-start-normal-${random_pet.suffix.id}"
    error_message = "Invalid function app name"
  }

  assert {
    condition     = module.test_execution[0].vm_1_power_state == "running"
    error_message = "VM 1 should remain running due to date exclusion"
  }

  assert {
    condition     = module.test_execution[0].vm_2_power_state == "running"
    error_message = "VM 2 should remain running due to date exclusion"
  }
}
