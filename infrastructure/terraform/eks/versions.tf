terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }

  # S3 backend for remote state management (no state locking)
  # Configuration is completed via backend-config in GitHub Actions
  # or via terraform init -backend-config flags
  backend "s3" {
    encrypt = true
    # Note: No DynamoDB state locking configured
  }
}
