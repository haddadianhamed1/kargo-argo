# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
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

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# Local values for common tags and configuration
locals {
  # Generate cluster name using label module + region
  cluster_name = var.kubernetes_cluster_name != "" ? var.kubernetes_cluster_name : "${module.label.id}-${replace(var.aws_region, "-", "")}"

  # Common tags for all resources
  common_tags = merge(
    module.label.tags,
    {
      "kubernetes.io/cluster/${local.cluster_name}" = "shared"
      "Environment"                                 = var.environment
      "Project"                                     = var.project_name
      "ManagedBy"                                   = "terraform"
      "Owner"                                       = var.owner
    }
  )

  # Kubernetes-specific tags for subnets
  kubernetes_public_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  kubernetes_private_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# CloudPosse VPC Module
module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "~> 2.0"

  namespace   = module.label.namespace
  environment = module.label.environment
  stage       = module.label.stage
  name        = module.label.name
  attributes  = module.label.attributes
  delimiter   = module.label.delimiter

  ipv4_primary_cidr_block          = var.vpc_cidr
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  # DNS settings
  dns_hostnames_enabled = true
  dns_support_enabled   = true
}

# CloudPosse Public Subnets Module
module "public_subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "~> 2.0"

  namespace   = module.label.namespace
  environment = module.label.environment
  stage       = module.label.stage
  name        = "${module.label.name}-public"
  attributes  = module.label.attributes
  delimiter   = module.label.delimiter

  vpc_id             = module.vpc.vpc_id
  igw_id             = [module.vpc.igw_id]
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.public_subnet_count)

  # Public subnet configuration
  public_subnets_enabled  = true
  private_subnets_enabled = false
  nat_gateway_enabled     = false
  nat_instance_enabled    = false

  tags = merge(
    local.common_tags,
    local.kubernetes_public_tags,
    {
      "SubnetType" = "public"
    }
  )
}

# CloudPosse Private Subnets Module
module "private_subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "~> 2.0"

  namespace   = module.label.namespace
  environment = module.label.environment
  stage       = module.label.stage
  name        = "${module.label.name}-private"
  attributes  = module.label.attributes
  delimiter   = module.label.delimiter

  vpc_id             = module.vpc.vpc_id
  igw_id             = [module.vpc.igw_id]
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.private_subnet_count)

  # Private subnet configuration
  public_subnets_enabled  = false
  private_subnets_enabled = true
  nat_gateway_enabled     = var.enable_nat_gateway
  nat_instance_enabled    = false

  tags = merge(
    local.common_tags,
    local.kubernetes_private_tags,
    {
      "SubnetType" = "private"
    }
  )
}

# Security Group for Kubernetes cluster
resource "aws_security_group" "kubernetes_cluster" {
  name_prefix = "${module.label.id}-k8s-cluster-"
  vpc_id      = module.vpc.vpc_id

  # Kubernetes API server
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Kubernetes API server"
  }

  # Node communication
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Kubelet API"
  }

  # NodePort Services
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "NodePort Services"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${module.label.id}-k8s-cluster-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# VPC Endpoints (conditional based on environment_config)
resource "aws_vpc_endpoint" "s3" {
  count = var.environment_config.enable_vpc_endpoints ? 1 : 0

  vpc_id       = module.vpc.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  tags = merge(
    local.common_tags,
    {
      Name = "${module.label.id}-s3-endpoint"
    }
  )
}

resource "aws_vpc_endpoint" "ec2" {
  count = var.environment_config.enable_vpc_endpoints ? 1 : 0

  vpc_id             = module.vpc.vpc_id
  service_name       = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = module.private_subnets.private_subnet_ids
  security_group_ids = [aws_security_group.kubernetes_cluster.id]

  tags = merge(
    local.common_tags,
    {
      Name = "${module.label.id}-ec2-endpoint"
    }
  )
}
