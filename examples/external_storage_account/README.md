# External Storage Account Example

This example demonstrates how to use the Azure Function App Scheduler module with an external storage account instead of creating a new one.

## Overview

This example shows two different approaches for using an external storage account:

1. **With explicit access key**: Providing the storage account access key directly
2. **With automatic key retrieval**: Letting the module automatically retrieve the access key

## Resources Created

- External storage account (`azurerm_storage_account.external`)
- Virtual machines with scheduler tags
- Two function apps using the external storage account
- Required networking components

## Usage

### Method 1: Explicit Access Key

```hcl
module "function_app_with_external_storage" {
  source = "path/to/module"

  # Standard configuration
  resource_group_name = "my-resource-group"
  location           = "swedencentral"
  function_app_name  = "my-function-app"
  
  # External storage account configuration
  existing_storage_account = {
    name                = "myexternalstorage"
    resource_group_name = "external-storage-rg"
    access_key          = "your-storage-account-access-key"
  }
  
  # Other configuration...
}
```

### Method 2: Automatic Key Retrieval

```hcl
module "function_app_with_external_storage_auto" {
  source = "path/to/module"

  # Standard configuration
  resource_group_name = "my-resource-group"
  location           = "swedencentral"
  function_app_name  = "my-function-app"
  
  # External storage account configuration (without access key)
  existing_storage_account = {
    name                = "myexternalstorage"
    resource_group_name = "external-storage-rg"
    # access_key omitted - will be retrieved automatically
  }
  
  # Other configuration...
}
```

## Key Features

- **Flexible storage configuration**: Use either an existing storage account or let the module create one
- **Automatic key retrieval**: The module can automatically retrieve storage account keys when not provided
- **Resource sharing**: Multiple function apps can share the same external storage account
- **Security**: Access keys can be managed externally or retrieved automatically with proper permissions

## Requirements

When using an external storage account, ensure that:

1. The storage account exists and is accessible
2. The Terraform execution context has permissions to read the storage account
3. If providing an explicit access key, ensure it's valid and has sufficient permissions
4. The storage account is in a location that supports the function app's requirements

## Running the Example

```bash
terraform init
terraform plan
terraform apply
```

## Cleanup

```bash
terraform destroy
```

## Security Considerations

- Store access keys securely using Azure Key Vault or environment variables
- Use automatic key retrieval when possible to avoid hardcoding sensitive values
- Ensure proper IAM permissions for accessing external storage accounts
- Consider using managed identities for enhanced security