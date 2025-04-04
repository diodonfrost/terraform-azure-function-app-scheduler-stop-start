# terraform-azure-function-scheduler-stop-start

Terraform module which creates app function scheduler for stop and start resources on Azure

## Usage

```hcl
module "stop_virtual_machines" {
  source = "diodonfrost/function-app-scheduler-stop-start/azure"

  resource_group_name           = "my-rg"
  location                      = "westeurope"
  function_app_name             = "my-stop-az-function-prefix"
  service_plan_name             = "my-stop-service-plan"
  storage_account_name          = "mystorageaccount1"
  scheduler_action              = "stop"
  scheduler_ncrontab_expression = "0 22 * * *"
  virtual_machine_schedule      = "true"
  postgresql_schedule           = "true"
  scheduler_tag = {
    tostop = "true"
  }
}

module "start_virtual_machines" {
  source = "diodonfrost/function-app-scheduler-stop-start/azure"

  resource_group_name           = "my-rg"
  location                      = "westeurope"
  function_app_name             = "my-az-start-function-prefix"
  service_plan_name             = "my-start-service-plan2"
  storage_account_name          = "mystartstorageaccount"
  scheduler_action              = "start"
  scheduler_ncrontab_expression = "0 7 * * *"
  virtual_machine_schedule      = "true"
  postgresql_schedule           = "true"
  scheduler_tag = {
    tostop = "true"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | 2.3.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.0.0, < 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.3.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.25.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_application_insights.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_insights) | resource |
| [azurerm_linux_function_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_function_app) | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_service_plan.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan) | resource |
| [azurerm_storage_account.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [terraform_data.replacement](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [archive_file.this](https://registry.terraform.io/providers/hashicorp/archive/2.3.0/docs/data-sources/file) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_schedule"></a> [aks\_schedule](#input\_aks\_schedule) | Enable Azure AKS scheduler. | `bool` | `false` | no |
| <a name="input_container_group_schedule"></a> [container\_group\_schedule](#input\_container\_group\_schedule) | Enable Azure Container group scheduler. | `bool` | `false` | no |
| <a name="input_function_app_name"></a> [function\_app\_name](#input\_function\_app\_name) | The name of the Azure Function App | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location of the Azure resources | `string` | n/a | yes |
| <a name="input_mysql_schedule"></a> [mysql\_schedule](#input\_mysql\_schedule) | Enable Azure Mysql scheduler. | `bool` | `false` | no |
| <a name="input_postgresql_schedule"></a> [postgresql\_schedule](#input\_postgresql\_schedule) | Enable Azure Postgresql scheduler. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the Resource Group where the Linux Function App should exist | `string` | n/a | yes |
| <a name="input_scale_set_schedule"></a> [scale\_set\_schedule](#input\_scale\_set\_schedule) | Enable Azure Scale Set scheduler. | `bool` | `false` | no |
| <a name="input_scheduler_action"></a> [scheduler\_action](#input\_scheduler\_action) | The action to take for the scheduler, accepted values: 'stop' or 'start' | `string` | n/a | yes |
| <a name="input_scheduler_ncrontab_expression"></a> [scheduler\_ncrontab\_expression](#input\_scheduler\_ncrontab\_expression) | The NCRONTAB expression which defines the schedule of the Azure function app (UTC Time Zone) | `string` | `"0 22 ? * MON-FRI *"` | no |
| <a name="input_scheduler_tag"></a> [scheduler\_tag](#input\_scheduler\_tag) | Set the tag to use for identify Azure resources to stop or start | `map(string)` | <pre>{<br/>  "tostop": "true"<br/>}</pre> | no |
| <a name="input_service_plan_name"></a> [service\_plan\_name](#input\_service\_plan\_name) | The name of the Azure service plan | `string` | n/a | yes |
| <a name="input_service_plan_sku_name"></a> [service\_plan\_sku\_name](#input\_service\_plan\_sku\_name) | The SKU name for the Azure service plan | `string` | `"Y1"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The backend storage account name which will be used by this Function App | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags to apply to the Azure resources | `map(string)` | `{}` | no |
| <a name="input_virtual_machine_schedule"></a> [virtual\_machine\_schedule](#input\_virtual\_machine\_schedule) | Enable Azure Virtual Machine scheduler. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_insights_id"></a> [application\_insights\_id](#output\_application\_insights\_id) | ID of the associated Application Insights |
| <a name="output_application_insights_name"></a> [application\_insights\_name](#output\_application\_insights\_name) | Name of the associated Application Insights |
| <a name="output_function_app_id"></a> [function\_app\_id](#output\_function\_app\_id) | The ID of the function app |
| <a name="output_function_app_name"></a> [function\_app\_name](#output\_function\_app\_name) | The name of the function app |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group |
| <a name="output_service_plan_id"></a> [service\_plan\_id](#output\_service\_plan\_id) | The ID of the service plan |
| <a name="output_service_plan_name"></a> [service\_plan\_name](#output\_service\_plan\_name) | The name of the service plan |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the storage account |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the storage account |
<!-- END_TF_DOCS -->

## Tests

Some of these tests create real resources. That means they cost money to run, especially if you don't clean up after yourself. Please be considerate of the resources you create and take extra care to clean everything up when you're done!

### End-to-end tests

This module has been packaged with [Terratest](https://github.com/gruntwork-io/terratest) to tests this Terraform module.

Install Terratest with depedencies:

```shell
# Prerequisite: install Go
cd tests/end-to-end/ && go get ./...

# Test simple scenario
go test -timeout 30m -v simple_test.go
```

## Authors

Modules managed by diodonfrost.

## Licence

Apache Software License 2.0.
