# Label Outputs
output "label_id" {
  description = "The complete label ID"
  value       = module.label.id
}

output "label_namespace" {
  description = "Normalized namespace"
  value       = module.label.namespace
}

output "label_environment" {
  description = "Normalized environment"
  value       = module.label.environment
}

output "label_name" {
  description = "Normalized name"
  value       = module.label.name
}

output "label_tags" {
  description = "Normalized tags"
  value       = module.label.tags
}

# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.vpc.vpc_arn
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = module.vpc.vpc_default_security_group_id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.igw_id
}

# Public Subnet Outputs
output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = module.subnets.public_subnet_ids
}

output "public_subnet_cidrs" {
  description = "List of CIDR blocks of the public subnets"
  value       = module.subnets.public_subnet_cidrs
}

output "public_route_table_ids" {
  description = "List of IDs of the public route tables"
  value       = module.subnets.public_route_table_ids
}

# Private Subnet Outputs
output "private_subnet_ids" {
  description = "List of IDs of the private subnets"
  value       = module.subnets.private_subnet_ids
}

output "private_subnet_cidrs" {
  description = "List of CIDR blocks of the private subnets"
  value       = module.subnets.private_subnet_cidrs
}

output "private_route_table_ids" {
  description = "List of IDs of the private route tables"
  value       = module.subnets.private_route_table_ids
}

output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = module.subnets.nat_gateway_ids
}

output "nat_eip_ids" {
  description = "List of IDs of the NAT Gateway Elastic IPs"
  value       = module.subnets.nat_ips
}

# Security Group Outputs
output "kubernetes_cluster_security_group_id" {
  description = "ID of the Kubernetes cluster security group"
  value       = aws_security_group.kubernetes_cluster.id
}

output "kubernetes_cluster_security_group_arn" {
  description = "ARN of the Kubernetes cluster security group"
  value       = aws_security_group.kubernetes_cluster.arn
}

# Availability Zone Outputs
output "availability_zones" {
  description = "List of availability zones used"
  value       = slice(data.aws_availability_zones.available.names, 0, max(var.public_subnet_count, var.private_subnet_count))
}

# Common tags for reference
output "common_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}

# Kubernetes-specific outputs
output "kubernetes_tags" {
  description = "Tags specifically for Kubernetes integration"
  value = {
    cluster_tag         = "kubernetes.io/cluster/${local.cluster_name}"
    public_subnet_tags  = local.kubernetes_public_tags
    private_subnet_tags = local.kubernetes_private_tags
  }
}

# Summary output for easy reference
output "vpc_summary" {
  description = "Summary of the VPC configuration"
  value = {
    vpc_id                = module.vpc.vpc_id
    vpc_cidr              = module.vpc.vpc_cidr_block
    environment           = var.environment
    region                = var.aws_region
    public_subnets        = length(module.subnets.public_subnet_ids)
    private_subnets       = length(module.subnets.private_subnet_ids)
    availability_zones    = length(slice(data.aws_availability_zones.available.names, 0, max(var.public_subnet_count, var.private_subnet_count)))
    vpc_endpoints_enabled = var.environment_config.enable_vpc_endpoints
  }
}

# EKS-specific outputs for Kubernetes module consumption
output "eks_cluster_config" {
  description = "Configuration values needed for EKS cluster deployment"
  value = {
    vpc_id                    = module.vpc.vpc_id
    private_subnet_ids        = module.subnets.private_subnet_ids
    public_subnet_ids         = module.subnets.public_subnet_ids
    cluster_security_group_id = aws_security_group.kubernetes_cluster.id
    cluster_name              = local.cluster_name
    cluster_endpoint_access = {
      private_access = true
      public_access  = true
      public_cidrs   = ["0.0.0.0/0"]
    }
  }
}

# Remote state data source for cross-module consumption
# This output enables other modules to reference this VPC infrastructure
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
