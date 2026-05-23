# Lab artifact

This file was uploaded to an S3 bucket by Terraform against LocalStack.
If you can read this via `awslocal s3 cp s3://acf-iac-lab-bucket/readme-snapshot.md -`,
the full IaC loop worked: HCL → AWS API call → LocalStack → object stored.
