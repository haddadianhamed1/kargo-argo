# Staging Environment Configuration

# Environment Settings
environment = "stg"
stage       = "stg"

# AWS Configuration
aws_region = "us-east-1"

# Project Information
project_name = "Kargo ArgoCD Staging"
owner        = "Platform Team"

# EKS Cluster Configuration
kubernetes_version = "1.34"

# Endpoint access configuration (production-like)
cluster_endpoint_private_access      = true
cluster_endpoint_public_access       = true
cluster_endpoint_public_access_cidrs = ["24.130.139.84/32"]

# Logging configuration (enhanced for testing)
enabled_cluster_log_types    = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
cluster_log_retention_period = 7

# Staging Node Groups - production-like with HA (SPOT for cost optimization)
node_groups = {
  general = {
    instance_types = ["t3.large"]
    min_size      = 2
    max_size      = 6
    desired_size  = 3
    ami_type      = "BOTTLEROCKET_x86_64"
    labels = {
      role = "general"
      environment = "stg"
    }
  }

  system = {
    instance_types = ["t3.medium"]
    min_size      = 1
    max_size      = 2
    desired_size  = 1
    ami_type      = "BOTTLEROCKET_x86_64"
    labels = {
      role = "system"
      environment = "stg"
    }
  }
}

# Environment-specific feature configuration
environment_config = {
  enable_irsa                = true
  enable_cluster_autoscaler  = true
  enable_aws_load_balancer_controller = true
  enable_external_dns        = true
  enable_cluster_encryption  = true
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
  "NodeType"         = "spot"
}
