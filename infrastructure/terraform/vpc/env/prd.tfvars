# Production Environment Configuration

# Environment Settings
environment = "prd"
stage       = "prd"

# AWS Configuration
aws_region = "us-east-1"

# Project Information
project_name = "Kargo ArgoCD Production"
owner        = "Platform Team"

# VPC Configuration
vpc_cidr = "10.30.0.0/16"

# Subnet Configuration - Multi-AZ for maximum high availability
public_subnet_count  = 3
private_subnet_count = 3
subnet_cidr_newbits  = 8

# Kubernetes Configuration
# kubernetes_cluster_name auto-generated: kargo-prd-argocd-vpc-useast1
enable_nat_gateway      = true
single_nat_gateway      = false  # Multiple NAT Gateways for HA

# Production-specific settings
environment_config = {
  instance_tenancy     = "default"
  enable_vpc_endpoints = true  # Enable for performance and reduced data transfer costs
}

# Additional tags for production
tags = {
  "CostCenter"       = "Platform"
  "AutoShutdown"     = "false"
  "Backup"           = "true"
  "Monitoring"       = "enhanced"
  "Environment"      = "prd"
  "TeamContact"      = "platform-team@company.com"
  "HighAvailability" = "true"
  "Compliance"       = "required"
  "DataClass"        = "confidential"
  "BusinessCritical" = "true"
}
