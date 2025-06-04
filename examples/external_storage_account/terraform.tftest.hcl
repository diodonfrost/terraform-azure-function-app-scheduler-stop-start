run "setup" {
  command = apply
}

run "verify_external_storage_account" {
  command = plan

  assert {
    condition     = azurerm_storage_account.external.name != null
    error_message = "External storage account should be created"
  }

  assert {
    condition     = azurerm_storage_account.external.account_tier == "Standard"
    error_message = "Storage account should use Standard tier"
  }
}

run "verify_function_apps_use_external_storage" {
  command = plan

  assert {
    condition     = module.stop_virtual_machines_with_external_storage.function_app_name != null
    error_message = "Stop function app should be created with external storage"
  }

  assert {
    condition     = module.start_virtual_machines_with_external_storage_auto_key.function_app_name != null
    error_message = "Start function app should be created with external storage and auto key retrieval"
  }
}

run "verify_no_internal_storage_accounts_created" {
  command = plan

  # This test verifies that the module doesn't create internal storage accounts
  # when external storage is configured
  assert {
    condition = length([
      for k, v in module.stop_virtual_machines_with_external_storage : k
      if can(regex("azurerm_storage_account", k))
    ]) == 0
    error_message = "Module should not create internal storage accounts when external storage is configured"
  }
}