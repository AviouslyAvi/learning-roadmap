---
type: cheatsheet
tool: terraform
updated: 2026-05-29
---

# terraform — quick reference

Terraform is declarative: you write `.tf` files describing the *desired* state, and Terraform makes real infrastructure match it. The state of what actually exists is tracked in `terraform.tfstate` (never hand-edit, never commit it).

Distilled while building the `03-projects/terraform-docker-sandbox` and `terraform-sandbox` (Hetzner) labs.

## The core loop (what I actually use)

The four commands that make up 95% of daily Terraform:

| | |
|---|---|
| Download providers, prep folder | `terraform init` |
| Preview changes (safe, read-only) | `terraform plan` |
| Apply changes (creates/updates real infra) | `terraform apply` |
| Tear everything down | `terraform destroy` |

Mental model: **init** once per project (and after adding providers) → **plan** to see what will happen → **apply** to make it real → **destroy** when you're done. Always read the plan before saying yes.

## Lifecycle

| | |
|---|---|
| Initialize project / download providers | `terraform init` |
| Re-init after provider changes | `terraform init -upgrade` |
| Preview the diff | `terraform plan` |
| Save a plan to a file | `terraform plan -out=tfplan` |
| Apply (prompts for "yes") | `terraform apply` |
| Apply without prompt | `terraform apply -auto-approve` |
| Apply a saved plan (no prompt) | `terraform apply tfplan` |
| Destroy all managed infra | `terraform destroy` |
| Preview a destroy | `terraform plan -destroy` |

## Targeting & variables

| | |
|---|---|
| Act on one resource only | `terraform apply -target=docker_container.web` |
| Pass a variable inline | `terraform apply -var="web_port=9090"` |
| Use a specific vars file | `terraform apply -var-file=prod.tfvars` |

`terraform.tfvars` is loaded automatically — no flag needed. Secrets go there (gitignored), never in `.tf` files.

## Formatting & validation

| | |
|---|---|
| Auto-format all `.tf` files | `terraform fmt` |
| Check formatting (CI-friendly, no writes) | `terraform fmt -check` |
| Recurse into subfolders | `terraform fmt -recursive` |
| Validate syntax & config (needs init) | `terraform validate` |

Run `fmt` before every commit; `validate` catches errors before a real `plan`.

## Inspecting state & outputs

| | |
|---|---|
| List everything in state | `terraform state list` |
| Show full state (human-readable) | `terraform show` |
| Show details of one resource | `terraform state show docker_container.web` |
| Print all outputs | `terraform output` |
| Print one output (scriptable) | `terraform output -raw web_url` |
| Show the dependency graph | `terraform graph` |

## State surgery (use sparingly)

| | |
|---|---|
| Stop managing a resource (keep it alive) | `terraform state rm <addr>` |
| Import existing infra into state | `terraform import <addr> <id>` |
| Force a resource to be recreated next apply | `terraform taint <addr>` (old) / `terraform apply -replace=<addr>` (new) |
| Move/rename a resource in state | `terraform state mv <old> <new>` |

`-replace=` is the modern replacement for `taint`. Reach for these only when state and reality have drifted.

## Workspaces (multiple environments, one config)

| | |
|---|---|
| List workspaces | `terraform workspace list` |
| Create one | `terraform workspace new staging` |
| Switch | `terraform workspace select staging` |

Each workspace gets its own isolated state — handy for dev vs. prod from the same code.

## Misc

| | |
|---|---|
| Show version + providers | `terraform version` |
| Open console for testing expressions | `terraform console` |
| Get/update modules | `terraform get -update` |

## Gotchas

- **Never commit** `terraform.tfstate`, `*.tfvars`, or `.terraform/` — they hold secrets or are machine-local. (The lab `.gitignore` already handles this.)
- **`plan` is always safe** — it never changes anything. When unsure, plan.
- **`destroy` is irreversible** — it deletes real resources. Double-check which folder/workspace you're in first.
- A `plan` that shows "must be replaced" means destroy-then-create — fine for a sandbox container, dangerous for a database with data.
- `apply` re-runs `plan` internally and shows it again before prompting — so a bare `terraform apply` is safe to type; just don't `-auto-approve` blindly.
- State can drift if someone changes infra by hand. `terraform plan` reveals drift; `terraform refresh` (or plan's built-in refresh) reconciles it.
