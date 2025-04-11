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
