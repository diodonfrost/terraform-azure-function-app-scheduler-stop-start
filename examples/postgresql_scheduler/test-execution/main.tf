resource "time_sleep" "before_stop_wait_30_seconds" {
  create_duration = "30s"
}

resource "null_resource" "stop_pg" {

  provisioner "local-exec" {
    command = <<-EOT
      curl -d "{}" -X POST https://${var.stop_function_app_url}/admin/functions/scheduler \
        -H "x-functions-key:${var.stop_function_app_master_key}" \
        -H "Content-Type:application/json" -v
    EOT
  }

  depends_on = [time_sleep.before_stop_wait_30_seconds]
}

resource "time_sleep" "after_stop_wait_30_seconds" {
  create_duration = "30s"

  depends_on = [null_resource.stop_pg]
}

resource "null_resource" "pg_1_to_stop" {

  provisioner "local-exec" {
    command = <<-EOT
      az postgres flexible-server show \
        --resource-group ${var.resource_group_name} \
        --name ${var.pg_1_to_stop_name} \
        --query "state" \
        --output tsv > ${path.module}/pg_1_to_stop.state
    EOT
  }

  depends_on = [time_sleep.after_stop_wait_30_seconds]
}

data "local_file" "pg_1_to_stop" {
  filename = "${path.module}/pg_1_to_stop.state"

  depends_on = [null_resource.pg_1_to_stop]
}

resource "null_resource" "pg_2_to_stop" {

  provisioner "local-exec" {
    command = <<-EOT
      az postgres flexible-server show \
        --resource-group ${var.resource_group_name} \
        --name ${var.pg_2_to_stop_name} \
        --query "state" \
        --output tsv > ${path.module}/pg_2_to_stop.state
    EOT
  }

  depends_on = [time_sleep.after_stop_wait_30_seconds]
}

data "local_file" "pg_2_to_stop" {
  filename = "${path.module}/pg_2_to_stop.state"

  depends_on = [null_resource.pg_2_to_stop]
}

resource "null_resource" "pg_1_do_not_stop" {

  provisioner "local-exec" {
    command = <<-EOT
      az postgres flexible-server show \
        --resource-group ${var.resource_group_name} \
        --name ${var.pg_1_do_not_stop_name} \
        --query "state" \
        --output tsv > ${path.module}/pg_1_do_not_stop.state
    EOT
  }

  depends_on = [time_sleep.after_stop_wait_30_seconds]
}

data "local_file" "pg_1_do_not_stop" {
  filename = "${path.module}/pg_1_do_not_stop.state"

  depends_on = [null_resource.pg_1_do_not_stop]
}

resource "null_resource" "pg_2_do_not_stop" {

  provisioner "local-exec" {
    command = <<-EOT
      az postgres flexible-server show \
        --resource-group ${var.resource_group_name} \
        --name ${var.pg_2_do_not_stop_name} \
        --query "state" \
        --output tsv > ${path.module}/pg_2_do_not_stop.state
    EOT
  }

  depends_on = [time_sleep.after_stop_wait_30_seconds]
}

data "local_file" "pg_2_do_not_stop" {
  filename = "${path.module}/pg_2_do_not_stop.state"

  depends_on = [null_resource.pg_2_do_not_stop]
}
