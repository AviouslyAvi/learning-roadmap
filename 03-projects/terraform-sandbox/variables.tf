variable "hcloud_token" {
  description = "Hetzner Cloud API token (project-scoped, Read & Write). Set in terraform.tfvars."
  type        = string
  sensitive   = true
}

variable "project" {
  description = "Short slug used to name/label all resources."
  type        = string
  default     = "tf-sandbox"
}

variable "ssh_public_key_path" {
  description = "Path to your SSH public key. This key gets added to the server."
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "server_type" {
  description = "Hetzner server type. cx22 = 2 vCPU / 4GB. cax11 = ARM, cheaper."
  type        = string
  default     = "cx22"
}

variable "image" {
  description = "OS image."
  type        = string
  default     = "ubuntu-24.04"
}

variable "location" {
  description = "Datacenter location. nbg1=Nuremberg, fsn1=Falkenstein, hel1=Helsinki, ash=Ashburn US, hil=Hillsboro US."
  type        = string
  default     = "nbg1"
}
