# Infrastructure Documentation

This directory contains the complete infrastructure-as-code for the Kargo ArgoCD project using Terraform and AWS.

## 🏗️ Architecture Overview

**Infrastructure Strategy:**
- **Multi-Environment**: Separate configurations for dev/stg/prd environments
- **Modular Design**: Each component (VPC, EKS, RDS) in separate modules
- **State Management**: S3 backend with environment-specific state files
- **Automation**: GitHub Actions for CI/CD deployment pipeline
- **Security**: AWS access keys, encrypted state, environment isolation

## 📁 Directory Structure

```
infrastructure/
├── terraform/               # Terraform modules and configurations
│   ├── vpc/                # VPC networking infrastructure
│   ├── eks/                # Kubernetes cluster (future)
│   └── rds/                # Database infrastructure (future)
├── scripts/                # Infrastructure utilities and helpers
├── docs/                   # Additional documentation (future)
├── GITHUB_ACTIONS_SETUP.md # GitHub Actions deployment guide
├── README.md               # Quick start and overview
└── CLAUDE.md               # This file - infrastructure context
```

## 🌍 Environment Strategy

### Development (dev)
- **Purpose**: Development and feature testing
- **Cost Optimization**: Single AZ, minimal resources
- **Access**: Open access for development team
- **Naming**: `kargo-dev-*-useast1` pattern

### Staging (stg)
- **Purpose**: Pre-production testing and validation
- **High Availability**: Multi-AZ deployment
- **Production-Like**: Mirrors production configuration
- **Naming**: `kargo-stg-*-useast1` pattern

### Production (prd) - Future
- **Purpose**: Live production workloads
- **Security**: Maximum security and monitoring
- **Compliance**: Audit logging and backup policies
- **Naming**: `kargo-prd-*-useast1` pattern

## 🏷️ Naming Convention

**CloudPosse Label Module Pattern:**
```
{namespace}-{environment}-{name}-{attributes}-{region}
Examples:
- kargo-dev-argocd-vpc-useast1
- kargo-stg-argocd-vpc-useast1
```

**Benefits:**
- Consistent across all resources
- Environment and region identification
- Easy filtering and cost tracking
- Automated via label module

## 🔄 Deployment Pipeline

### GitHub Actions Workflow
- **Trigger**: Push to main, PR creation, manual dispatch
- **Backend Setup**: Automatic S3 bucket creation and configuration
- **Multi-Environment**: Matrix strategy for dev/stg environments
- **Security**: AWS access keys stored as GitHub secrets
- **Validation**: Terraform validate, plan, and apply stages

### State Management
- **Backend**: S3 with environment-specific keys
- **Encryption**: AES256 encryption at rest
- **No Locking**: Simplified without DynamoDB for cost optimization
- **Isolation**: Separate state files per environment

### Workflow States
```
terraform/vpc/dev/terraform.tfstate      # Development VPC state
terraform/vpc/stg/terraform.tfstate      # Staging VPC state
terraform/eks/dev/terraform.tfstate      # Development EKS state (future)
terraform/eks/stg/terraform.tfstate      # Staging EKS state (future)
```

## 🔐 Security Considerations

### Access Control
- **AWS IAM**: Dedicated user for GitHub Actions
- **Least Privilege**: PowerUser policy for infrastructure deployment
- **Secret Management**: GitHub repository secrets for AWS credentials
- **Environment Protection**: GitHub environment protection rules

### Network Security
- **Private Subnets**: Application workloads isolated from internet
- **Security Groups**: Kubernetes-specific rules pre-configured
- **VPC Endpoints**: Optional for reduced data transfer costs
- **NAT Gateways**: Secure outbound internet access

### Compliance
- **Encryption**: S3 state files encrypted at rest
- **Auditing**: CloudTrail integration recommended
- **Backup**: S3 versioning for state file history
- **Documentation**: Infrastructure documented as code

## 📊 Cost Optimization

### Development Environment
- **Single AZ**: Reduced networking costs
- **Single NAT Gateway**: Minimize NAT charges
- **No VPC Endpoints**: Reduce interface costs
- **Auto-Shutdown**: Tags support automated resource cleanup

### Staging Environment
- **Multi-AZ**: Production-like for testing
- **VPC Endpoints**: Enable for performance testing
- **Multiple NAT Gateways**: High availability testing
- **Monitoring**: Enable for testing observability

### Cost Monitoring
- **Resource Tags**: Environment, project, cost center
- **AWS Cost Explorer**: Filter by tags for cost analysis
- **Budget Alerts**: Set up per-environment budgets
- **Resource Cleanup**: Automated via GitHub workflows

## 🔧 Development Workflow

### Local Development
1. **Install Tools**: tfswitch, AWS CLI, git
2. **Configure Backend**: S3 bucket and credentials
3. **Initialize**: `terraform init` with backend config
4. **Plan**: `terraform plan` with environment tfvars
5. **Apply**: `terraform apply` (development only)

### CI/CD Workflow
1. **Feature Branch**: Create `feature/infrastructure-*` branch
2. **Validation**: Pre-commit hooks run terraform validate
3. **Pull Request**: GitHub Actions runs plan for both environments
4. **Review**: Code review and plan output verification
5. **Merge**: Automatic apply to development environment
6. **Manual Promotion**: Workflow dispatch for staging deployment

## 🚀 Future Roadmap

### Phase 1: Foundation (Current)
- ✅ VPC networking with CloudPosse modules
- ✅ Multi-environment configuration
- ✅ GitHub Actions deployment pipeline
- ✅ S3 state backend

### Phase 2: Kubernetes Platform
- 🔄 EKS cluster module with IRSA
- 🔄 ALB Ingress Controller
- 🔄 External DNS configuration
- 🔄 Cluster autoscaling

### Phase 3: Application Infrastructure
- 🔄 RDS PostgreSQL with high availability
- 🔄 ElastiCache Redis cluster
- 🔄 S3 buckets for application storage
- 🔄 CloudWatch monitoring and alerting

### Phase 4: Security & Compliance
- 🔄 WAF integration
- 🔄 Config rules for compliance
- 🔄 GuardDuty threat detection
- 🔄 Secrets Manager integration

## 📚 Documentation References

- **Quick Start**: [README.md](./README.md)
- **GitHub Actions**: [GITHUB_ACTIONS_SETUP.md](./GITHUB_ACTIONS_SETUP.md)
- **Terraform Modules**: [terraform/CLAUDE.md](./terraform/CLAUDE.md)
- **VPC Configuration**: [terraform/vpc/CLAUDE.md](./terraform/vpc/CLAUDE.md)
- **CloudPosse Modules**: [CloudPosse Documentation](https://docs.cloudposse.com/)

## 🤝 Contributing Guidelines

### Code Standards
- **Terraform Formatting**: Use `terraform fmt` before committing
- **Variable Documentation**: Document all variables with descriptions
- **Output Documentation**: Provide clear output descriptions
- **Module Versioning**: Pin module versions for stability

### Review Process
- **Infrastructure Changes**: Require 2 approvals for production
- **Security Changes**: Security team review required
- **Cost Impact**: Include cost analysis for significant changes
- **Testing**: Validate in development before staging

### Emergency Procedures
- **Rollback**: Use Terraform state versioning for rollbacks
- **Access**: On-call engineers have emergency access
- **Communication**: Use #infrastructure channel for updates
- **Documentation**: Update runbooks after incidents
