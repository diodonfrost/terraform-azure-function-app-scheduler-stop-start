resource "null_resource" "check_vms_running_before_stop" {
  provisioner "local-exec" {
    command = <<-EOT
      python3 ${path.module}/check_vm_state.py running \
        ${var.resource_group_name} \
        ${var.vm_1_to_stop_name} \
        ${var.vm_2_to_stop_name}
    EOT
  }
}

resource "null_resource" "trigger_stop_function" {

  provisioner "local-exec" {
    command = <<-EOT
      curl -d "{}" -X POST https://${var.stop_function_app_url}/admin/functions/scheduler \
        -H "x-functions-key:${var.stop_function_app_master_key}" \
        -H "Content-Type:application/json" -v
    EOT
  }

  depends_on = [null_resource.check_vms_running_before_stop]
}

# Wait a bit to ensure function execution is complete
resource "null_resource" "wait_after_function_execution" {
  provisioner "local-exec" {
    command = "sleep 30"
  }

  depends_on = [null_resource.trigger_stop_function]
}

# Verify VMs are still running (not stopped due to date exclusion)
resource "null_resource" "check_vms_still_running_after_exclusion" {
  provisioner "local-exec" {
    command = <<-EOT
      python3 ${path.module}/check_vm_state.py running \
        ${var.resource_group_name} \
        ${var.vm_1_to_stop_name} \
        ${var.vm_2_to_stop_name}
    EOT
  }

  depends_on = [null_resource.wait_after_function_execution]
}

data "azurerm_virtual_machine" "vm_1_to_stop" {
  name                = var.vm_1_to_stop_name
  resource_group_name = var.resource_group_name

  depends_on = [null_resource.check_vms_still_running_after_exclusion]
}

data "azurerm_virtual_machine" "vm_2_to_stop" {
  name                = var.vm_2_to_stop_name
  resource_group_name = var.resource_group_name

  depends_on = [null_resource.check_vms_still_running_after_exclusion]
}
