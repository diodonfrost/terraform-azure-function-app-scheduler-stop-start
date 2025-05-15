data "azurerm_storage_account" "this" {
  count = var.create_storage_account ? 0 : 1

  name                = var.storage_account_name
  resource_group_name = var.storage_account_resource_group_name
}

resource "azurerm_storage_account" "this" {
  count = var.create_storage_account ? 1 : 0

  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}
