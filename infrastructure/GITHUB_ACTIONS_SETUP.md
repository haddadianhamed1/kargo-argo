# GitHub Actions Terraform Deployment

This guide explains how to set up automated Terraform deployments using GitHub Actions with S3 backend.

## Prerequisites

### 1. AWS IAM Role for GitHub Actions (OIDC)

Create an IAM role that GitHub Actions can assume using OpenID Connect:

```bash
# Create trust policy for GitHub OIDC
cat > github-actions-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:YOUR_USERNAME/kargo-argocd:ref:refs/heads/main"
        }
      }
    }
  ]
}
EOF

# Create IAM role
aws iam create-role \
  --role-name GitHubActions-TerraformRole \
  --assume-role-policy-document file://github-actions-trust-policy.json

# Attach necessary policies
aws iam attach-role-policy \
  --role-name GitHubActions-TerraformRole \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess
```

### 2. GitHub OIDC Provider (if not exists)

```bash
# Check if OIDC provider exists
aws iam list-open-id-connect-providers

# Create if it doesn't exist
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

### 3. Repository Secrets

Add the following secrets to your GitHub repository:

- `AWS_ROLE_ARN`: The ARN of the IAM role created above
  - Example: `arn:aws:iam::123456789012:role/GitHubActions-TerraformRole`

## Workflow Features

### 🔄 Automatic Triggers

1. **Push to main**: Automatically runs `terraform plan` and `apply` for dev environment
2. **Pull Request**: Runs `terraform plan` and posts results as PR comments
3. **Feature branches**: Runs `terraform plan` for validation

### 🎛️ Manual Triggers

Use the **Actions** tab in GitHub to manually trigger:

- **Environment**: Choose `dev` or `staging`
- **Action**: Choose `plan`, `apply`, or `destroy`

### 🏗️ Multi-Environment Support

The workflow supports multiple environments with separate state files:

- **Dev**: `terraform/vpc/dev/terraform.tfstate`
- **Staging**: `terraform/vpc/stg/terraform.tfstate`

### 🛡️ Security Features

- **OIDC Authentication**: No long-lived AWS credentials
- **Environment Protection**: Apply/destroy requires environment approval
- **State Locking**: DynamoDB prevents concurrent modifications
- **Encrypted Storage**: S3 state encryption at rest

## Usage Examples

### 1. Deploy to Development

```bash
# Push to feature branch for validation
git push origin feature/terraform-infrastructure

# Merge to main for automatic deployment
git checkout main
git merge feature/terraform-infrastructure
git push origin main
```

### 2. Deploy to Staging

1. Go to **Actions** tab in GitHub
2. Select **Terraform Infrastructure** workflow
3. Click **Run workflow**
4. Choose:
   - Environment: `stg`
   - Action: `apply`

### 3. Plan Changes

```bash
# Create PR to see plan output
git checkout -b feature/vpc-changes
# Make your changes
git push origin feature/vpc-changes
# Create PR - plan will be commented automatically
```

## Workflow Jobs

### 📋 setup-backend

- Creates S3 bucket and DynamoDB table if they don't exist
- Configures encryption, versioning, and security settings
- Runs once before other jobs

### 📊 terraform-plan

- Runs for both `dev` and `staging` environments
- Validates Terraform configuration
- Posts plan output to PR comments
- Saves plan artifacts for apply job

### 🚀 terraform-apply

- Runs only on main branch or manual trigger
- Uses saved plan artifacts
- Requires environment approval for production
- Saves outputs for other workflows

### 💥 terraform-destroy

- Manual trigger only
- Requires explicit environment approval
- Use with caution!

## Environment Configuration

The workflow uses environment-specific tfvars files:

- `infrastructure/terraform/vpc/env/dev.tfvars`
- `infrastructure/terraform/vpc/env/stg.tfvars`

To add a new environment:

1. Create new `.tfvars` file in `terraform/vpc/env/`
2. Update workflow matrix to include new environment
3. Create GitHub environment for protection rules

## Monitoring and Debugging

### View Workflow Status

- **Actions Tab**: See all workflow runs
- **PR Comments**: Plan output appears automatically
- **Artifacts**: Download plans and outputs

### Common Issues

1. **OIDC Trust Policy**: Ensure repo path is correct
2. **AWS Permissions**: Role needs VPC, EC2, and S3 permissions
3. **State Lock**: If locked, check DynamoDB table for stuck locks

### Terraform State Management

```bash
# View current state (using AWS CLI)
aws s3 ls s3://github-actions-kargo-argocd/terraform/vpc/

# Download state file for inspection
aws s3 cp s3://github-actions-kargo-argocd/terraform/vpc/dev/terraform.tfstate ./

# List state versions
aws s3api list-object-versions \
  --bucket github-actions-kargo-argocd \
  --prefix terraform/vpc/dev/terraform.tfstate
```

## Security Best Practices

1. **Least Privilege**: IAM role has only necessary permissions
2. **Environment Protection**: Use GitHub environment protection rules
3. **State Encryption**: S3 bucket encryption is enabled
4. **Access Logging**: Enable CloudTrail for audit logs
5. **Branch Protection**: Require PR reviews before merging

## Extending the Workflow

### Adding New Infrastructure Modules

1. Create new directory under `infrastructure/terraform/`
2. Copy and modify workflow for new module
3. Update backend key path for separation

### Integration with EKS

The VPC outputs are designed to be consumed by EKS modules:

```yaml
# In EKS workflow
- name: Get VPC Outputs
  run: |
    aws s3 cp s3://github-actions-kargo-argocd/terraform/vpc/dev/terraform.tfstate ./
    terraform output -json > vpc-outputs.json
```

## Cost Optimization

- **Dev Environment**: Single NAT Gateway, no flow logs
- **Staging Environment**: Multi-AZ for testing production scenarios
- **State Storage**: Minimal S3 and DynamoDB costs
- **Destroy Unused**: Use destroy workflow for cleanup
