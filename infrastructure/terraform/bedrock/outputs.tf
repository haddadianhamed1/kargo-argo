# IAM Role Information
output "bedrock_role_arn" {
  description = "ARN of the IAM role for Bedrock access"
  value       = aws_iam_role.bedrock_access_role.arn
}

output "bedrock_role_name" {
  description = "Name of the IAM role for Bedrock access"
  value       = aws_iam_role.bedrock_access_role.name
}

# Service Account Configuration
output "service_account_annotations" {
  description = "Annotations needed for Kubernetes service account"
  value = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.bedrock_access_role.arn
  }
}

# Bedrock Configuration
output "bedrock_model_id" {
  description = "Bedrock model ID configured for access"
  value       = var.bedrock_model_id
}

output "aws_region" {
  description = "AWS region where Bedrock is configured"
  value       = var.aws_region
}

# Kubernetes Configuration
output "kubernetes_config" {
  description = "Configuration values for Kubernetes deployment"
  value = {
    namespace        = var.litellm_namespace
    service_account  = var.litellm_service_account
    role_arn         = aws_iam_role.bedrock_access_role.arn
    bedrock_model_id = var.bedrock_model_id
    aws_region       = var.aws_region
  }
}
