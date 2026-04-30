# Bedrock Terraform Module

This module creates AWS IAM infrastructure for LiteLLM to access AWS Bedrock models from EKS clusters using IRSA (IAM Roles for Service Accounts).

## 🎯 Module Purpose

**Objective:** Enable secure access to AWS Bedrock models from Kubernetes workloads without storing AWS credentials in pods.

**Key Features:**
- **IRSA Integration**: Uses EKS OIDC provider for secure authentication
- **Least Privilege**: Grants access only to specified Bedrock models
- **Environment Isolation**: Separate roles for dev/staging/production
- **GitOps Ready**: Outputs provide configuration for Kubernetes manifests

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────┐
│                AWS Bedrock                      │
│  Claude 3.5 Sonnet Model                      │
└─────────────┬───────────────────────────────────┘
              │ IAM Policy (InvokeModel)
              ▼
┌─────────────────────────────────────────────────┐
│           IAM Role (IRSA)                       │
│  dev-litellm-bedrock-role                      │
└─────────────┬───────────────────────────────────┘
              │ OIDC Trust Policy
              ▼
┌─────────────────────────────────────────────────┐
│           EKS Cluster                           │
│  ┌─────────────────────────────────────────┐   │
│  │        litellm namespace                │   │
│  │  ┌─────────────────────────────────┐   │   │
│  │  │    litellm-sa ServiceAccount    │   │   │
│  │  │  (eks.amazonaws.com/role-arn)   │   │   │
│  │  └─────────────────────────────────┘   │   │
│  │  ┌─────────────────────────────────┐   │   │
│  │  │       LiteLLM Pod               │   │   │
│  │  │  (uses service account)         │   │   │
│  │  └─────────────────────────────────┘   │   │
│  └─────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

## 📋 Resources Created

### IAM Resources
```
├── IAM Role: dev-litellm-bedrock-role
│   ├── Trust Policy: EKS OIDC Provider
│   │   ├── Principal: oidc-provider/[EKS-OIDC-URL]
│   │   ├── Condition: StringEquals
│   │   │   ├── :sub = system:serviceaccount:litellm:litellm-sa
│   │   │   └── :aud = sts.amazonaws.com
│   └── Attached Policies:
│       └── dev-litellm-bedrock-policy
└── IAM Policy: dev-litellm-bedrock-policy
    ├── bedrock:InvokeModel (specific model ARN)
    ├── bedrock:InvokeModelWithResponseStream
    ├── bedrock:ListFoundationModels
    └── bedrock:GetFoundationModel
```

### Security Model
- **No AWS Credentials**: Uses EKS service account token exchange
- **Scoped Access**: Only specified Bedrock model and basic list operations
- **Environment Isolation**: Separate roles per environment
- **Conditional Trust**: Only specific service account can assume role

## 🔧 Configuration

### Current Configuration (dev.tfvars)
```hcl
# Environment Settings
environment = "dev"
aws_region  = "us-east-1"

# EKS Integration
eks_cluster_name = "kargo-dev-eks"

# Bedrock Model Access
bedrock_model_id = "anthropic.claude-3-5-sonnet-20241022-v2:0"

# Kubernetes Target
litellm_namespace       = "litellm"
litellm_service_account = "litellm-sa"
```

### Available Bedrock Models
Common model IDs for different use cases:

**Anthropic Claude Models:**
- `anthropic.claude-3-5-sonnet-20241022-v2:0` - Latest, most capable
- `anthropic.claude-3-haiku-20240307-v1:0` - Fast and cost-effective
- `anthropic.claude-3-opus-20240229-v1:0` - Most powerful (if available)

**Amazon Titan Models:**
- `amazon.titan-text-express-v1` - General text generation
- `amazon.titan-text-lite-v1` - Lightweight text tasks

**Meta Llama Models:**
- `meta.llama3-70b-instruct-v1:0` - Large instruction-following model
- `meta.llama3-8b-instruct-v1:0` - Smaller, faster model

## 📤 Module Outputs

### Primary Outputs
```hcl
# For Kubernetes Service Account
output "service_account_annotations" {
  value = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.bedrock_access_role.arn
  }
}

# Complete Configuration Package
output "kubernetes_config" {
  value = {
    namespace         = "litellm"
    service_account   = "litellm-sa"
    role_arn         = "arn:aws:iam::ACCOUNT:role/dev-litellm-bedrock-role"
    bedrock_model_id = "anthropic.claude-3-5-sonnet-20241022-v2:0"
    aws_region       = "us-east-1"
  }
}
```

### Usage in Kubernetes Manifests
```yaml
# Service Account with IRSA annotation
apiVersion: v1
kind: ServiceAccount
metadata:
  name: litellm-sa
  namespace: litellm
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::ACCOUNT:role/dev-litellm-bedrock-role"

---
# Deployment using the service account
apiVersion: apps/v1
kind: Deployment
metadata:
  name: litellm
  namespace: litellm
spec:
  template:
    spec:
      serviceAccountName: litellm-sa  # Links to IRSA role
      containers:
      - name: litellm
        image: ghcr.io/berriai/litellm:main-latest
        env:
        - name: AWS_REGION
          value: "us-east-1"
        # No AWS credentials needed - uses IRSA
```

## 🚀 Deployment Instructions

### Step 1: Initialize Terraform
```bash
# Navigate to bedrock module
cd infrastructure/terraform/bedrock

# Initialize with S3 backend
terraform init \
  -backend-config="bucket=github-actions-kargo-argocd" \
  -backend-config="key=terraform/bedrock/dev/terraform.tfstate" \
  -backend-config="region=us-east-1"
```

### Step 2: Plan and Apply
```bash
# Review planned changes
terraform plan -var-file="env/dev.tfvars"

# Apply the configuration
terraform apply -var-file="env/dev.tfvars"
```

### Step 3: Capture Outputs
```bash
# Get service account annotations
terraform output -json service_account_annotations

# Get complete Kubernetes configuration
terraform output -json kubernetes_config
```

### Step 4: Validate OIDC Provider
```bash
# Verify EKS OIDC provider exists
aws eks describe-cluster --name kargo-dev-eks \
  --query 'cluster.identity.oidc.issuer' --output text

# Check if OIDC provider is registered in IAM
aws iam list-open-id-connect-providers
```

## 🔍 Troubleshooting

### Common Issues

#### OIDC Provider Not Found
```bash
# Error: "OIDC provider does not exist"
# Solution: Ensure OIDC provider is associated with EKS cluster

eksctl utils associate-iam-oidc-provider \
  --config-file ../cluster/kargo-dev-eks.yaml \
  --approve
```

#### Permission Denied from Bedrock
```bash
# Error: "User/Role is not authorized to perform: bedrock:InvokeModel"
# Check: Verify model ID and region are correct
# Check: Ensure IAM role is properly assumed

# Test role assumption
aws sts get-caller-identity

# List available Bedrock models
aws bedrock list-foundation-models --region us-east-1
```

#### Service Account Not Working
```bash
# Error: Pod cannot assume IAM role
# Check: Service account annotation is correct
kubectl get sa litellm-sa -n litellm -o yaml

# Check: Pod is using the service account
kubectl get pod <pod-name> -n litellm -o yaml | grep serviceAccountName

# Check: EKS OIDC issuer URL matches IAM trust policy
```

### Validation Commands
```bash
# Check IAM role exists
aws iam get-role --role-name dev-litellm-bedrock-role

# Test Bedrock access (requires AWS credentials)
aws bedrock list-foundation-models --region us-east-1

# Check EKS cluster OIDC
eksctl get cluster kargo-dev-eks -o yaml | grep oidc
```

## 🔒 Security Considerations

### IAM Best Practices
- **Principle of Least Privilege**: Only grants necessary Bedrock permissions
- **Resource-Specific Access**: Targets specific model ARNs, not wildcard
- **Conditional Trust**: Role can only be assumed by specific service account
- **No Long-Term Credentials**: Uses temporary STS tokens via IRSA

### Network Security
- **VPC Endpoints**: Consider adding Bedrock VPC endpoint to avoid internet traffic
- **Security Groups**: Default EKS security groups should allow HTTPS outbound
- **NAT Gateway**: Required for Bedrock API access from private subnets

### Monitoring and Auditing
```bash
# CloudTrail events to monitor
aws logs filter-log-events \
  --log-group-name CloudTrail \
  --filter-pattern "{ $.eventName = \"InvokeModel\" }"

# IAM access analyzer
aws accessanalyzer list-findings \
  --analyzer-arn "arn:aws:access-analyzer:us-east-1:ACCOUNT:analyzer/console"
```

## 📊 Cost Optimization

### Bedrock Pricing Considerations
- **Model Selection**: Claude 3 Haiku vs Sonnet vs Opus pricing tiers
- **Request Patterns**: Batch vs streaming vs individual requests
- **Token Usage**: Input vs output token pricing differences
- **Regional Pricing**: Bedrock availability and pricing by region

### Resource Tagging for Cost Tracking
```hcl
tags = {
  "Project"     = "KargoArgoCD"
  "Component"   = "Bedrock"
  "Environment" = "dev"
  "CostCenter"  = "Development"
  "Purpose"     = "AI API Gateway"
}
```

## 🔄 Environment Management

### Adding Staging Environment
```bash
# Create staging configuration
cp env/dev.tfvars env/stg.tfvars

# Edit for staging cluster
# eks_cluster_name = "kargo-stg-eks"
# environment = "stg"

# Deploy to staging
terraform workspace new stg  # or use separate state files
terraform apply -var-file="env/stg.tfvars"
```

### Cross-Environment Dependencies
```hcl
# Reference VPC outputs if needed
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "github-actions-kargo-argocd"
    key    = "terraform/vpc/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}
```

## 📚 Next Steps

### Kubernetes Integration
1. **Create Namespace**: `kubectl create namespace litellm`
2. **Create Service Account**: Use terraform outputs for annotations
3. **Deploy LiteLLM**: Configure with Bedrock model from outputs
4. **Test API Access**: Verify Bedrock model invocation works

### GitOps Integration
1. **Add to ArgoCD**: Create Application for LiteLLM
2. **Kustomize Configuration**: Environment-specific overlays
3. **Kargo Pipeline**: Automated dev → staging promotion

### Production Readiness
1. **Multi-Model Support**: Extend IAM policy for multiple models
2. **Monitoring**: CloudWatch metrics and alerts
3. **Scaling**: HPA configuration for LiteLLM pods
4. **Security**: Additional security policies and network controls

## 📖 References

- **AWS Bedrock Documentation**: [Bedrock User Guide](https://docs.aws.amazon.com/bedrock/)
- **EKS IRSA Guide**: [IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
- **LiteLLM Documentation**: [LiteLLM Bedrock Integration](https://docs.litellm.ai/docs/providers/bedrock)
- **Terraform AWS Provider**: [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 🏷️ Resource Naming Convention

```
Pattern: {environment}-{service}-{resource-type}

Examples:
- IAM Role: dev-litellm-bedrock-role
- IAM Policy: dev-litellm-bedrock-policy
- Service Account: litellm-sa
- Namespace: litellm
- State File: terraform/bedrock/dev/terraform.tfstate
```
