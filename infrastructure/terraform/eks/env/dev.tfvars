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
kubernetes_version = "1.28"

# Endpoint access configuration (more open for development)
cluster_endpoint_private_access      = true
cluster_endpoint_public_access       = true
cluster_endpoint_public_access_cidrs = ["24.130.139.84/32"]

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
    ami_type      = "AL2_x86_64"
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
