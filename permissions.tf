resource "azurerm_role_definition" "this" {
  for_each    = toset(local.subscription_ids)
  name        = "${azurerm_linux_function_app.this.name}-${substr(each.value, 0, 8)}"
  scope       = "/subscriptions/${each.value}"
  description = "Custom role to stop and start Azure resources"

  permissions {
    actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/write",
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Compute/virtualMachines/start/action",
      "Microsoft.Compute/virtualMachines/powerOff/action",
      "Microsoft.Compute/virtualMachines/deallocate/action",
      "Microsoft.Compute/virtualMachineScaleSets/read",
      "Microsoft.Compute/virtualMachineScaleSets/setOrchestrationServiceState/action",
      "Microsoft.Compute/virtualMachineScaleSets/start/action",
      "Microsoft.Compute/virtualMachineScaleSets/powerOff/action",
      "Microsoft.Compute/virtualMachineScaleSets/deallocate/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/read",
      "Microsoft.DBforPostgreSQL/flexibleServers/start/action",
      "Microsoft.DBforPostgreSQL/flexibleServers/stop/action",
      "Microsoft.DBforMySQL/flexibleServers/read",
      "Microsoft.DBforMySQL/flexibleServers/start/action",
      "Microsoft.DBforMySQL/flexibleServers/stop/action",
      "Microsoft.ContainerService/managedClusters/read",
      "Microsoft.ContainerService/managedClusters/start/action",
      "Microsoft.ContainerService/managedClusters/stop/action",
      "Microsoft.ContainerInstance/containerGroups/read",
      "Microsoft.ContainerInstance/containerGroups/start/action",
      "Microsoft.ContainerInstance/containerGroups/stop/action",
    ]
    not_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${each.value}"
  ]
}

resource "azurerm_role_assignment" "this" {
  for_each           = toset(local.subscription_ids)
  scope              = "/subscriptions/${each.value}"
  role_definition_id = azurerm_role_definition.this[each.value].role_definition_resource_id
  principal_id       = azurerm_linux_function_app.this.identity[0].principal_id
}
