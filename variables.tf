variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "machine_type" {
  description = "The machine type for VMs"
  type        = string
  default     = "e2-small"
}

variable "ssh_username" {
  description = "SSH username"
  type        = string
  default     = "kthw-gcp"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/gcp_k8s_hw.pub"
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key corresponding to the public key."
  type        = string
  default     = "~/.ssh/kthw-gcp" # Corresponds to the public key
}
