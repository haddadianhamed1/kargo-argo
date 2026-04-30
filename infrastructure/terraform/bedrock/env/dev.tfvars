# Development Environment Configuration for Bedrock

# Environment Settings
environment = "dev"

# AWS Configuration
aws_region = "us-east-1"

# EKS Configuration
eks_cluster_name = "kargo-dev-eks"  # Match your existing dev cluster

# Bedrock Configuration
bedrock_model_id = "us.anthropic.claude-3-haiku-20240307-v1:0"  # Current inference profile ID for testing

# Kubernetes Configuration
litellm_namespace       = "litellm"
litellm_service_account = "litellm"

# Additional tags for development
tags = {
  "CostCenter"   = "Development"
  "Environment"  = "dev"
  "TeamContact"  = "dev-team@company.com"
  "Purpose"      = "AI API Gateway"
  "AutoShutdown" = "true"
}
