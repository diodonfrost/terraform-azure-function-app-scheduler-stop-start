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
}

#run "verify_function_app_execution" {
#  command = plan
#
#  module {
#    source = "./test-execution"
#
#    resource_group_name = module.stop_virtual_machines.resource_group_name
#    function_app_name   = module.stop_virtual_machines.function_app_name
#    vm_1_to_stop        = azurerm_linux_virtual_machine[0].to_stop.name
#    vm_2_to_stop        = azurerm_linux_virtual_machine[1].to_stop.name
#    vm_3_to_stop        = azurerm_linux_virtual_machine[2].to_stop.name
#    vm_1_do_not_stop    = azurerm_linux_virtual_machine[0].do_not_stop.name
#    vm_2_do_not_stop    = azurerm_linux_virtual_machine[1].do_not_stop.name
#  }
#
#  assert {
#    condition     = output.vm_1_to_stop.power_state == "Deallocated"
#    error_message = "Virtual machine 1 to stop is not deallocated"
#  }
#
#  assert {
#    condition     = output.vm_2_to_stop.power_state == "Deallocated"
#    error_message = "Virtual machine 2 to stop is not deallocated"
#  }
#
#  assert {
#    condition     = output.vm_3_to_stop.power_state == "Deallocated"
#    error_message = "Virtual machine 3 to stop is not deallocated"
#  }
#
#  assert {
#    condition     = output.vm_1_to_stop.power_state == "Running"
#    error_message = "Virtual machine 1 to stop is not Running"
#  }
#
#  assert {
#    condition     = output.vm_2_to_stop.power_state == "Running"
#    error_message = "Virtual machine 2 to stop is not Running"
#  }
#}
