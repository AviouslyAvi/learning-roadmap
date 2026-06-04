---
type: project
status: active
started: 2026-05-29
---

# terraform-sandbox (Hetzner Cloud)

A minimal, **destroyable** Terraform project that provisions one real server on Hetzner Cloud — plus the SSH key and firewall it needs — entirely in code. Spin it up, SSH in, poke around, then `terraform destroy` it. Real infra, real provider, pennies per hour.

> **Why this exists:** I'm a sysadmin transitioning into cloud automation, learning Infrastructure as Code end-to-end. This is the "real billed cloud" companion to my `terraform-localstack-s3-lab` (which was $0/fake AWS). Here the API calls are real, so the muscle memory transfers to production.

---

## The 5 Ws

- **Who** — me, learning the full Terraform provisioning lifecycle on real infra.
- **What** — 3 resources: an SSH key, a firewall (SSH + ping only), and a `cx22` server running Ubuntu 24.04.
- **When** — spin up to experiment, **destroy when done** (billing is hourly — leaving it up is the only way to waste money).
- **Where** — Hetzner Cloud, Nuremberg (`nbg1`) by default. US locations available (`ash`, `hil`).
- **Why Hetzner and not netcup** — Hetzner Cloud has a first-class official Terraform provider with a clean API. netcup has no real Terraform support (SOAP API, no official provider), so it's managed by hand. This project is the contrast case for "provider support decides the tool."

---

## What this provisions

| Resource | Type | Notes |
|---|---|---|
| `tf-sandbox-key` | `hcloud_ssh_key` | Your local public key, uploaded |
| `tf-sandbox-fw` | `hcloud_firewall` | Inbound SSH (22) + ICMP only |
| `tf-sandbox-01` | `hcloud_server` | cx22 · 2 vCPU / 4GB · Ubuntu 24.04 |

Cost: **~€0.006/hr** (~€4.50/mo if you forget to destroy it). Always destroy when you're done.

---

## Prerequisites

1. **A Hetzner Cloud account + project.** Sign up at [console.hetzner.cloud](https://console.hetzner.cloud).
2. **An API token.** In the console: your project → **Security → API Tokens → Generate**, permission **Read & Write**. Copy it (shown once).
3. **An SSH key.** If you don't have one:
   ```bash
   ssh-keygen -t ed25519 -C "tf-sandbox"
   ```
   The config defaults to `~/.ssh/id_ed25519.pub`.

---

## Workflow

```bash
# 1. Configure your secrets (one time)
cp terraform.tfvars.example terraform.tfvars
#   then edit terraform.tfvars and paste your API token

# 2. Download the Hetzner provider into this folder
terraform init

# 3. Preview what Terraform will create — read this carefully
terraform plan

# 4. Make it real (asks for confirmation; type "yes")
terraform apply

# 5. Terraform prints the SSH command as an output. Log in:
ssh root@<server_ipv4>

# 6. When you're done playing — tear it all down
terraform destroy
```

`terraform destroy` removes the server, firewall, and SSH key from Hetzner. Billing stops the moment the server is deleted.

---

## What to try while it's up

- `terraform plan` again after editing `variables.tf` (e.g. change `server_type` to `cax11`) — watch Terraform figure out it must **replace** the server.
- Add a second `hcloud_server` resource and `apply` — see it create only the new one.
- Open a port in the firewall (add an `80` rule), `apply`, and watch it update in place without recreating the server.
- Run `terraform state list` and `terraform show` to inspect tracked state.

---

## Files

| File | Purpose |
|---|---|
| `main.tf` | Provider, resources, outputs |
| `variables.tf` | Input variables + defaults |
| `terraform.tfvars.example` | Template for your secrets (copy to `terraform.tfvars`) |
| `.gitignore` | Keeps state, `.terraform/`, and `*.tfvars` out of git |

> **Security note:** `terraform.tfvars` (your token) and `*.tfstate` (which can contain sensitive values) are gitignored. Never commit them. Only `*.example` ships to GitHub.
