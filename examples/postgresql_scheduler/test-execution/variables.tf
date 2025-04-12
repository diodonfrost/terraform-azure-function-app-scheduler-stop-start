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

variable "pg_1_to_stop_name" {
  description = "The name of the first PostgreSQL server to stop"
  type        = string
}

variable "pg_2_to_stop_name" {
  description = "The name of the second PostgreSQL server to stop"
  type        = string
}

variable "pg_1_do_not_stop_name" {
  description = "The name of the first PostgreSQL server to not stop"
  type        = string
}

variable "pg_2_do_not_stop_name" {
  description = "The name of the second PostgreSQL server to not stop"
  type        = string
}
