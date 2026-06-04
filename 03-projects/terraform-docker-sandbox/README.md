---
type: project
status: active
started: 2026-05-29
---

# terraform-docker-sandbox

A **free, fully local** Terraform project that provisions real Docker containers and a network on your own machine. Same `init → plan → apply → destroy` workflow you'd use on Hetzner or AWS — but **$0, no API token, no cloud account**. The closest "feels like managing servers" practice you can get without spending anything.

> **Why this exists:** The cloud-feel companion to `terraform-localstack-s3-lab` ($0 fake AWS) and `terraform-sandbox` (real billed Hetzner). Here the resources are real containers you can `docker ps`, but they live on your laptop — so you can iterate fearlessly.

---

## What this provisions

| Resource | Type | Notes |
|---|---|---|
| `tf-docker-net` | `docker_network` | Bridge network the containers share |
| `nginx:1.27-alpine` | `docker_image` | Pulled declaratively |
| `tf-docker-web` | `docker_container` | nginx, mapped to `localhost:8080` |
| `alpine:3.20` | `docker_image` | Worker base image |
| `tf-docker-worker` | `docker_container` | `sleep infinity`, for multi-resource practice |

Cost: **$0**. Everything runs on your local Docker daemon.

---

## Prerequisites

1. **Docker installed and running.** Docker Desktop (macOS/Windows) or Docker Engine (Linux).
   - ⚠️ On this machine `docker` was **not on PATH** at scaffold time — install/start Docker Desktop and confirm with `docker ps` before running Terraform.
2. **Terraform ≥ 1.5.**

---

## Workflow

```bash
cd 03-projects/terraform-docker-sandbox

terraform init      # downloads the kreuzwerker/docker provider
terraform plan      # preview the 5 resources
terraform apply     # create them (type "yes")

# verify outside Terraform:
docker ps
curl http://localhost:8080      # nginx welcome page

terraform destroy   # tear it all down
```

---

## What to try

- `docker ps` before/after apply — see Terraform-managed containers appear/disappear.
- Change `web_port` in `variables.tf`, `apply`, watch it **recreate** the container.
- Bump `nginx_image` to a newer tag, `apply`, watch the image + container update.
- Add a third container with `for_each` over a map to learn iteration.
- `terraform state list` / `terraform graph` to inspect the dependency graph.

---

## Files

| File | Purpose |
|---|---|
| `main.tf` | Provider, network, images, containers, outputs |
| `variables.tf` | Inputs + defaults |
| `.gitignore` | Keeps state + `.terraform/` out of git |
