resource "random_id" "storage_suffix" {
  count = var.storage_account_name == null && var.existing_storage_account == null ? 1 : 0

  byte_length = 4
}

resource "azurerm_storage_account" "this" {
  count = var.existing_storage_account == null ? 1 : 0

  name                     = local.generated_storage_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

data "azurerm_storage_account" "external" {
  count = var.existing_storage_account != null ? 1 : 0

  name                = var.existing_storage_account.name
  resource_group_name = var.existing_storage_account.resource_group_name
}
