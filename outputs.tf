# Jumpbox outputs
output "jumpbox_external_ip" {
  description = "External IP address of jumpbox"
  value = {
    for i, instance in google_compute_instance.jumpbox :
    instance.name => instance.network_interface[0].access_config[0].nat_ip
  }
}

output "jumpbox_internal_ip" {
  description = "Internal IP address of jumpbox"
  value = {
    for i, instance in google_compute_instance.jumpbox :
    instance.name => instance.network_interface[0].network_ip
  }
}

# Controller node outputs
output "controller_external_ip" {
  description = "External IP address of controller node"
  value = {
    for i, instance in google_compute_instance.controller :
    instance.name => instance.network_interface[0].access_config[0].nat_ip
  }
}

output "controller_internal_ip" {
  description = "Internal IP address of controller node"
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
    instance.name => instance.network_interface[0].access_config[0].nat_ip
  }
}

output "worker_internal_ips" {
  description = "Internal IP addresses of worker nodes"
  value = {
    for i, instance in google_compute_instance.worker :
    instance.name => instance.network_interface[0].network_ip
  }
}

# SSH connection commands with private key
output "ssh_commands" {
  description = "SSH commands to connect to all nodes (with private key)"
  value = merge(
    {
      for i, instance in google_compute_instance.jumpbox :
      instance.name => "ssh -i ~/.ssh/kthw-gcp ${var.ssh_username}@${instance.network_interface[0].access_config[0].nat_ip}"
    },
    {
      for i, instance in google_compute_instance.controller :
      instance.name => "ssh -i ~/.ssh/kthw-gcp ${var.ssh_username}@${instance.network_interface[0].access_config[0].nat_ip}"
    },
    {
      for i, instance in google_compute_instance.worker :
      instance.name => "ssh -i ~/.ssh/kthw-gcp ${var.ssh_username}@${instance.network_interface[0].access_config[0].nat_ip}"
    }
  )
}

# All external IPs in one place
output "all_external_ips" {
  description = "All external IP addresses"
  value = merge(
    {
      for i, instance in google_compute_instance.jumpbox :
      instance.name => instance.network_interface[0].access_config[0].nat_ip
    },
    {
      for i, instance in google_compute_instance.controller :
      instance.name => instance.network_interface[0].access_config[0].nat_ip
    },
    {
      for i, instance in google_compute_instance.worker :
      instance.name => instance.network_interface[0].access_config[0].nat_ip
    }
  )
}

# All internal IPs in one place
output "all_internal_ips" {
  description = "All internal IP addresses"
  value = merge(
    {
      for i, instance in google_compute_instance.jumpbox :
      instance.name => instance.network_interface[0].network_ip
    },
    {
      for i, instance in google_compute_instance.controller :
      instance.name => instance.network_interface[0].network_ip
    },
    {
      for i, instance in google_compute_instance.worker :
      instance.name => instance.network_interface[0].network_ip
    }
  )
}

# Summary for easy reference
output "cluster_summary" {
  description = "Cluster summary"
  value = {
    jumpbox     = length(google_compute_instance.jumpbox)
    controllers = length(google_compute_instance.controller)
    workers     = length(google_compute_instance.worker)
    total_nodes = length(google_compute_instance.jumpbox) + length(google_compute_instance.controller) + length(google_compute_instance.worker)
    machine_type = var.machine_type
    region      = var.region
    zone        = var.zone
  }
}

# Quick reference for copy-paste
output "quick_ssh_jumpbox" {
  description = "Quick SSH command for jumpbox"
  value = length(google_compute_instance.jumpbox) > 0 ? "ssh -i ~/.ssh/kthw-gcp ${var.ssh_username}@${google_compute_instance.jumpbox[0].network_interface[0].access_config[0].nat_ip}" : "No jumpbox created"
}

output "quick_ssh_controller" {
  description = "Quick SSH command for controller"
  value = length(google_compute_instance.controller) > 0 ? "ssh -i ~/.ssh/kthw-gcp ${var.ssh_username}@${google_compute_instance.controller[0].network_interface[0].access_config[0].nat_ip}" : "No controller created"
}
