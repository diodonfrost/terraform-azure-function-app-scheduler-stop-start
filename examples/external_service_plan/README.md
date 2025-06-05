# External Service Plan Example

This example demonstrates how to use the Terraform Azure Function App Scheduler module with an external App Service Plan instead of creating a new one.

## Overview

This example creates:
- A resource group
- An external App Service Plan
- A Function App using the external App Service Plan through the scheduler module

The key difference from other examples is the use of the `existing_service_plan` variable to specify an external App Service Plan that is managed outside of the module.

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Review and customize the variables in `variables.tf` or create a `terraform.tfvars` file:
```hcl
resource_group_name         = "rg-my-scheduler-test"
location                   = "West Europe"
function_app_name          = "func-my-scheduler-test"
external_service_plan_name = "asp-my-external-plan"
service_plan_sku_name      = "Y1"
```

3. Plan the deployment:
```bash
terraform plan
```

4. Apply the configuration:
```bash
terraform apply
```

5. Clean up when done:
```bash
terraform destroy
```

## Testing

Run the Terraform test to validate the configuration:
```bash
terraform test
```

The test validates that:
- The Function App is correctly using the external App Service Plan
- All resources are created with the expected names
- The module outputs match the external resources

## Key Configuration

The important part of this example is how the external service plan is referenced in the module:

```hcl
module "scheduler" {
  source = "../.."

  # ... other variables ...

  # Use the external service plan created above
  existing_service_plan = {
    name                = azurerm_service_plan.external.name
    resource_group_name = azurerm_service_plan.external.resource_group_name
  }

  # ... other variables ...
}
```

## Outputs

This example provides several outputs to verify the configuration:
- `external_service_plan_id`: The ID of the external App Service Plan
- `service_plan_id_from_module`: The service plan ID returned by the module (should match the external plan)
- `function_app_id`: The ID of the created Function App
- `function_app_name`: The name of the Function App
- `default_hostname`: The default hostname of the Function App

## Benefits

Using an external App Service Plan allows you to:
- Share a single App Service Plan across multiple Function Apps
- Manage the App Service Plan lifecycle independently from the Function Apps
- Optimize costs by consolidating multiple Function Apps on the same plan
- Apply different Terraform management strategies for infrastructure vs applications
