# Configure the Google Cloud Provider
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  credentials = file("${path.module}/tf-key.json")
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

# Create Jumpbox VM
resource "google_compute_instance" "jumpbox" {
  count        = 1
  name         = "jumpbox-${count.index}"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"  # Debian GNU/Linux 12 (Bookworm) amd64
      size  = 20  # Slightly larger for control plane components
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  # Use preemptible for cost savings
  scheduling {
    preemptible       = true
    automatic_restart = false
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key_path)}"
  }

  # Tags for firewall rules
  tags = ["kthw", "jumpbox"]

  labels = {
    environment = "learning"
    purpose     = "kubernetes-the-hard-way"
    role        = "jumpbox"
  }
}

# Create Controller VM (for Kubernetes control plane)
resource "google_compute_instance" "controller" {
  count        = 1
  name         = "controller-${count.index}"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"  # Debian GNU/Linux 12 (Bookworm) amd64
      size  = 20  # Space for control plane components
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  # Use preemptible for cost savings
  scheduling {
    preemptible       = true
    automatic_restart = false
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key_path)}"
  }

  # Tags for firewall rules
  tags = ["kthw", "controller"]

  labels = {
    environment = "learning"
    purpose     = "kubernetes-the-hard-way"
    role        = "controller"
  }
}

# Create Worker VMs (for Kubernetes worker nodes)
resource "google_compute_instance" "worker" {
  count        = 2
  name         = "worker-${count.index}"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"  # Debian GNU/Linux 12 (Bookworm) amd64
      size  = 20  # Space for container images
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  # Use preemptible for cost savings
  scheduling {
    preemptible       = true
    automatic_restart = false
  }

  metadata = {
    ssh-keys = "${var.ssh_username}:${file(var.ssh_public_key_path)}"
  }

  # Tags for firewall rules
  tags = ["kthw", "worker"]

  labels = {
    environment = "learning"
    purpose     = "kubernetes-the-hard-way"
    role        = "worker"
  }
}

# Allow SSH access
resource "google_compute_firewall" "allow_ssh" {
  name    = "kthw-allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["kthw"]
}

# Allow Kubernetes API server access (port 6443)
resource "google_compute_firewall" "allow_k8s_api" {
  name    = "kthw-allow-k8s-api"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }

  source_ranges = ["0.0.0.0/0"]  # So kubectl from your laptop works
  target_tags   = ["controller"]
}

# Allow internal cluster communication
resource "google_compute_firewall" "allow_internal_k8s" {
  name    = "kthw-allow-internal"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["2379-2380", "10250", "10251", "10252", "10256"]
  }

  allow {
    protocol = "udp"
    ports    = ["8472"]  # Flannel VXLAN (if using Flannel)
  }

  source_ranges = ["10.128.0.0/9"]  # Default GCP VPC CIDR
  target_tags   = ["kthw"]
}

# Allow NodePort services (30000-32767)
resource "google_compute_firewall" "allow_nodeport" {
  name    = "kthw-allow-nodeport"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["worker"]
}

# Allow ICMP (ping)
resource "google_compute_firewall" "allow_icmp" {
  name    = "kthw-allow-icmp"
  network = "default"

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["kthw"]
}