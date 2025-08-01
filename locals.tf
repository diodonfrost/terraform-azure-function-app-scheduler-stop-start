locals {
  # Generate a storage account name if not provided
  # Format: "funcsa" + random 8-character hex suffix = max 14 characters
  # This ensures we stay within Azure's 3-24 character limit and use only lowercase letters and numbers
  generated_storage_name = var.storage_account_name == null && var.existing_storage_account == null ? "funcsa${random_id.storage_suffix[0].hex}" : var.storage_account_name

  # Generate a service plan name if not provided and not using external service plan
  # Format: "asp-" + function app name + "-" + random 8-character hex suffix
  # This ensures a meaningful and unique name for the service plan
  generated_service_plan_name = var.service_plan_name == null && var.existing_service_plan == null ? "asp-${var.function_app_name}-${random_id.service_plan_suffix[0].hex}" : var.service_plan_name

  # Service plan configuration - use external if provided, otherwise use the created one
  service_plan_id = var.existing_service_plan != null ? data.azurerm_service_plan.external[0].id : azurerm_service_plan.this[0].id

  # Storage account configuration - use external if provided, otherwise use the created one
  storage_account_name       = var.existing_storage_account != null ? data.azurerm_storage_account.external[0].name : azurerm_storage_account.this[0].name
  storage_account_access_key = var.existing_storage_account != null ? data.azurerm_storage_account.external[0].primary_access_key : azurerm_storage_account.this[0].primary_access_key

  # Subscription configuration - use provided list or current subscription
  subscription_ids = length(var.subscription_ids) > 0 ? var.subscription_ids : [data.azurerm_subscription.current.subscription_id]
}
