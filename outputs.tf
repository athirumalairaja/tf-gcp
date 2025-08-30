output "controller_external_ips" {
  description = "External IP addresses of controller nodes"
  value = {
    for i, instance in google_compute_instance.controller :
    instance.name => instance.network_interface[0].access_config[0].nat_ip
  }
}

output "controller_internal_ips" {
  description = "Internal IP addresses of controller nodes"
  value = {
    for i, instance in google_compute_instance.controller :
    instance.name => instance.network_interface[0].network_ip
  }
}

# Worker node outputs
output "worker_external_ips" {
  description = "External IP addresses of worker nodes"
  value = {
    for i, instance in google_compute_instance.worker :
    instance.name => instance.network_interface[0].network_ip
  }
}

output "worker_internal_ips" {
  description = "Internal IP addresses of worker nodes"
  value = {
    for i, instance in google_compute_instance.worker :
    instance.name => instance.network_interface[0].network_ip
  }
}

# SSH connection commands
output "ssh_commands" {
  description = "SSH commands to connect to all nodes"
  value = merge(
    {
      for i, instance in google_compute_instance.controller :
      instance.name => "ssh ${var.ssh_username}@${instance.network_interface[0].access_config[0].nat_ip}"
    },
    {
      for i, instance in google_compute_instance.worker :
      instance.name => "ssh ${var.ssh_username}@${instance.network_interface[0].access_config[0].nat_ip}"
    }
  )
}

# Kubernetes API endpoint
output "kubernetes_api_endpoint" {
  description = "Kubernetes API server endpoints"
  value = [
    for instance in google_compute_instance.controller :
    "https://${instance.network_interface[0].access_config[0].nat_ip}:6443"
  ]
}

# Summary for easy reference
output "cluster_summary" {
  description = "Cluster summary"
  value = {
    controllers = length(google_compute_instance.controller)
    workers     = length(google_compute_instance.worker)
    total_nodes = length(google_compute_instance.controller) + length(google_compute_instance.worker)
    machine_type = var.machine_type
    region      = var.region
    zone        = var.zone
  }
}