variable "function_app_name_prefix" {
  type        = string
  description = "The prefix of the Azure Function App name"
}

variable "service_plan_name" {
  type        = string
  description = "The name of the Azure service plan"
}

variable "storage_account_name" {
  type        = string
  description = "The backend storage account name which will be used by this Function App"
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
  description = "The NCRONTAB expression which defines the schedule of the Azure function app"
  type        = string
  default     = "0 22 ? * MON-FRI *"
}

variable "scheduler_action" {
  description = "The action to take for the scheduler, accepted values: 'stop' or 'start'"
  type        = string

  validation {
    condition     = var.scheduler_action == "stop" || var.scheduler_action == "start"
    error_message = "The scheduler_action variable must be either 'stop' or 'start'"
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

variable "tags" {
  type        = map(string)
  description = "The tags to apply to the Azure resources"
  default     = {}
}
