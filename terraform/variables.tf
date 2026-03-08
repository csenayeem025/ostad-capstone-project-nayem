# AWS Region (Singapore)
variable "aws_region" {
  description = "AWS region for deployment (Singapore)"
  type        = string
  default     = "ap-southeast-1"

  validation {
    condition     = contains(["ap-southeast-1", "ap-southeast-2", "ap-southeast-3", "ap-southeast-4"], var.aws_region)
    error_message = "AWS region must be in Southeast Asia (ap-southeast-1, ap-southeast-2, ap-southeast-3, or ap-southeast-4)."
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

# AMI ID for Ubuntu 22.04 in Singapore region
variable "ami_id" {
  description = "AMI ID for Ubuntu 22.04 in Singapore region"
  type        = string
  default     = "ami-0df7a207adb9748c7" # Ubuntu 22.04 LTS in ap-southeast-1 (Singapore)

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
    condition     = contains(["t3.medium", "t3.large", "t3.xlarge", "t3.2xlarge"], var.master_instance_type)
    error_message = "Master instance type must be t3.medium, t3.large, t3.xlarge, or t3.2xlarge."
  }
}

# Worker Node Instance Type
variable "worker_instance_type" {
  description = "Instance type for worker nodes"
  type        = string
  default     = "t3.medium"

  validation {
    condition     = contains(["t3.medium", "t3.large", "t3.xlarge", "t3.2xlarge"], var.worker_instance_type)
    error_message = "Worker instance type must be t3.medium, t3.large, t3.xlarge, or t3.2xlarge."
  }
}

# SSH Key Pair Name
variable "key_name" {
  description = "SSH key pair name in AWS Singapore region"
  type        = string
  default     = "nayem-pem"

  validation {
    condition     = length(var.key_name) > 0
    error_message = "Key name cannot be empty."
  }
}

# Path to SSH Private Key
variable "private_key_path" {
  description = "Path to SSH private key file"
  type        = string
  default     = "~/.ssh/nayem-pem.pem"
}

# VPC ID
variable "vpc_id" {
  description = "VPC ID in Singapore region"
  type        = string
}

# Subnet ID
variable "subnet_id" {
  description = "Subnet ID in Singapore region"
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
    condition     = var.volume_size >= 20 && var.volume_size <= 500
    error_message = "Volume size must be between 20 and 500 GB."
  }
}

# Environment Name
variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["dev", "staging", "production", "dr"], var.environment)
    error_message = "Environment must be dev, staging, production, or dr."
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
    Terraform        = "true"
    Environment      = "production"
    Region           = "Singapore"
    Project          = "QuickHire"
    ManagedBy        = "Terraform"
    CostCenter       = "DevOps"
    DataClassification = "internal"
  }
}

# Kubernetes Version
variable "kubernetes_version" {
  description = "Kubernetes version to install"
  type        = string
  default     = "1.28"

  validation {
    condition     = can(regex("^1\\.(2[4-9]|30)", var.kubernetes_version))
    error_message = "Kubernetes version must be 1.24 or higher."
  }
}

# CIDR Blocks for Ingress Rules
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the cluster"
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = length(var.allowed_cidr_blocks) > 0
    error_message = "At least one CIDR block must be specified."
  }
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
    condition     = var.mongodb_volume_size >= 20 && var.mongodb_volume_size <= 1000
    error_message = "MongoDB volume size must be between 20 and 1000 GB."
  }
}

# MongoDB Volume Type
variable "mongodb_volume_type" {
  description = "EBS volume type for MongoDB"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "st1", "sc1"], var.mongodb_volume_type)
    error_message = "Volume type must be a valid EBS volume type."
  }
}

# MongoDB IOPS (for io1/io2 volumes)
variable "mongodb_iops" {
  description = "IOPS for MongoDB volume (if using io1/io2)"
  type        = number
  default     = null
}

# Monitoring Volume Size
variable "monitoring_volume_size" {
  description = "Size of monitoring data volume in GB"
  type        = number
  default     = 30

  validation {
    condition     = var.monitoring_volume_size >= 20 && var.monitoring_volume_size <= 500
    error_message = "Monitoring volume size must be between 20 and 500 GB."
  }
}

# Frontend Cache Volume Size
variable "frontend_cache_volume_size" {
  description = "Size of frontend cache volume in GB"
  type        = number
  default     = 20

  validation {
    condition     = var.frontend_cache_volume_size >= 10 && var.frontend_cache_volume_size <= 200
    error_message = "Frontend cache volume size must be between 10 and 200 GB."
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

# Availability Zones (for Singapore region)
variable "availability_zones" {
  description = "List of availability zones to use in Singapore region"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]

  validation {
    condition = alltrue([
      for az in var.availability_zones : can(regex("^ap-southeast-1[a-c]$", az))
    ])
    error_message = "Availability zones must be in ap-southeast-1 region (ap-southeast-1a, ap-southeast-1b, or ap-southeast-1c)."
  }
}

# Enable CloudWatch Logs
variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs for EC2 instances"
  type        = bool
  default     = true
}

# CloudWatch Logs Retention Days
variable "cloudwatch_logs_retention_days" {
  description = "Retention days for CloudWatch logs"
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.cloudwatch_logs_retention_days)
    error_message = "CloudWatch logs retention days must be a valid value."
  }
}

# Enable SSM Session Manager
variable "enable_ssm_session_manager" {
  description = "Enable SSM Session Manager for EC2 instances"
  type        = bool
  default     = true
}

# Instance Tenancy
variable "instance_tenancy" {
  description = "Instance tenancy (default or dedicated)"
  type        = string
  default     = "default"

  validation {
    condition     = contains(["default", "dedicated"], var.instance_tenancy)
    error_message = "Instance tenancy must be either default or dedicated."
  }
}

# EBS Optimization
variable "ebs_optimized" {
  description = "Enable EBS optimization for instances"
  type        = bool
  default     = true
}

# Singapore-specific metadata
variable "region_metadata" {
  description = "Singapore region metadata"
  type        = map(string)
  default = {
    region_code        = "ap-southeast-1"
    region_name        = "Singapore"
    continent          = "Asia"
    country            = "Singapore"
    timezone           = "Asia/Singapore"
    supported_azs      = "ap-southeast-1a, ap-southeast-1b, ap-southeast-1c"
    latency_optimized  = "Southeast Asia"
    data_center        = "Singapore"
  }
}

# Backup retention
variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_days >= 1 && var.backup_retention_days <= 365
    error_message = "Backup retention days must be between 1 and 365."
  }
}

# Enable automated snapshots
variable "enable_automated_snapshots" {
  description = "Enable automated EBS snapshots"
  type        = bool
  default     = true
}

# Snapshot schedule
variable "snapshot_schedule" {
  description = "Cron expression for automated snapshots"
  type        = string
  default     = "0 2 * * *" # Daily at 2 AM Singapore time

  validation {
    condition     = can(regex("^[0-9*/-]+ [0-9*/-]+ [0-9*/-]+ [0-9*/-]+ [0-9*/-]+$", var.snapshot_schedule))
    error_message = "Snapshot schedule must be a valid cron expression."
  }
}

# Disaster recovery flag
variable "is_dr_site" {
  description = "Whether this is a disaster recovery site"
  type        = bool
  default     = false
}

# Singapore compliance requirements
variable "compliance_requirements" {
  description = "Compliance requirements for Singapore region"
  type        = list(string)
  default     = ["ISO27001", "SOC2", "PCI-DSS", "MAS-TRM"]

  validation {
    condition = alltrue([
      for req in var.compliance_requirements : contains(["ISO27001", "SOC2", "PCI-DSS", "HIPAA", "GDPR", "MAS-TRM", "SS584"], req)
    ])
    error_message = "Compliance requirements must be valid Singapore/International standards."
  }
}

# Network performance tier
variable "network_performance_tier" {
  description = "Network performance tier for instances"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "enhanced", "dedicated"], var.network_performance_tier)
    error_message = "Network performance tier must be standard, enhanced, or dedicated."
  }
}