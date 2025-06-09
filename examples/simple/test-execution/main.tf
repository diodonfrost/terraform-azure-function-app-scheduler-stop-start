resource "null_resource" "check_vms_running_before_stop" {
  provisioner "local-exec" {
    command = <<-EOT
      python3 ${path.module}/check_vm_state.py running \
        ${var.resource_group_name} \
        ${var.vm_1_to_stop_name} \
        ${var.vm_2_to_stop_name} \
        ${var.vm_3_to_stop_name}
    EOT
  }
}

resource "null_resource" "stop_vm" {

  provisioner "local-exec" {
    command = <<-EOT
      curl -d "{}" -X POST https://${var.stop_function_app_url}/admin/functions/scheduler \
        -H "x-functions-key:${var.stop_function_app_master_key}" \
        -H "Content-Type:application/json" -v
    EOT
  }

  depends_on = [null_resource.check_vms_running_before_stop]
}

resource "null_resource" "check_vms_stopped_after_stop" {
  provisioner "local-exec" {
    command = <<-EOT
      python3 ${path.module}/check_vm_state.py deallocated \
        ${var.resource_group_name} \
        ${var.vm_1_to_stop_name} \
        ${var.vm_2_to_stop_name} \
        ${var.vm_3_to_stop_name}
    EOT
  }

  depends_on = [null_resource.stop_vm]
}

data "azurerm_virtual_machine" "vm_1_to_stop" {
  name                = var.vm_1_to_stop_name
  resource_group_name = var.resource_group_name

  depends_on = [null_resource.check_vms_stopped_after_stop]
}

data "azurerm_virtual_machine" "vm_2_to_stop" {
  name                = var.vm_2_to_stop_name
  resource_group_name = var.resource_group_name

  depends_on = [null_resource.check_vms_stopped_after_stop]
}

data "azurerm_virtual_machine" "vm_3_to_stop" {
  name                = var.vm_3_to_stop_name
  resource_group_name = var.resource_group_name

  depends_on = [null_resource.check_vms_stopped_after_stop]
}

data "azurerm_virtual_machine" "vm_1_do_not_stop" {
  name                = var.vm_1_do_not_stop_name
  resource_group_name = var.resource_group_name

  depends_on = [null_resource.check_vms_stopped_after_stop]
}

data "azurerm_virtual_machine" "vm_2_do_not_stop" {
  name                = var.vm_2_do_not_stop_name
  resource_group_name = var.resource_group_name

  depends_on = [null_resource.check_vms_stopped_after_stop]
}
