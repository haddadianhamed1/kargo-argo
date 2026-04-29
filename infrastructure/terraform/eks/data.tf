# Data sources for cross-module integration and AWS resources

# VPC Remote State - Primary data source for network configuration
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.vpc_remote_state_bucket
    key    = "${var.vpc_remote_state_key_prefix}/${var.environment}/terraform.tfstate"
    region = var.aws_region
  }
}

# Availability Zones - For subnet distribution and node group placement
data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Current AWS caller identity - For account ID and ARN references
data "aws_caller_identity" "current" {}

# Current AWS region - For region-specific configurations
data "aws_region" "current" {}

# Default KMS key for EKS encryption
data "aws_kms_alias" "ebs" {
  name = "alias/aws/ebs"
}

# Latest EKS optimized AMI - For node group AMI references
data "aws_ami" "eks_worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.kubernetes_version}-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI account ID
}

# EKS Cluster Auth - For kubectl/helm provider configuration
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster.eks_cluster_id
}

# Note: VPC and subnet data comes from remote state - no additional AWS API calls needed

# Local values computed from data sources
locals {
  # Account and region information
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  # VPC configuration from remote state
  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  public_subnet_ids  = data.terraform_remote_state.vpc.outputs.public_subnet_ids
  vpc_cidr_block     = data.terraform_remote_state.vpc.outputs.vpc_cidr_block

  # Kubernetes cluster security group from VPC module
  vpc_kubernetes_security_group_id = data.terraform_remote_state.vpc.outputs.kubernetes_cluster_security_group_id

  # Generate cluster name using label module + region
  cluster_name = "${module.label.id}-${replace(var.aws_region, "-", "")}"

  # Node group subnet IDs (use private subnets for worker nodes)
  node_group_subnet_ids = local.private_subnet_ids

  # Common tags for all resources
  common_tags = merge(
    module.label.tags,
    {
      "kubernetes.io/cluster/${local.cluster_name}" = "owned"
      "Environment"                                 = var.environment
      "Project"                                     = var.project_name
      "ManagedBy"                                   = "terraform"
      "Owner"                                       = var.owner
      "AccountId"                                   = local.account_id
      "Region"                                      = local.region
    }
  )

  # Cross-module integration values
  integration_config = {
    # VPC configuration
    vpc = {
      id                 = local.vpc_id
      cidr_block         = local.vpc_cidr_block
      private_subnet_ids = local.private_subnet_ids
      public_subnet_ids  = local.public_subnet_ids
      security_group_id  = local.vpc_kubernetes_security_group_id
    }

    # EKS configuration
    eks = {
      cluster_name       = local.cluster_name
      kubernetes_version = var.kubernetes_version
      node_group_subnets = local.node_group_subnet_ids
      availability_zones = data.aws_availability_zones.available.names
    }

    # AWS account and region
    aws = {
      account_id = local.account_id
      region     = local.region
    }
  }
}
