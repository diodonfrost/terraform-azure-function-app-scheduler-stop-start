output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.this.name
}

output "external_service_plan_id" {
  description = "The ID of the external App Service Plan"
  value       = azurerm_service_plan.external.id
}

output "external_service_plan_name" {
  description = "The name of the external App Service Plan"
  value       = azurerm_service_plan.external.name
}

output "function_app_id" {
  description = "The ID of the function app"
  value       = module.external_service_plan.function_app_id
}

output "function_app_name" {
  description = "The name of the function app"
  value       = module.external_service_plan.function_app_name
}

output "service_plan_id_from_module" {
  description = "The service plan ID returned by the module (should match external_service_plan_id)"
  value       = module.external_service_plan.service_plan_id
}

output "service_plan_name_from_module" {
  description = "The service plan name returned by the module (should match external_service_plan_name)"
  value       = module.external_service_plan.service_plan_name
}

output "function_app_master_key" {
  description = "The master key of the function app"
  value       = module.external_service_plan.function_app_master_key
  sensitive   = true
}

output "default_hostname" {
  description = "The default hostname of the function app"
  value       = module.external_service_plan.default_hostname
}
