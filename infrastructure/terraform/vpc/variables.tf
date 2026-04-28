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
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "stage" {
  description = "Stage name (e.g., dev, staging, prod)"
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
  default     = ["vpc"]
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
  default     = "Kargo ArgoCD"
}

variable "owner" {
  description = "Owner of the infrastructure"
  type        = string
  default     = "DevOps Team"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_ipv6" {
  description = "Enable IPv6 support"
  type        = bool
  default     = false
}

# Subnet Configuration
variable "public_subnet_count" {
  description = "Number of public subnets to create"
  type        = number
  default     = 1

  validation {
    condition     = var.public_subnet_count >= 1 && var.public_subnet_count <= 6
    error_message = "Public subnet count must be between 1 and 6."
  }
}

variable "private_subnet_count" {
  description = "Number of private subnets to create"
  type        = number
  default     = 1

  validation {
    condition     = var.private_subnet_count >= 1 && var.private_subnet_count <= 6
    error_message = "Private subnet count must be between 1 and 6."
  }
}

variable "subnet_cidr_newbits" {
  description = "Number of additional bits to extend the VPC CIDR for subnets"
  type        = number
  default     = 8

  validation {
    condition     = var.subnet_cidr_newbits >= 4 && var.subnet_cidr_newbits <= 16
    error_message = "Subnet CIDR newbits must be between 4 and 16."
  }
}

# Kubernetes Configuration
variable "kubernetes_cluster_name" {
  description = "Name of the Kubernetes cluster (auto-generated if empty)"
  type        = string
  default     = ""
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets"
  type        = bool
  default     = true
}

# Environment-specific settings
variable "environment_config" {
  description = "Environment-specific configuration"
  type = object({
    instance_tenancy     = optional(string, "default")
    enable_flow_logs     = optional(bool, true)
    flow_logs_retention  = optional(number, 7)
    enable_vpc_endpoints = optional(bool, false)
  })
  default = {
    instance_tenancy     = "default"
    enable_flow_logs     = true
    flow_logs_retention  = 7
    enable_vpc_endpoints = false
  }
}
