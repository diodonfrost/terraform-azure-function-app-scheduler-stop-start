output "vm_1_power_state" {
  description = "Power state of the first VM (should be 'running' due to date exclusion)"
  value       = data.azurerm_virtual_machine.vm_1_to_stop.power_state
}

output "vm_2_power_state" {
  description = "Power state of the second VM (should be 'running' due to date exclusion)"
  value       = data.azurerm_virtual_machine.vm_2_to_stop.power_state
}
