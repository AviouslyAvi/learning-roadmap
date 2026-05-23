# terraform-localstack-s3-lab

A minimal, zero-cost Terraform lab that provisions an AWS S3 bucket and two objects — but against **LocalStack**, an open-source local emulator of AWS APIs. The Terraform code uses the real `hashicorp/aws` provider with real AWS resource syntax. Only the endpoint is swapped.

> **Why this exists:** I'm a sysadmin at a nonprofit foundation transitioning into cloud automation. I'm building public labs to learn Infrastructure as Code (IaC) end-to-end — free, reproducible, and before touching billed cloud accounts.

---

## What this provisions

| Resource | Type | Notes |
|---|---|---|
| `acf-iac-lab-bucket` | `aws_s3_bucket` | Tagged for ownership / project / environment |
| `hello.txt` | `aws_s3_object` | Inline content |
| `readme-snapshot.md` | `aws_s3_object` | Uploaded from `files/readme-snapshot.md` |

Total: **3 resources**, **$0 cost**, **0 real AWS API calls**.

---

## Why LocalStack

- **Free.** No AWS account, no credit card.
- **Real Terraform syntax.** The `.tf` file is what you'd write against real AWS — only the `endpoints` block in the provider is different.
- **Fast feedback loop.** Apply / destroy in seconds, no quotas, no IAM friction.
- **Safe.** Cannot accidentally bill anyone, page anyone, or break anyone's prod.

When I'm ready for real AWS, I delete the `endpoints` block, drop the fake creds, and the same Terraform code targets real S3. (See *Next steps* below.)

---

## Prerequisites

- macOS (tested on Apple Silicon)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or Colima)
- [Terraform](https://developer.hashicorp.com/terraform/install) `>= 1.5`
- [LocalStack CLI](https://docs.localstack.cloud/getting-started/installation/)
- [`awscli-local`](https://github.com/localstack/awscli-local) (`awslocal` wrapper)

Install on macOS:

```zsh
brew install --cask docker
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
brew install localstack/tap/localstack-cli
brew install awscli-local
```

---

## How to run

```zsh
# 1. Start LocalStack (Docker must be running)
localstack start -d
localstack status services | grep s3   # confirm s3 is "available"

# 2. Initialize Terraform (downloads the AWS provider)
terraform init

# 3. Preview what will be created
terraform plan

# 4. Apply
terraform apply -auto-approve

# 5. Verify objects landed in the (local) bucket
awslocal s3 ls
awslocal s3 ls s3://acf-iac-lab-bucket/
awslocal s3 cp s3://acf-iac-lab-bucket/hello.txt -

# 6. Tear it all down
terraform destroy -auto-approve

# 7. Stop LocalStack when done
localstack stop
```

Expected plan summary: **`Plan: 3 to add, 0 to change, 0 to destroy.`**

See [`plan-output.txt`](./plan-output.txt) for a captured plan run.

---

## What I learned

- **HCL → API translation.** The Terraform AWS provider is a Go binary that converts each `resource` block into AWS REST/JSON API calls (e.g., `CreateBucket`, `PutObject`). LocalStack just intercepts those calls on `localhost:4566`.
- **State is the source of truth.** Terraform doesn't introspect the cloud each run — it diffs your code against `terraform.tfstate`. Lose state, lose the map.
- **Declarative > imperative.** I described the *desired* end state, not the steps. Re-running `apply` is a no-op when nothing changed. That's the whole game.
- **Provider blocks are pluggable.** Same code, different `endpoints` → different cloud. That's why Terraform won over CloudFormation for multi-cloud shops.
- **LocalStack ≠ real AWS.** No IAM nuance, no eventual consistency surprises, no quotas. Great for syntax practice, not a substitute for testing in real AWS.

---

## Next steps / real AWS variant

To run this against real AWS:

1. Delete the `endpoints { ... }` block and the `skip_*` / `s3_use_path_style` lines from `main.tf`.
2. Remove the hardcoded `access_key`/`secret_key`. Configure credentials via `aws configure` or an IAM role.
3. Pick a globally unique bucket name (S3 bucket names are global).
4. `terraform plan` → `terraform apply`.

Stretch goals tracked on my portfolio backlog:

- Add a GitHub Actions workflow that runs `terraform fmt -check`, `validate`, and `plan` on every PR.
- Port the same lab to **Azure Blob Storage** with the `azurerm` provider, using either Azurite (local) or Azure free tier. Pairs with my AZ-900 prep.
- Add S3 versioning, server-side encryption, and a lifecycle policy as a reusable Terraform module.

---

## Repo layout

```
.
├── main.tf                    # Provider + 3 resources + outputs
├── files/
│   └── readme-snapshot.md     # Uploaded as an S3 object
├── plan-output.txt            # Captured `terraform plan` output
├── screenshots/
│   └── plan.png               # Visual proof of plan
├── .gitignore
└── README.md
```

---

## License

MIT
