variable "resource_group_name" {
  description = "Name of the resource group containing the VMs"
  type        = string
}

variable "vm_1_to_stop_name" {
  description = "Name of the first VM that should not be stopped due to date exclusion"
  type        = string
}

variable "vm_2_to_stop_name" {
  description = "Name of the second VM that should not be stopped due to date exclusion"
  type        = string
}

variable "stop_function_app_url" {
  description = "URL of the stop function app"
  type        = string
}

variable "stop_function_app_master_key" {
  description = "Master key for the stop function app"
  type        = string
  sensitive   = true
}
