data "azurerm_subscription" "current" {}

resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

resource "azurerm_service_plan" "this" {
  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = var.service_plan_sku_name

  tags = var.tags
}

data "archive_file" "this" {
  type        = "zip"
  source_dir  = "${path.module}/functions/"
  output_path = "${path.module}/functions.zip"
}

resource "terraform_data" "replacement" {
  input = data.archive_file.this.output_sha
}

resource "azurerm_linux_function_app" "this" {
  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_account_name        = azurerm_storage_account.this.name
  storage_account_access_key  = azurerm_storage_account.this.primary_access_key
  service_plan_id             = azurerm_service_plan.this.id
  functions_extension_version = "~4"
  zip_deploy_file             = data.archive_file.this.output_path

  site_config {
    application_insights_connection_string = var.application_insights.enabled ? azurerm_application_insights.this[0].connection_string : null
    application_insights_key               = var.application_insights.enabled ? azurerm_application_insights.this[0].instrumentation_key : null
    application_stack {
      python_version = "3.11"
    }
    cors {
      allowed_origins = ["https://portal.azure.com"]
    }
  }

  app_settings = {
    SCM_DO_BUILD_DURING_DEPLOYMENT = true
    ENABLE_ORYX_BUILD              = true
    FUNCTIONS_WORKER_RUNTIME       = "python"
    CURRENT_SUBSCRIPTION_ID        = data.azurerm_subscription.current.subscription_id
    ScheduleAppSetting             = var.scheduler_ncrontab_expression
    SCHEDULER_ACTION               = var.scheduler_action
    SCHEDULER_TAG                  = jsonencode(var.scheduler_tag)
    VIRTUAL_MACHINE_SCHEDULE       = tostring(var.virtual_machine_schedule)
    SCALE_SET_SCHEDULE             = tostring(var.scale_set_schedule)
    POSTGRESQL_SCHEDULE            = tostring(var.postgresql_schedule)
    MYSQL_SCHEDULE                 = tostring(var.mysql_schedule)
    AKS_SCHEDULE                   = tostring(var.aks_schedule)
    CONTAINER_GROUP_SCHEDULE       = tostring(var.container_group_schedule)
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

  lifecycle {
    replace_triggered_by = [
      terraform_data.replacement
    ]
  }
}

resource "azurerm_application_insights" "this" {
  count = var.application_insights.enabled ? 1 : 0

  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  workspace_id        = var.application_insights.log_analytics_workspace_id
  application_type    = "other"

  tags = var.tags

  lifecycle {
    replace_triggered_by = [
      terraform_data.replacement
    ]
  }
}
