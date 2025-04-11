output "vm_1_power_state" {
  description = "The power state of the first VM that should be stopped"
  value       = data.azurerm_virtual_machine.vm_1_to_stop.power_state
}

output "vm_2_power_state" {
  description = "The power state of the second VM that should be stopped"
  value       = data.azurerm_virtual_machine.vm_2_to_stop.power_state
}

output "vm_3_power_state" {
  description = "The power state of the third VM that should be stopped"
  value       = data.azurerm_virtual_machine.vm_3_to_stop.power_state
}

output "vm_1_do_not_stop_power_state" {
  description = "The power state of the first VM that should not be stopped"
  value       = data.azurerm_virtual_machine.vm_1_do_not_stop.power_state
}

output "vm_2_do_not_stop_power_state" {
  description = "The power state of the second VM that should not be stopped"
  value       = data.azurerm_virtual_machine.vm_2_do_not_stop.power_state
}
