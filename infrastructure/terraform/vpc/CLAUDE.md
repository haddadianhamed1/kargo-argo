# VPC Module Documentation

This module creates AWS VPC networking infrastructure optimized for Kubernetes workloads using CloudPosse modules.

## 🌐 Network Architecture

**VPC Design:**
- **Multi-AZ Deployment**: High availability across availability zones
- **Public/Private Subnets**: Separated network tiers for security
- **Kubernetes-Ready**: Pre-configured tags and security groups
- **Environment-Specific**: Customized per dev/stg/prd requirements

## 📋 Module Overview

### Resources Created
```
VPC Infrastructure:
├── VPC (10.x.0.0/16)
├── Internet Gateway
├── Public Subnets (1-6 per environment)
├── Private Subnets (1-6 per environment)
├── NAT Gateways (1 or per-AZ)
├── Route Tables (public/private)
├── Security Groups (Kubernetes cluster)
└── VPC Endpoints (optional)
```

### CloudPosse Modules Used
- **`cloudposse/vpc/aws`**: Core VPC infrastructure
- **`cloudposse/dynamic-subnets/aws`**: Public/private subnets
- **`cloudposse/label/null`**: Consistent resource naming

## 🔧 Configuration Reference

### Core Variables

#### Required Variables
```hcl
variable "environment" {
  description = "Environment name (dev, stg, prd)"
  type        = string
  validation {
    condition     = contains(["dev", "stg", "prd"], var.environment)
    error_message = "Environment must be dev, stg, or prd."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
```

#### Network Configuration
```hcl
variable "public_subnet_count" {
  description = "Number of public subnets to create"
  type        = number
  default     = 1
  validation {
    condition     = var.public_subnet_count >= 1 && var.public_subnet_count <= 6
    error_message = "Public subnet count must be between 1 and 6."
  }
}

variable "private_subnet_count" {
  description = "Number of private subnets to create"
  type        = number
  default     = 1
  validation {
    condition     = var.private_subnet_count >= 1 && var.private_subnet_count <= 6
    error_message = "Private subnet count must be between 1 and 6."
  }
}
```

#### Feature Configuration
```hcl
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets"
  type        = bool
  default     = true
}

variable "environment_config" {
  description = "Environment-specific configuration"
  type = object({
    instance_tenancy     = optional(string, "default")
    enable_vpc_endpoints = optional(bool, false)
  })
}
```

### Environment Configurations

#### Development (dev.tfvars)
```hcl
# Cost-optimized configuration
environment = "dev"
stage       = "development"
vpc_cidr    = "10.10.0.0/16"

# Minimal subnet configuration
public_subnet_count  = 1
private_subnet_count = 1
subnet_cidr_newbits  = 8

# Single NAT Gateway for cost savings
enable_nat_gateway = true
single_nat_gateway = true

# Disable expensive features in dev
environment_config = {
  instance_tenancy     = "default"
  enable_vpc_endpoints = false
}

# Development-specific tags
tags = {
  "CostCenter"    = "Development"
  "AutoShutdown"  = "true"
  "Backup"        = "false"
  "Monitoring"    = "basic"
  "Environment"   = "dev"
  "TeamContact"   = "dev-team@company.com"
}
```

#### Staging (stg.tfvars)
```hcl
# Production-like configuration
environment = "stg"
stage       = "stg"
vpc_cidr    = "10.20.0.0/16"

# Multi-AZ for high availability testing
public_subnet_count  = 2
private_subnet_count = 2
subnet_cidr_newbits  = 8

# Multiple NAT Gateways for HA
enable_nat_gateway = true
single_nat_gateway = false

# Enable production features
environment_config = {
  instance_tenancy     = "default"
  enable_vpc_endpoints = true
}

# Staging-specific tags
tags = {
  "CostCenter"       = "Platform"
  "AutoShutdown"     = "false"
  "Backup"           = "true"
  "Monitoring"       = "enhanced"
  "Environment"      = "stg"
  "TeamContact"      = "platform-team@company.com"
  "HighAvailability" = "true"
}
```

## 🏷️ Resource Naming

### Label Module Integration
```hcl
module "label" {
  source  = "cloudposse/label/null"
  version = "~> 0.25"

  namespace   = "kargo"           # Project identifier
  environment = var.environment   # dev/stg/prd
  stage       = var.stage        # development/staging/production
  name        = "argocd"         # Service name
  attributes  = ["vpc"]          # Resource type
  delimiter   = "-"             # Separator

  tags = var.tags
}

# Generated names:
# - VPC: kargo-dev-argocd-vpc
# - Subnets: kargo-dev-argocd-vpc-public, kargo-dev-argocd-vpc-private
# - Security Group: kargo-dev-argocd-vpc-k8s-cluster-sg
```

### Dynamic Cluster Naming
```hcl
locals {
  # Generate cluster name with region
  cluster_name = var.kubernetes_cluster_name != "" ?
    var.kubernetes_cluster_name :
    "${module.label.id}-${replace(var.aws_region, "-", "")}"
}

# Results:
# - Dev: kargo-dev-argocd-vpc-useast1
# - Staging: kargo-stg-argocd-vpc-useast1
```

## 🔐 Security Configuration

### Kubernetes Security Group
```hcl
resource "aws_security_group" "kubernetes_cluster" {
  name_prefix = "${module.label.id}-k8s-cluster-"
  vpc_id      = module.vpc.vpc_id

  # Kubernetes API server (6443)
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Kubernetes API server"
  }

  # Kubelet API (10250)
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Kubelet API"
  }

  # NodePort Services (30000-32767)
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "NodePort Services"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }
}
```

### Kubernetes Subnet Tags
```hcl
locals {
  # Public subnet tags for load balancers
  kubernetes_public_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  # Private subnet tags for internal load balancers
  kubernetes_private_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  # Common cluster tag for all resources
  cluster_tag = "kubernetes.io/cluster/${local.cluster_name}"
}
```

## 🌍 Network Topology

### CIDR Allocation Strategy
```
Development (10.10.0.0/16):
├── Public Subnet:  10.10.0.0/24   (256 IPs)
└── Private Subnet: 10.10.1.0/24   (256 IPs)

Staging (10.20.0.0/16):
├── Public Subnet 1:  10.20.0.0/24   (256 IPs, us-east-1a)
├── Public Subnet 2:  10.20.1.0/24   (256 IPs, us-east-1b)
├── Private Subnet 1: 10.20.2.0/24   (256 IPs, us-east-1a)
└── Private Subnet 2: 10.20.3.0/24   (256 IPs, us-east-1b)

Production (10.30.0.0/16) - Future:
├── Public Subnets:   10.30.0.0/22   (1024 IPs, 3 AZs)
├── Private Subnets:  10.30.4.0/22   (1024 IPs, 3 AZs)
└── Database Subnets: 10.30.8.0/22   (1024 IPs, 3 AZs)
```

### Routing Configuration
```
Public Subnets:
├── Route Table: public-rt
├── Default Route: 0.0.0.0/0 → Internet Gateway
└── Local Route: 10.x.0.0/16 → VPC

Private Subnets:
├── Route Table: private-rt (per AZ)
├── Default Route: 0.0.0.0/0 → NAT Gateway
├── Local Route: 10.x.0.0/16 → VPC
└── VPC Endpoint Routes: aws.service → VPC Endpoint
```

## 📤 Module Outputs

### VPC Information
```hcl
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.igw_id
}
```

### Subnet Information
```hcl
output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = module.public_subnets.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of IDs of the private subnets"
  value       = module.private_subnets.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = module.private_subnets.nat_gateway_ids
}
```

### Kubernetes Integration
```hcl
output "kubernetes_cluster_security_group_id" {
  description = "ID of the Kubernetes cluster security group"
  value       = aws_security_group.kubernetes_cluster.id
}

output "eks_cluster_config" {
  description = "Configuration values needed for EKS cluster deployment"
  value = {
    vpc_id                     = module.vpc.vpc_id
    private_subnet_ids         = module.private_subnets.private_subnet_ids
    public_subnet_ids          = module.public_subnets.public_subnet_ids
    cluster_security_group_id  = aws_security_group.kubernetes_cluster.id
    cluster_name               = local.cluster_name
    cluster_endpoint_access    = {
      private_access = true
      public_access  = true
      public_cidrs   = ["0.0.0.0/0"]
    }
  }
}
```

### Cross-Module References
```hcl
output "remote_state_key" {
  description = "S3 key for remote state - use this in data.terraform_remote_state"
  value       = "terraform/vpc/${var.environment}/terraform.tfstate"
}

output "remote_state_config" {
  description = "Complete remote state configuration for other modules"
  value = {
    backend = "s3"
    config = {
      bucket = "github-actions-kargo-argocd"
      key    = "terraform/vpc/${var.environment}/terraform.tfstate"
      region = var.aws_region
    }
  }
}
```

## 🔄 Usage Patterns

### Local Development
```bash
# Initialize with environment-specific backend
terraform init \
  -backend-config="bucket=github-actions-kargo-argocd" \
  -backend-config="key=terraform/vpc/dev/terraform.tfstate" \
  -backend-config="region=us-east-1"

# Plan for development environment
terraform plan -var-file="env/dev.tfvars"

# Apply development changes
terraform apply -var-file="env/dev.tfvars"

# Switch to staging environment
terraform init -reconfigure \
  -backend-config="key=terraform/vpc/stg/terraform.tfstate"

terraform plan -var-file="env/stg.tfvars"
```

### Cross-Module Integration
```hcl
# In EKS module - reference VPC outputs
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "github-actions-kargo-argocd"
    key    = "terraform/vpc/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}

resource "aws_eks_cluster" "main" {
  name     = data.terraform_remote_state.vpc.outputs.eks_cluster_config.cluster_name
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = data.terraform_remote_state.vpc.outputs.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
    security_group_ids      = [data.terraform_remote_state.vpc.outputs.kubernetes_cluster_security_group_id]
  }
}
```

## 🔍 Troubleshooting

### Common Issues

#### Subnet CIDR Conflicts
```bash
# Error: CIDR blocks overlap
# Solution: Adjust subnet_cidr_newbits or use different VPC CIDRs

# Development: 10.10.0.0/16
# Staging:     10.20.0.0/16
# Production:  10.30.0.0/16
```

#### NAT Gateway Costs
```bash
# High NAT Gateway charges
# Dev: Use single_nat_gateway = true
# Staging: Use single_nat_gateway = false for HA testing
# Production: Use single_nat_gateway = false for HA

# Alternative: Use VPC endpoints to reduce NAT Gateway traffic
environment_config = {
  enable_vpc_endpoints = true  # Reduces data transfer costs
}
```

#### Security Group Rules
```bash
# EKS cluster communication issues
# Ensure security group allows:
# - Port 6443 for API server
# - Port 10250 for kubelet
# - All traffic between cluster nodes
```

### Validation Commands
```bash
# Validate Terraform configuration
terraform validate

# Check subnet allocation
terraform plan -var-file="env/dev.tfvars" | grep "cidr_block"

# Verify security group rules
aws ec2 describe-security-groups \
  --group-names "kargo-dev-argocd-vpc-k8s-cluster-*"
```

## 📊 Cost Optimization

### Development Environment
- **Single NAT Gateway**: ~$45/month instead of ~$90/month (per AZ)
- **No VPC Endpoints**: Save ~$7/endpoint/month
- **Single AZ**: Reduced data transfer costs
- **Auto-shutdown tags**: Enable automated resource cleanup

### Staging Environment
- **Multiple NAT Gateways**: Required for HA testing
- **VPC Endpoints**: Reduce NAT Gateway data transfer charges
- **Multi-AZ**: Production-like testing environment

### Cost Monitoring
```hcl
# Tags for cost tracking
tags = {
  "Project"     = "KargoArgoCD"
  "Environment" = var.environment
  "CostCenter"  = "Platform"
  "Team"        = "DevOps"
}

# Use AWS Cost Explorer filters:
# - Service: Amazon VPC
# - Tag: Environment = dev
# - Tag: Project = KargoArgoCD
```

## 🚀 Future Enhancements

### IPv6 Support
```hcl
variable "enable_ipv6" {
  description = "Enable IPv6 support"
  type        = bool
  default     = false
}

# In VPC module
assign_generated_ipv6_cidr_block = var.enable_ipv6
```

### Transit Gateway Integration
```hcl
# For multi-VPC connectivity
resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  count              = var.enable_transit_gateway ? 1 : 0
  subnet_ids         = module.private_subnets.private_subnet_ids
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = module.vpc.vpc_id
}
```

### Network ACLs
```hcl
# Additional security layer
resource "aws_network_acl" "private" {
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.private_subnets.private_subnet_ids

  # Kubernetes cluster communication
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 65535
  }
}
```

## 📚 Reference Documentation

- **CloudPosse VPC Module**: [terraform-aws-vpc](https://github.com/cloudposse/terraform-aws-vpc)
- **CloudPosse Dynamic Subnets**: [terraform-aws-dynamic-subnets](https://github.com/cloudposse/terraform-aws-dynamic-subnets)
- **CloudPosse Label Module**: [terraform-null-label](https://github.com/cloudposse/terraform-null-label)
- **AWS VPC Guide**: [Amazon VPC User Guide](https://docs.aws.amazon.com/vpc/latest/userguide/)
- **Kubernetes Networking**: [EKS Network Requirements](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html)
