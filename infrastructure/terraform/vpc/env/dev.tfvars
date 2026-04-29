# Development Environment Configuration

# Environment Settings
environment = "dev"
stage       = "development"

# AWS Configuration
aws_region = "us-east-1"

# Project Information
project_name = "Kargo ArgoCD Development"
owner        = "Development Team"

# VPC Configuration
vpc_cidr = "10.10.0.0/16"

# Subnet Configuration - EKS requires at least 2 AZs
public_subnet_count  = 2
private_subnet_count = 2
subnet_cidr_newbits  = 8

# Kubernetes Configuration
kubernetes_cluster_name     = "kargo-dev-eks"  # Match actual EKS cluster name
enable_nat_gateway      = true
single_nat_gateway      = true

# Environment-specific settings
environment_config = {
  instance_tenancy     = "default"
  enable_vpc_endpoints = false  # Disable for cost savings in dev
}

# Additional tags for development
tags = {
  "CostCenter"    = "Development"
  "AutoShutdown"  = "true"
  "Backup"        = "false"
  "Monitoring"    = "basic"
  "Environment"   = "dev"
  "TeamContact"   = "dev-team@company.com"
}
