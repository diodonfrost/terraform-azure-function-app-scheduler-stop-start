output "to_stop_1_power_state" {
  description = "Scale Set 1 Power State"
  value       = data.azurerm_virtual_machine_scale_set.to_stop_1.instances[0].power_state
}

output "to_stop_2_power_state" {
  description = "Scale Set 2 Power State"
  value       = data.azurerm_virtual_machine_scale_set.to_stop_2.instances[0].power_state
}

output "do_not_stop_1_power_state" {
  description = "Scale Set 1 Do Not Stop Power State"
  value       = data.azurerm_virtual_machine_scale_set.do_not_stop_1.instances[0].power_state
}

output "do_not_stop_2_power_state" {
  description = "Scale Set 2 Do Not Stop Power State"
  value       = data.azurerm_virtual_machine_scale_set.do_not_stop_2.instances[0].power_state
}
