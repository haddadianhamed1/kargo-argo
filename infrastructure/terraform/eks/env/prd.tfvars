# Production Environment Configuration

# Environment Settings
environment = "prd"
stage       = "prd"

# AWS Configuration
aws_region = "us-east-1"

# Project Information
project_name = "Kargo ArgoCD Production"
owner        = "Platform Team"

# EKS Cluster Configuration
kubernetes_version = "1.28"

# Endpoint access configuration (secure for production)
cluster_endpoint_private_access      = true
cluster_endpoint_public_access       = true
cluster_endpoint_public_access_cidrs = ["24.130.139.84/32"]

# Logging configuration (comprehensive for production)
enabled_cluster_log_types    = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
cluster_log_retention_period = 30

# Production Node Groups - high availability and performance (SPOT for cost optimization)
node_groups = {
  general = {
    instance_types = ["m5.xlarge", "m5.large"]
    min_size      = 3
    max_size      = 10
    desired_size  = 5
    ami_type      = "AL2_x86_64"
    labels = {
      role = "general"
      environment = "prd"
    }
  }

  system = {
    instance_types = ["t3.large"]
    min_size      = 2
    max_size      = 4
    desired_size  = 2
    ami_type      = "AL2_x86_64"
    labels = {
      role = "system"
      environment = "prd"
    }
  }

  compute = {
    instance_types = ["c5.2xlarge", "c5.xlarge"]
    min_size      = 1
    max_size      = 8
    desired_size  = 2
    ami_type      = "AL2_x86_64"
    labels = {
      role = "compute"
      environment = "prd"
    }
  }
}

# Environment-specific feature configuration (all enabled for production)
environment_config = {
  enable_irsa                = true
  enable_cluster_autoscaler  = true
  enable_aws_load_balancer_controller = true
  enable_external_dns        = true
  enable_cluster_encryption  = true
}

# Production-specific tags
tags = {
  "CostCenter"       = "Platform"
  "AutoShutdown"     = "false"
  "Backup"           = "true"
  "Monitoring"       = "comprehensive"
  "Environment"      = "prd"
  "TeamContact"      = "platform-team@company.com"
  "HighAvailability" = "true"
  "BusinessCritical" = "true"
  "Compliance"       = "required"
  "DataClass"        = "confidential"
  "NodeType"         = "spot"
}
