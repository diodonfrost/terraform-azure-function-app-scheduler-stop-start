output "external_storage_account_name" {
  description = "The name of the external storage account created for this example"
  value       = azurerm_storage_account.external.name
}

output "external_storage_account_id" {
  description = "The ID of the external storage account"
  value       = azurerm_storage_account.external.id
}

output "stop_function_app_name" {
  description = "The name of the stop function app using external storage"
  value       = module.stop_virtual_machines_with_external_storage.function_app_name
}

output "start_function_app_name" {
  description = "The name of the start function app using external storage with auto key retrieval"
  value       = module.start_virtual_machines_with_external_storage_auto_key.function_app_name
}

output "stop_function_app_url" {
  description = "The URL of the stop function app"
  value       = module.stop_virtual_machines_with_external_storage.default_hostname
}

output "start_function_app_url" {
  description = "The URL of the start function app"
  value       = module.start_virtual_machines_with_external_storage_auto_key.default_hostname
}

output "resource_group_name" {
  description = "The name of the resource group containing all resources"
  value       = azurerm_resource_group.test.name
}
