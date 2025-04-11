resource "time_sleep" "before_stop_wait_30_seconds" {
  create_duration = "30s"
}

resource "null_resource" "stop_vm" {

  provisioner "local-exec" {
    command = <<-EOT
      curl -d "{}" -X POST https://${var.stop_function_app_url}/admin/functions/scheduler \
        -H "x-functions-key:${var.stop_function_app_master_key}" \
        -H "Content-Type:application/json" -v
    EOT
  }

  depends_on = [time_sleep.before_stop_wait_30_seconds]
}

resource "time_sleep" "after_stop_wait_60_seconds" {
  create_duration = "60s"

  depends_on = [null_resource.stop_vm]
}

data "azurerm_virtual_machine" "vm_1_to_stop" {
  name                = var.vm_1_to_stop_name
  resource_group_name = var.resource_group_name

  depends_on = [time_sleep.after_stop_wait_60_seconds]
}

data "azurerm_virtual_machine" "vm_2_to_stop" {
  name                = var.vm_2_to_stop_name
  resource_group_name = var.resource_group_name

  depends_on = [time_sleep.after_stop_wait_60_seconds]
}

data "azurerm_virtual_machine" "vm_3_to_stop" {
  name                = var.vm_3_to_stop_name
  resource_group_name = var.resource_group_name

  depends_on = [time_sleep.after_stop_wait_60_seconds]
}

data "azurerm_virtual_machine" "vm_1_do_not_stop" {
  name                = var.vm_1_do_not_stop_name
  resource_group_name = var.resource_group_name

  depends_on = [time_sleep.after_stop_wait_60_seconds]
}

data "azurerm_virtual_machine" "vm_2_do_not_stop" {
  name                = var.vm_2_do_not_stop_name
  resource_group_name = var.resource_group_name

  depends_on = [time_sleep.after_stop_wait_60_seconds]
}
