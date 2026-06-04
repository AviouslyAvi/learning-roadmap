###############################################################################
# terraform-sandbox (Hetzner Cloud)
# Provisions a throwaway server + firewall + SSH key on Hetzner Cloud.
# Real infra, real provider, pennies per hour. `terraform destroy` when done.
###############################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.48"
    }
  }
}

# Token comes from var.hcloud_token (see variables.tf + terraform.tfvars).
# Never hardcode it here — tfvars files are gitignored.
provider "hcloud" {
  token = var.hcloud_token
}

# Upload your local SSH public key so you can log into the server.
resource "hcloud_ssh_key" "default" {
  name       = "${var.project}-key"
  public_key = file(var.ssh_public_key_path)
}

# Minimal firewall: allow inbound SSH + ICMP (ping). Everything else denied.
# Outbound is unrestricted by default.
resource "hcloud_firewall" "default" {
  name = "${var.project}-fw"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  labels = local.labels
}

# The server itself. cx22 = 2 vCPU / 4GB RAM, ~€0.006/hr (billed hourly).
resource "hcloud_server" "sandbox" {
  name         = "${var.project}-01"
  image        = var.image
  server_type  = var.server_type
  location     = var.location
  ssh_keys     = [hcloud_ssh_key.default.id]
  firewall_ids = [hcloud_firewall.default.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  labels = local.labels
}

locals {
  labels = {
    project    = var.project
    owner      = "aviouslyavi"
    managed_by = "terraform"
    env        = "sandbox"
  }
}

output "server_name" {
  value       = hcloud_server.sandbox.name
  description = "Name of the provisioned server."
}

output "server_ipv4" {
  value       = hcloud_server.sandbox.ipv4_address
  description = "Public IPv4 address — ssh root@<this> to log in."
}

output "ssh_command" {
  value       = "ssh root@${hcloud_server.sandbox.ipv4_address}"
  description = "Ready-to-paste SSH command."
}
