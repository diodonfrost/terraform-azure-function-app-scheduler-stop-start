provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      skip_shutdown_and_force_delete = true
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      skip_shutdown_and_force_delete = true
    }
  }
  alias           = "subscription_1"
  subscription_id = var.subscription_1_id
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    virtual_machine {
      skip_shutdown_and_force_delete = true
    }
  }
  alias           = "subscription_2"
  subscription_id = var.subscription_2_id
}
