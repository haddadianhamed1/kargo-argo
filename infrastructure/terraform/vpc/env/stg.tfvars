# Staging Environment Configuration

# Environment Settings
environment = "stg"
stage       = "stg"

# AWS Configuration
aws_region = "us-east-1"

# Project Information
project_name = "Kargo ArgoCD Staging"
owner        = "Platform Team"

# VPC Configuration
vpc_cidr = "10.20.0.0/16"

# Subnet Configuration - Multi-AZ for high availability
public_subnet_count  = 2
private_subnet_count = 2
subnet_cidr_newbits  = 8

# Kubernetes Configuration
# kubernetes_cluster_name auto-generated: kargo-stg-argocd-vpc-useast1
enable_nat_gateway      = true
single_nat_gateway      = false  # Multiple NAT Gateways for HA

# Environment-specific settings
environment_config = {
  instance_tenancy     = "default"
  enable_vpc_endpoints = true  # Enable for better performance
}

# Additional tags for staging
tags = {
  "CostCenter"     = "Platform"
  "AutoShutdown"   = "false"
  "Backup"         = "true"
  "Monitoring"     = "enhanced"
  "Environment"    = "stg"
  "TeamContact"    = "platform-team@company.com"
  "HighAvailability" = "true"
}
