variable "resource_group_name" {
  description = "The name of the resource group where resources are deployed"
  type        = string
}

variable "stop_function_app_url" {
  description = "The URL of the function app to execute"
  type        = string
}

variable "stop_function_app_master_key" {
  description = "The master key of the function app to execute"
  type        = string
}

variable "aks_1_to_stop_name" {
  description = "The name of the first AKS server to stop"
  type        = string
}

variable "aks_2_to_stop_name" {
  description = "The name of the second AKS server to stop"
  type        = string
}

variable "aks_1_do_not_stop_name" {
  description = "The name of the first AKS server to not stop"
  type        = string
}

variable "aks_2_do_not_stop_name" {
  description = "The name of the second AKS server to not stop"
  type        = string
}
