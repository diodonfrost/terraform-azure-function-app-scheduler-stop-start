output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_linux_function_app.this.resource_group_name
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = try(azurerm_storage_account.this[0].id, null)
}

output "storage_account_name" {
  description = "The name of the storage account (generated automatically if not provided in variables)"
  value       = try(azurerm_storage_account.this[0].name, null)
}

output "service_plan_id" {
  description = "The ID of the service plan"
  value       = local.service_plan_id
}

output "service_plan_name" {
  description = "The name of the service plan"
  value       = var.existing_service_plan != null ? data.azurerm_service_plan.external[0].name : azurerm_service_plan.this[0].name
}

output "function_app_id" {
  description = "The ID of the function app"
  value       = azurerm_linux_function_app.this.id
}

output "function_app_name" {
  description = "The name of the function app"
  value       = azurerm_linux_function_app.this.name
}

output "function_app_master_key" {
  description = "The master key of the function app"
  value       = data.azurerm_function_app_host_keys.this.primary_key
  sensitive   = true
}

output "default_hostname" {
  description = "The default hostname of the function app"
  value       = azurerm_linux_function_app.this.default_hostname
}

output "application_insights_id" {
  description = "ID of the associated Application Insights"
  value       = try(azurerm_application_insights.this[0].id, null)
}

output "application_insights_name" {
  description = "Name of the associated Application Insights"
  value       = try(azurerm_application_insights.this[0].name, null)
}

output "diagnostic_settings_name" {
  description = "The name of the diagnostic settings"
  value       = try(azurerm_monitor_diagnostic_setting.this[0].name, null)
}

output "diagnostic_settings_target_resource_id" {
  description = "The target resource ID of the diagnostic settings"
  value       = try(azurerm_monitor_diagnostic_setting.this[0].target_resource_id, null)
}

output "app_settings" {
  description = "The app settings of the function app"
  value       = azurerm_linux_function_app.this.app_settings
  sensitive   = true
}
