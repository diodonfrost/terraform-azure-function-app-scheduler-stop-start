terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0, < 4.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.3.0"
    }
  }
}

provider "azurerm" {
  features {}
  alias = "diagnostic_setting_subscription"
  subscription_id = try(
    coalesce(
      var.diagnostic_settings.event_hub_subscription_id,
      var.diagnostic_settings.log_analytics_subscription_id,
      var.diagnostic_settings.storage_account_subscription_id
    ),
    data.azurerm_subscription.current.subscription_id
  )
}
