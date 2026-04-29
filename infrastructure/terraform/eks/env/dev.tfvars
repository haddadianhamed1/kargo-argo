# Development Environment Configuration

# Environment Settings
environment = "dev"
stage       = "dev"

# AWS Configuration
aws_region = "us-east-1"

# Project Information
project_name = "Kargo ArgoCD Development"
owner        = "Platform Team"

# EKS Cluster Configuration
kubernetes_version = "1.34"

# Endpoint access configuration (more open for development)
cluster_endpoint_private_access      = true
cluster_endpoint_public_access       = true
cluster_endpoint_public_access_cidrs = [
  "24.130.139.84/32",    # User access
  "4.0.0.0/8",           # GitHub Actions core range
  "13.64.0.0/12",        # GitHub Actions Azure East US ranges
  "20.0.0.0/8",          # GitHub Actions Azure core ranges
  "40.64.0.0/10",        # GitHub Actions Azure West ranges
  "52.224.0.0/11"        # GitHub Actions Azure Central ranges
]

# Logging configuration (basic for cost optimization)
enabled_cluster_log_types    = ["api", "audit"]
cluster_log_retention_period = 3

# Development Node Groups - cost-optimized
node_groups = {
  general = {
    instance_types = ["t3.medium"]
    min_size      = 1
    max_size      = 3
    desired_size  = 2
    ami_type      = "BOTTLEROCKET_x86_64"
    labels = {
      role = "general"
      environment = "dev"
    }
  }
}

# Environment-specific feature configuration
environment_config = {
  enable_irsa                = true
  enable_cluster_autoscaler  = true
  enable_aws_load_balancer_controller = true
  enable_external_dns        = false
  enable_cluster_encryption  = false
}

# Development-specific tags
tags = {
  "CostCenter"    = "Development"
  "AutoShutdown"  = "true"
  "Backup"        = "false"
  "Monitoring"    = "basic"
  "Environment"   = "dev"
  "TeamContact"   = "dev-team@company.com"
  "NodeType"      = "spot"
}
