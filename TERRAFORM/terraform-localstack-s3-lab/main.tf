###############################################################################
# terraform-localstack-s3-lab
# Provisions an S3 bucket + two objects against LocalStack (local AWS emulator).
# Zero cost. No real AWS account touched.
###############################################################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS provider, but pointed at LocalStack on localhost:4566.
# All creds are fake — LocalStack ignores them but the SDK requires the fields.
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # S3 needs path-style addressing against LocalStack, not virtual-host-style.
  s3_use_path_style = true

  endpoints {
    s3 = "http://localhost:4566"
  }
}

resource "aws_s3_bucket" "lab" {
  bucket = "acf-iac-lab-bucket"

  tags = {
    Project     = "terraform-localstack-s3-lab"
    Owner       = "AviouslyAvi"
    Environment = "local"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_object" "hello" {
  bucket       = aws_s3_bucket.lab.id
  key          = "hello.txt"
  content      = "Hello from Terraform + LocalStack.\nSysadmin → cloud, one bucket at a time.\n"
  content_type = "text/plain"
}

resource "aws_s3_object" "readme_snapshot" {
  bucket       = aws_s3_bucket.lab.id
  key          = "readme-snapshot.md"
  content      = file("${path.module}/files/readme-snapshot.md")
  content_type = "text/markdown"
}

output "bucket_name" {
  value       = aws_s3_bucket.lab.id
  description = "Name of the provisioned S3 bucket (in LocalStack)."
}

output "object_keys" {
  value       = [aws_s3_object.hello.key, aws_s3_object.readme_snapshot.key]
  description = "Keys of objects uploaded to the bucket."
}
