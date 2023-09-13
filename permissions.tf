resource "azurerm_role_definition" "this" {
  name        = azurerm_linux_function_app.this.name
  scope       = data.azurerm_subscription.current.id
  description = "Custom role to stop and start Azure resources"

  permissions {
    actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/write",
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/powerOff/action",
      "Microsoft.Compute/virtualMachines/deallocate/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/start/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/stop/action",
      "Microsoft.DBforMySQL/flexibleServers/read",
      "Microsoft.DBforMySQL/flexibleServers/start/action",
      "Microsoft.DBforMySQL/flexibleServers/stop/action",
    ]
    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.current.id
  ]
}

resource "azurerm_role_assignment" "this" {
  scope              = data.azurerm_subscription.current.id
  role_definition_id = azurerm_role_definition.this.role_definition_resource_id
  principal_id       = azurerm_linux_function_app.this.identity[0].principal_id
}
