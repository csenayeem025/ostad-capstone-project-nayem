# AWS Region (Mumbai)
variable "aws_region" {
  description = "AWS region for deployment (Mumbai)"
  type        = string
  default     = "ap-south-1"

  validation {
    condition     = contains(["ap-south-1", "ap-south-2"], var.aws_region)
    error_message = "AWS region must be in Mumbai (ap-south-1 or ap-south-2)."
  }
}

# AWS Access Key
variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

# AWS Secret Key
variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

# AWS Session Token (optional - for temporary credentials)
variable "aws_session_token" {
  description = "AWS Session Token (optional, for temporary credentials)"
  type        = string
  sensitive   = true
  default     = null
}

# AMI ID for Ubuntu 22.04 in Mumbai region
variable "ami_id" {
  description = "AMI ID for Ubuntu 22.04 in Mumbai region"
  type        = string
  default     = "ami-0da59f20af2c0cc27" # Ubuntu 22.04 LTS in ap-south-1

  validation {
    condition     = length(var.ami_id) > 0
    error_message = "AMI ID cannot be empty."
  }
}

# Master Node Instance Type
variable "master_instance_type" {
  description = "Instance type for master node"
  type        = string
  default     = "t3.medium"

  validation {
    condition     = contains(["t3.medium", "t3.large", "t3.xlarge"], var.master_instance_type)
    error_message = "Master instance type must be t3.medium, t3.large, or t3.xlarge."
  }
}

# Worker Node Instance Type
variable "worker_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t3.medium"

  validation {
    condition     = contains(["t3.medium", "t3.large", "t3.xlarge"], var.worker_instance_type)
    error_message = "Worker instance type must be t3.medium, t3.large, or t3.xlarge."
  }
}

# SSH Key Pair Name
variable "key_name" {
  description = "SSH key pair name in AWS Mumbai region"
  type        = string
  default     = "quickhire-mumbai-key"

  validation {
    condition     = length(var.key_name) > 0
    error_message = "Key name cannot be empty."
  }
}

# Path to SSH Private Key
variable "private_key_path" {
  description = "Path to SSH private key file"
  type        = string
  default     = "~/.ssh/quickhire-mumbai-key.pem"
}

# VPC ID
variable "vpc_id" {
  description = "VPC ID in Mumbai region"
  type        = string
}

# Subnet ID
variable "subnet_id" {
  description = "Subnet ID in Mumbai region"
  type        = string
}

# Additional Subnet IDs for high availability
variable "subnet_ids" {
  description = "List of subnet IDs for multi-AZ deployment"
  type        = list(string)
  default     = []
}

# Root Volume Size
variable "volume_size" {
  description = "Root EBS volume size in GB"
  type        = number
  default     = 30

  validation {
    condition     = var.volume_size >= 20 && var.volume_size <= 100
    error_message = "Volume size must be between 20 and 100 GB."
  }
}

# Environment Name
variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["dev", "staging", "production"], var.environment)
    error_message = "Environment must be dev, staging, or production."
  }
}

# Project Name
variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "quickhire"
}

# Owner/Team
variable "owner" {
  description = "Owner or team responsible for the resources"
  type        = string
  default     = "devops-team"
}

# Enable Detailed Monitoring
variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}

# Instance Tags
variable "additional_tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "production"
    Region      = "Mumbai"
    Project     = "QuickHire"
  }
}

# Kubernetes Version
variable "kubernetes_version" {
  description = "Kubernetes version to install"
  type        = string
  default     = "1.28"
}

# CIDR Blocks for Ingress Rules
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the cluster"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# Create Elastic IP for Master
variable "create_eip_for_master" {
  description = "Create Elastic IP for master node"
  type        = bool
  default     = true
}

# MongoDB Volume Size
variable "mongodb_volume_size" {
  description = "Size of MongoDB data volume in GB"
  type        = number
  default     = 50

  validation {
    condition     = var.mongodb_volume_size >= 20 && var.mongodb_volume_size <= 500
    error_message = "MongoDB volume size must be between 20 and 500 GB."
  }
}

# Monitoring Volume Size
variable "monitoring_volume_size" {
  description = "Size of monitoring data volume in GB"
  type        = number
  default     = 30

  validation {
    condition     = var.monitoring_volume_size >= 20 && var.monitoring_volume_size <= 200
    error_message = "Monitoring volume size must be between 20 and 200 GB."
  }
}

# Frontend Cache Volume Size
variable "frontend_cache_volume_size" {
  description = "Size of frontend cache volume in GB"
  type        = number
  default     = 20

  validation {
    condition     = var.frontend_cache_volume_size >= 10 && var.frontend_cache_volume_size <= 100
    error_message = "Frontend cache volume size must be between 10 and 100 GB."
  }
}

# Enable Termination Protection
variable "enable_termination_protection" {
  description = "Enable termination protection for instances"
  type        = bool
  default     = false
}

# Instance Profile
variable "instance_profile" {
  description = "IAM instance profile for EC2 instances"
  type        = string
  default     = null
}