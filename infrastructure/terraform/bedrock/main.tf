# AWS Bedrock Integration Module
terraform {
  backend "s3" {
    # Backend configuration provided during initialization:
    # terraform init -backend-config="bucket=github-actions-kargo-argocd" \
    #               -backend-config="key=terraform/bedrock/dev/terraform.tfstate" \
    #               -backend-config="region=us-east-1"
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# Data source for EKS cluster OIDC issuer
data "aws_eks_cluster" "main" {
  name = var.eks_cluster_name
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Local values
locals {
  common_tags = merge(
    var.tags,
    {
      "Project"     = "KargoArgoCD"
      "Component"   = "Bedrock"
      "Environment" = var.environment
      "ManagedBy"   = "terraform"
    }
  )
}

# IAM Role for LiteLLM service to access Bedrock
resource "aws_iam_role" "bedrock_access_role" {
  name = "${var.environment}-litellm-bedrock-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Condition = {
          StringEquals = {
            "${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:${var.litellm_namespace}:${var.litellm_service_account}"
            "${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

# IAM Policy for Bedrock model access
resource "aws_iam_policy" "bedrock_access_policy" {
  name        = "${var.environment}-litellm-bedrock-policy"
  description = "Allow LiteLLM to access Bedrock models"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:Converse",
          "bedrock:ConverseStream"
        ]
        # Broad permissions for testing - will lock down after confirming exact ARNs
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:ListFoundationModels",
          "bedrock:GetFoundationModel"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.common_tags
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "bedrock_policy_attachment" {
  role       = aws_iam_role.bedrock_access_role.name
  policy_arn = aws_iam_policy.bedrock_access_policy.arn
}
