terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0, < 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0, < 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.0.0, < 3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.13.0"
    }
  }
}
