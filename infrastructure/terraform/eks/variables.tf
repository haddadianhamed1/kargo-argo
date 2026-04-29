# AWS Configuration
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

# Label Module Variables
variable "namespace" {
  description = "Namespace for resource naming"
  type        = string
  default     = "kargo"
}

variable "environment" {
  description = "Environment name (e.g., dev, stg, prd)"
  type        = string
  validation {
    condition     = contains(["dev", "stg", "prd"], var.environment)
    error_message = "Environment must be dev, stg, or prd."
  }
}

variable "stage" {
  description = "Stage name (e.g., development, staging, production)"
  type        = string
  default     = ""
}

variable "name" {
  description = "Solution name"
  type        = string
  default     = "argocd"
}

variable "attributes" {
  description = "Additional attributes for resource naming"
  type        = list(string)
  default     = ["eks"]
}

variable "delimiter" {
  description = "Delimiter to be used between name segments"
  type        = string
  default     = "-"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Project Information
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "Kargo ArgoCD Development"
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "Platform Team"
}

# EKS Cluster Configuration
variable "kubernetes_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.28"
  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.kubernetes_version))
    error_message = "Kubernetes version must be in format X.Y (e.g., 1.28)."
  }
}

variable "cluster_endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_cluster_log_types" {
  description = "List of log types to enable for EKS cluster"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "cluster_log_retention_period" {
  description = "Number of days to retain cluster logs"
  type        = number
  default     = 7
}

# Node Group Configuration
variable "node_groups" {
  description = "Configuration for EKS managed node groups"
  type = map(object({
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
    ami_type       = string
    labels         = map(string)
  }))
  default = {}
}

# Add-ons Configuration
variable "cluster_addons" {
  description = "Map of cluster addon configurations to enable"
  type = map(object({
    addon_version               = string
    resolve_conflicts_on_create = string
    resolve_conflicts_on_update = string
    service_account_role_arn    = string
  }))
  default = {}
}

# Environment-specific Configuration
variable "environment_config" {
  description = "Environment-specific configuration"
  type = object({
    enable_irsa                         = optional(bool, true)
    enable_cluster_autoscaler           = optional(bool, true)
    enable_aws_load_balancer_controller = optional(bool, true)
    enable_external_dns                 = optional(bool, false)
    enable_cluster_encryption           = optional(bool, false)
  })
  default = {
    enable_irsa                         = true
    enable_cluster_autoscaler           = true
    enable_aws_load_balancer_controller = true
    enable_external_dns                 = false
    enable_cluster_encryption           = false
  }
}

# Remote State Configuration
variable "vpc_remote_state_bucket" {
  description = "S3 bucket containing VPC remote state"
  type        = string
  default     = "github-actions-kargo-argocd"
}

variable "vpc_remote_state_key_prefix" {
  description = "S3 key prefix for VPC remote state"
  type        = string
  default     = "terraform/vpc"
}
