run "create_test_infrastructure" {
  command = apply

  assert {
    condition     = module.to_stop.resource_group_name == azurerm_resource_group.test.name
    error_message = "Invalid resource group name"
  }

  assert {
    condition     = module.to_stop.resource_group_name == azurerm_resource_group.test.name
    error_message = "Invalid resource group name"
  }

  assert {
    condition     = module.to_stop.function_app_name == "fpn-to-stop-${random_pet.suffix.id}"
    error_message = "Invalid function app name"
  }

  assert {
    condition     = module.to_start.service_plan_name == "spn-to-start-${random_pet.suffix.id}"
    error_message = "Invalid service plan name"
  }

  assert {
    condition     = module.to_start.function_app_name == "fpn-to-start-${random_pet.suffix.id}"
    error_message = "Invalid function app name"
  }

  assert {
    condition     = module.to_stop.storage_account_name == "tostop${random_id.suffix.hex}"
    error_message = "Invalid storage account name"
  }

  assert {
    condition     = module.to_start.storage_account_name == "tostart${random_id.suffix.hex}"
    error_message = "Invalid storage account name"
  }
}
