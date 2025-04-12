output "mysql_1_to_stop_state" {
  description = "The power state of the first MySQL server that should be stopped"
  value       = data.local_file.mysql_1_to_stop.content
}

output "mysql_2_to_stop_state" {
  description = "The power state of the second MySQL server that should be stopped"
  value       = data.local_file.mysql_2_to_stop.content
}

output "mysql_1_do_not_stop_state" {
  description = "The power state of the first MySQL server that should not be stopped"
  value       = data.local_file.mysql_1_do_not_stop.content
}

output "mysql_2_do_not_stop_state" {
  description = "The power state of the second MySQL server that should not be stopped"
  value       = data.local_file.mysql_2_do_not_stop.content
}
