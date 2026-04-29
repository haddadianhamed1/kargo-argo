# Kargo ArgoCD Infrastructure

This directory contains Terraform configurations for deploying AWS infrastructure for the Kargo ArgoCD project using CloudPosse modules.

## 📁 Directory Structure

```
infrastructure/
├── terraform/
│   └── vpc/                    # VPC infrastructure
│       ├── env/               # Environment-specific configurations
│       │   ├── dev.tfvars    # Development environment
│       │   └── stg.tfvars    # Staging environment
│       ├── main.tf            # Main VPC configuration
│       ├── variables.tf       # Input variables
│       ├── outputs.tf         # Output values
│       └── versions.tf        # Provider versions
└── README.md                 # This file
```

## 🏗️ Infrastructure Components

### VPC Architecture
- **CloudPosse VPC Module** - Production-ready VPC configuration
- **CloudPosse Label Module** - Consistent resource naming
- **Public Subnets** - For load balancers and NAT gateways
- **Private Subnets** - For Kubernetes nodes and application workloads
- **Internet Gateway** - Public internet access
- **NAT Gateway(s)** - Outbound internet access for private subnets
- **Security Groups** - Kubernetes-ready network security

### Kubernetes Integration
- **Kubernetes Tags** - Proper subnet tagging for EKS/K8s integration
- **Security Groups** - Pre-configured for Kubernetes communication
- **Multi-AZ Support** - High availability across availability zones

## 🚀 Quick Start

### Prerequisites
- [Terraform](https://www.terraform.io/downloads.html) >= 1.5
- [AWS CLI](https://aws.amazon.com/cli/) configured
- Appropriate AWS permissions for VPC, subnet, and security group creation

### Deployment Options

#### Option 1: GitHub Actions (Recommended)

**Progressive deployment with GitHub Environments:**

🔄 **Deployment Flow**: Dev (auto) → Staging (approval) → Production (approval)

1. **Setup GitHub Environments** (see `.github/ENVIRONMENTS.md`)
   - Configure approval rules for staging/production
   - Add reviewers and protection settings

2. **Add GitHub Secrets**: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

3. **Automatic deployment**:
   ```bash
   git push origin main  # Auto-deploys to dev, awaits approval for staging/prod
   ```

4. **Manual deployment**: Use GitHub Actions → "Run workflow"

**Benefits**: Progressive deployment, approval gates, audit trail, single branch strategy

#### Option 2: Local Deployment

**For development and testing:**

### 1. Initialize Terraform
```bash
terraform init \
  -backend-config="bucket=github-actions-kargo-argocd" \
  -backend-config="key=terraform/vpc/dev/terraform.tfstate" \
  -backend-config="region=us-east-1"
```

### 2. Plan Infrastructure (Development)
```bash
terraform plan -var-file="env/dev.tfvars"
```

### 3. Apply Infrastructure (Development)
```bash
terraform apply -var-file="env/dev.tfvars"
```

### 4. Deploy to Staging
```bash
# Re-initialize with staging state
terraform init -reconfigure \
  -backend-config="key=terraform/vpc/stg/terraform.tfstate"

terraform plan -var-file="env/stg.tfvars"
terraform apply -var-file="env/stg.tfvars"
```

## 🌍 Environment Configurations

### Development (`dev.tfvars`)
- **VPC CIDR**: `10.10.0.0/16`
- **Subnets**: 1 public, 1 private
- **NAT Gateway**: Single (cost-optimized)
- **VPC Endpoints**: Disabled (cost-optimized)
- **Auto-shutdown**: Enabled
- **Deployment**: Automatic on push to main

### Staging (`stg.tfvars`)
- **VPC CIDR**: `10.20.0.0/16`
- **Subnets**: 2 public, 2 private (Multi-AZ)
- **NAT Gateway**: Multiple (high availability)
- **VPC Endpoints**: Enabled
- **Deployment**: Manual approval required (1-2 reviewers)

### Production (`prd.tfvars`)
- **VPC CIDR**: `10.30.0.0/16`
- **Subnets**: 3 public, 3 private (Full Multi-AZ)
- **NAT Gateway**: Multiple (maximum high availability)
- **VPC Endpoints**: Enabled (cost optimization)
- **Deployment**: Manual approval required (2-3 reviewers)

## 📊 Key Outputs

After deployment, you'll get important infrastructure information:

```hcl
# VPC Information
vpc_id                 = "vpc-xxxxxxxxx"
vpc_cidr_block         = "10.10.0.0/16"

# Subnet Information
public_subnet_ids      = ["subnet-xxxxxxxxx"]
private_subnet_ids     = ["subnet-yyyyyyyyy"]

# Kubernetes Integration
kubernetes_cluster_security_group_id = "sg-zzzzzzzzz"
```

## 🏷️ Resource Naming Convention

Using CloudPosse Label module for consistent naming:

```
Pattern: {namespace}-{environment}-{name}-{attributes}
Example: kargo-dev-argocd-vpc
```

### Tags Applied
- **Environment**: dev/staging/prod
- **Project**: Kargo ArgoCD
- **ManagedBy**: terraform
- **Kubernetes Integration**: `kubernetes.io/cluster/cluster-name`

## 🔐 Security Features

### Network Security
- **Private Subnets** - Kubernetes nodes isolated from internet
- **Security Groups** - Kubernetes-specific rules pre-configured
- **NAT Gateway** - Secure outbound internet access

### Kubernetes-Ready Tags
```hcl
Public Subnets:  "kubernetes.io/role/elb" = "1"
Private Subnets: "kubernetes.io/role/internal-elb" = "1"
Cluster Tag:     "kubernetes.io/cluster/{cluster-name}" = "shared"
```

## 🔧 Customization

### Adding New Environments
1. Create new `.tfvars` file in `env/`
2. Customize VPC CIDR, subnet counts, and tags
3. Deploy: `terraform apply -var-file="env/new-env.tfvars"`

### Modifying Subnet Configuration
```hcl
# In your .tfvars file
public_subnet_count  = 3    # Number of public subnets
private_subnet_count = 3    # Number of private subnets
vpc_cidr            = "10.30.0.0/16"  # Custom CIDR range
```

## 📝 Best Practices

1. **State Management**: Configure S3 backend for production
2. **Environment Isolation**: Use separate state files per environment
3. **Cost Optimization**: Adjust NAT Gateway settings per environment
4. **Monitoring**: Enable VPC Flow Logs for staging/production
5. **Tags**: Maintain consistent tagging for cost tracking

## 🚀 Next Steps

After VPC deployment:
1. **EKS Cluster** - Deploy Kubernetes cluster in private subnets
2. **Application Load Balancer** - Deploy in public subnets
3. **RDS Databases** - Deploy in private subnets with dedicated subnet groups
4. **Monitoring** - CloudWatch, VPC Flow Logs

## 📚 CloudPosse Module References

- [VPC Module](https://github.com/cloudposse/terraform-aws-vpc)
- [Dynamic Subnets Module](https://github.com/cloudposse/terraform-aws-dynamic-subnets)
- [Label Module](https://github.com/cloudposse/terraform-null-label)

## 🤝 Contributing

1. Follow naming conventions using the label module
2. Test changes in development environment first
3. Update documentation for any configuration changes
4. Ensure all resources have appropriate tags
