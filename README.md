This Terraform configuration creates the infrastructure needed for [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) tutorial.

## Infrastructure Created

- **1 Jumpbox** (Kubernetes Administration host)
- **1 server node** (for Kubernetes control plane)
- **2 Worker nodes** (for Kubernetes workloads)
- **Firewall rules** for SSH, Kubernetes API, and internal cluster communication
- **Debian 12 (Bookworm)** on all nodes
- **e2-small instances** (cost-effective for learning)
- **Preemptible VMs** (up to 80% cost savings)

## Prerequisites

1. **GCP Account** with billing enabled
2. **Terraform** installed
3. **Google Cloud SDK** installed and configured
4. **SSH key pair** generated
5. **Service Account JSON** with appropriate permissions

## Quick Setup

### 1. Authentication Setup
```bash
# Create service account with necessary permissions
# Download JSON key and place in same directory as main.tf
# Rename your JSON file to match the filename in main.tf (line 12)