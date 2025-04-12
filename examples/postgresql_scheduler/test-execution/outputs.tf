output "pg_1_to_stop_state" {
  description = "The power state of the first PostgreSQL server that should be stopped"
  value       = data.local_file.pg_1_to_stop.content
}

output "pg_2_to_stop_state" {
  description = "The power state of the second PostgreSQL server that should be stopped"
  value       = data.local_file.pg_2_to_stop.content
}

output "pg_1_do_not_stop_state" {
  description = "The power state of the first PostgreSQL server that should not be stopped"
  value       = data.local_file.pg_1_do_not_stop.content
}

output "pg_2_do_not_stop_state" {
  description = "The power state of the second PostgreSQL server that should not be stopped"
  value       = data.local_file.pg_2_do_not_stop.content
}
