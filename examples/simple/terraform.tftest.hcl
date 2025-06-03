run "create_test_infrastructure" {
  command = apply

  assert {
    condition     = module.stop_virtual_machines.resource_group_name == azurerm_resource_group.test.name
    error_message = "Invalid resource group name"
  }

  assert {
    condition     = module.stop_virtual_machines.resource_group_name == azurerm_resource_group.test.name
    error_message = "Invalid resource group name"
  }

  assert {
    condition     = module.stop_virtual_machines.function_app_name == "fpn-to-stop-${random_pet.suffix.id}"
    error_message = "Invalid function app name"
  }

  assert {
    condition     = module.start_virtual_machines.function_app_name == "fpn-to-start-${random_pet.suffix.id}"
    error_message = "Invalid function app name"
  }

  assert {
    condition     = module.test_execution.vm_1_power_state == "deallocated"
    error_message = "Virtual machine 1 to stop is not deallocated"
  }

  assert {
    condition     = module.test_execution.vm_2_power_state == "deallocated"
    error_message = "Virtual machine 2 to stop is not deallocated"
  }

  assert {
    condition     = module.test_execution.vm_3_power_state == "deallocated"
    error_message = "Virtual machine 3 to stop is not deallocated"
  }

  assert {
    condition     = module.test_execution.vm_1_do_not_stop_power_state == "running"
    error_message = "Virtual machine 1 to stop is not Running"
  }

  assert {
    condition     = module.test_execution.vm_2_do_not_stop_power_state == "running"
    error_message = "Virtual machine 2 to stop is not Running"
  }
}
