# GitHub Actions Terraform Deployment

This guide explains how to set up automated Terraform deployments using GitHub Actions with S3 backend.

## Prerequisites

### 1. AWS IAM User for GitHub Actions

Create an IAM user with programmatic access for GitHub Actions:

```bash
# Create IAM user
aws iam create-user --user-name GitHubActions-TerraformUser

# Attach necessary policies
aws iam attach-user-policy \
  --user-name GitHubActions-TerraformUser \
  --policy-arn arn:aws:iam::aws:policy/PowerUserAccess

# Create access keys
aws iam create-access-key --user-name GitHubActions-TerraformUser
```

**Note the Access Key ID and Secret Access Key from the output.**

### 2. Repository Secrets

Add the following secrets to your GitHub repository:

- `AWS_ACCESS_KEY_ID`: The access key ID from step 1
- `AWS_SECRET_ACCESS_KEY`: The secret access key from step 1

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

- **IAM User Access**: Dedicated IAM user for GitHub Actions
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

1. **Invalid Credentials**: Ensure AWS access keys are valid and not expired
2. **AWS Permissions**: IAM user needs VPC, EC2, and S3 permissions
3. **State Lock**: If locked, check DynamoDB table for stuck locks
4. **Region Mismatch**: Ensure AWS region matches your configuration

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

1. **Least Privilege**: IAM user has only necessary permissions
2. **Secure Secrets**: Store AWS credentials as GitHub repository secrets
3. **Environment Protection**: Use GitHub environment protection rules
4. **State Encryption**: S3 bucket encryption is enabled
5. **Access Logging**: Enable CloudTrail for audit logs
6. **Branch Protection**: Require PR reviews before merging
7. **Key Rotation**: Regularly rotate AWS access keys

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
