locals {
  storage_account_name       = var.create_storage_account ? var.storage_account_name : data.azurerm_storage_account.this[0].name
  storage_account_access_key = var.create_storage_account ? azurerm_storage_account.this[0].primary_access_key : data.azurerm_storage_account.this[0].primary_access_key
  storage_account_id         = var.create_storage_account ? azurerm_storage_account.this[0].id : data.azurerm_storage_account.this[0].id
}
