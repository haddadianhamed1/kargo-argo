# Bedrock Integration Terraform Module

This module creates AWS IAM resources required for LiteLLM to access AWS Bedrock models from EKS clusters using IRSA (IAM Roles for Service Accounts).

## What it creates

- IAM Role for Bedrock access with OIDC trust policy
- IAM Policy granting access to specified Bedrock model
- Properly configured trust relationships for EKS service accounts

## Usage

### Initialize and Apply

```bash
# Navigate to module directory
cd infrastructure/terraform/bedrock

# Initialize with dev environment backend
terraform init \
  -backend-config="bucket=github-actions-kargo-argocd" \
  -backend-config="key=terraform/bedrock/dev/terraform.tfstate" \
  -backend-config="region=us-east-1"

# Plan for development environment
terraform plan -var-file="env/dev.tfvars"

# Apply development changes
terraform apply -var-file="env/dev.tfvars"
```

### Get Outputs for Kubernetes

```bash
# Get the service account annotations needed
terraform output service_account_annotations

# Get complete Kubernetes configuration
terraform output kubernetes_config
```

## Outputs

- `bedrock_role_arn`: IAM role ARN for Kubernetes service account annotation
- `service_account_annotations`: Ready-to-use annotations for service account
- `kubernetes_config`: Complete configuration values for deployment

## Next Steps

After applying this module:

1. Create Kubernetes namespace: `kubectl create namespace litellm`
2. Create service account with the output annotations
3. Deploy LiteLLM with the service account
4. Configure LiteLLM to use the Bedrock model ID from outputs

## Configuration

Currently configured for:
- **Model**: Claude 3.5 Sonnet (latest)
- **Environment**: Development only
- **Cluster**: kargo-dev-eks
- **Namespace**: litellm
