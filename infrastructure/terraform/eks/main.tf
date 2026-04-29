# Configure the AWS Provider
# Ready to deploy EKS cluster infrastructure v1
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.provider_tags
  }
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = module.eks_cluster.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.eks_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks_cluster.eks_cluster_id]
  }
}

# Configure Helm provider
provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_cluster.eks_cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks_cluster.eks_cluster_id]
    }
  }
}

# CloudPosse Label Module for consistent naming
module "label" {
  source  = "cloudposse/label/null"
  version = "~> 0.25"

  namespace   = var.namespace
  environment = var.environment
  stage       = var.stage
  name        = var.name
  attributes  = var.attributes
  delimiter   = var.delimiter

  tags = var.tags
}

# Main configuration now uses locals from data.tf for all data sources and computed values

# CloudPosse EKS Cluster Module
module "eks_cluster" {
  source  = "cloudposse/eks-cluster/aws"
  version = "~> 2.0"

  namespace   = module.label.namespace
  environment = module.label.environment
  stage       = module.label.stage
  name        = module.label.name
  attributes  = module.label.attributes
  delimiter   = module.label.delimiter

  # Cluster configuration
  region             = var.aws_region
  vpc_id             = local.vpc_id
  subnet_ids         = concat(local.private_subnet_ids, local.public_subnet_ids)
  kubernetes_version = var.kubernetes_version
  # Endpoint configuration
  endpoint_private_access = var.cluster_endpoint_private_access
  endpoint_public_access  = var.cluster_endpoint_public_access
  public_access_cidrs     = local.dynamic_public_access_cidrs

  # Logging configuration
  enabled_cluster_log_types    = var.enabled_cluster_log_types
  cluster_log_retention_period = var.cluster_log_retention_period

  # Security configuration
  cluster_encryption_config_enabled = var.environment_config.enable_cluster_encryption

  # OIDC configuration for IRSA
  oidc_provider_enabled = var.environment_config.enable_irsa

  # Disable cluster wait check for GitHub Actions compatibility
  wait_for_cluster_command = "echo 'Skipping cluster wait check'"

  tags = local.common_tags
}

# CloudPosse EKS Node Group Module
module "eks_node_groups" {
  source  = "cloudposse/eks-node-group/aws"
  version = "3.2.0"

  # Create one iteration for each node group defined in variables
  for_each = var.node_groups

  namespace   = module.label.namespace
  environment = module.label.environment
  stage       = module.label.stage
  name        = "${module.label.name}-${each.key}"
  attributes  = module.label.attributes
  delimiter   = module.label.delimiter

  # Cluster configuration
  cluster_name       = module.eks_cluster.eks_cluster_id
  subnet_ids         = local.node_group_subnet_ids
  kubernetes_version = null # Let node group inherit from cluster

  # Node group configuration
  instance_types = each.value.instance_types
  min_size       = each.value.min_size
  max_size       = each.value.max_size
  desired_size   = each.value.desired_size

  # AMI configuration
  ami_type = each.value.ami_type

  # Labels
  kubernetes_labels = merge(each.value.labels, {
    "cluster.k8s.amazonaws.com/name" = module.eks_cluster.eks_cluster_id
  })

  tags = merge(local.common_tags, {
    "NodeGroup" = each.key
  })

  depends_on = [module.eks_cluster]
}

# AWS Load Balancer Controller IAM Role (IRSA)
module "aws_load_balancer_controller_irsa_role" {
  count = var.environment_config.enable_aws_load_balancer_controller ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${local.cluster_name}-aws-load-balancer-controller"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }

  tags = local.common_tags
}

# Cluster Autoscaler IAM Role (IRSA)
module "cluster_autoscaler_irsa_role" {
  count = var.environment_config.enable_cluster_autoscaler ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${local.cluster_name}-cluster-autoscaler"

  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [module.eks_cluster.eks_cluster_id]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }

  tags = local.common_tags
}

# External DNS IAM Role (IRSA) - Optional
module "external_dns_irsa_role" {
  count = var.environment_config.enable_external_dns ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${local.cluster_name}-external-dns"

  attach_external_dns_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks_cluster.eks_cluster_identity_oidc_issuer_arn
      namespace_service_accounts = ["external-dns:external-dns"]
    }
  }

  tags = local.common_tags
}

# Security group for additional EKS worker node access
resource "aws_security_group" "eks_workers_additional" {
  name_prefix = "${module.label.id}-eks-workers-additional-"
  vpc_id      = local.vpc_id

  # Allow communication between worker nodes
  ingress {
    description = "Worker node communication"
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  # Allow communication from control plane
  ingress {
    description = "Control plane communication"
    from_port   = 1025
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_block]
  }

  # HTTPS for webhook communication
  ingress {
    description = "HTTPS webhook communication"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.vpc_cidr_block]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(local.common_tags, {
    Name = "${module.label.id}-eks-workers-additional-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}
