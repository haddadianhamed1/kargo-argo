# AWS Configuration
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string
  validation {
    condition     = contains(["dev", "stg", "prd"], var.environment)
    error_message = "Environment must be dev, stg, or prd."
  }
}

# EKS Configuration
variable "eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

# Bedrock Configuration
variable "bedrock_model_id" {
  description = "Bedrock model ID to grant access to"
  type        = string
  default     = "anthropic.claude-3-5-sonnet-20241022-v2:0"
}

# Kubernetes Configuration
variable "litellm_namespace" {
  description = "Kubernetes namespace for LiteLLM deployment"
  type        = string
  default     = "litellm"
}

variable "litellm_service_account" {
  description = "Kubernetes service account name for LiteLLM"
  type        = string
  default     = "litellm-sa"
}

# Tags
variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
