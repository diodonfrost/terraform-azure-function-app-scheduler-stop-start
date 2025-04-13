output "aks_1_to_stop_state" {
  description = "The power state of the first AKS server that should be stopped"
  value       = data.local_file.aks_1_to_stop.content
}

output "aks_2_to_stop_state" {
  description = "The power state of the second AKS server that should be stopped"
  value       = data.local_file.aks_2_to_stop.content
}

output "aks_1_do_not_stop_state" {
  description = "The power state of the first AKS server that should not be stopped"
  value       = data.local_file.aks_1_do_not_stop.content
}

output "aks_2_do_not_stop_state" {
  description = "The power state of the second AKS server that should not be stopped"
  value       = data.local_file.aks_2_do_not_stop.content
}
