variable "function_app_name" {
  type        = string
  description = "The name of the Azure Function App"
}

variable "service_plan_name" {
  type        = string
  description = "The name of the Azure service plan. If not provided, a name will be automatically generated."
  default     = null
}

variable "service_plan_sku_name" {
  type        = string
  description = "The SKU name for the Azure service plan"
  default     = "Y1"
}

variable "storage_account_name" {
  type        = string
  description = "The backend storage account name which will be used by this Function App. If not provided, a name will be automatically generated with a random suffix."
  default     = null
}

variable "existing_storage_account" {
  description = "Configuration for using an existing external storage account instead of creating a new one."
  type = object({
    name                = string
    resource_group_name = string
  })
  default = null
}

variable "existing_service_plan" {
  description = "Configuration for using an existing external service plan instead of creating a new one."
  type = object({
    name                = string
    resource_group_name = string
  })
  default = null
}

variable "application_insights" {
  description = "Application Insights parameters."
  type = object({
    enabled                    = optional(bool, false)
    log_analytics_workspace_id = optional(string, null)
  })
  default = {}
}

variable "resource_group_name" {
  type        = string
  description = "The name of the Resource Group where the Linux Function App should exist"
}

variable "location" {
  type        = string
  description = "The location of the Azure resources"
}

variable "scheduler_ncrontab_expression" {
  description = "The NCRONTAB expression which defines the schedule of the Azure function app (UTC Time Zone)"
  type        = string
  default     = "0 22 ? * MON-FRI *"
}

variable "scheduler_excluded_dates" {
  description = "List of specific dates to exclude from scheduling in MM-DD format (e.g., ['12-25', '01-01'])"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for date in var.scheduler_excluded_dates : can(regex("^(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$", date))
    ])
    error_message = "Excluded dates must be in MM-DD format (e.g., '12-25', '01-01')."
  }
}

variable "scheduler_action" {
  description = "The action to take for the scheduler, accepted values: 'stop' or 'start'"
  type        = string

  validation {
    condition     = var.scheduler_action == "stop" || var.scheduler_action == "start"
    error_message = "The scheduler_action variable must be either 'stop' or 'start'"
  }
}

variable "subscription_ids" {
  description = "List of Azure subscription IDs to manage resources in. If empty, uses the current subscription only."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for id in var.subscription_ids : can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", id))
    ])
    error_message = "All subscription IDs must be valid UUIDs."
  }
}

variable "scheduler_tag" {
  description = "Set the tag to use for identify Azure resources to stop or start"
  type        = map(string)

  default = {
    "tostop" = "true"
  }
}

variable "virtual_machine_schedule" {
  description = "Enable Azure Virtual Machine scheduler."
  type        = bool
  default     = false
}

variable "scale_set_schedule" {
  description = "Enable Azure Scale Set scheduler."
  type        = bool
  default     = false
}

variable "postgresql_schedule" {
  description = "Enable Azure Postgresql scheduler."
  type        = bool
  default     = false
}

variable "mysql_schedule" {
  description = "Enable Azure Mysql scheduler."
  type        = bool
  default     = false
}

variable "aks_schedule" {
  description = "Enable Azure AKS scheduler."
  type        = bool
  default     = false
}

variable "container_group_schedule" {
  description = "Enable Azure Container group scheduler."
  type        = bool
  default     = false
}

variable "custom_app_settings" {
  description = "Additional app settings/environment variables to be added to the function app"
  type        = map(string)
  default     = {}
}

variable "diagnostic_settings" {
  description = "Diagnostic settings for the function app"
  type = object({
    name                           = string
    storage_account_id             = optional(string, null)
    log_analytics_id               = optional(string, null)
    log_analytics_destination_type = optional(string, null)
    eventhub_name                  = optional(string, null)
    eventhub_authorization_rule_id = optional(string, null)
    log_categories                 = optional(list(string), ["FunctionAppLogs"])
    enable_metrics                 = optional(bool, false)
  })
  default = null
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to the Azure resources"
  default     = {}
}
