variable "aws_region" {
  description = "AWS region for infrastructure"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "tindahang"
}

variable "environment" {
  description = "Environment name (production, staging, etc)"
  type        = string
  default     = "production"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  default     = "905418233489"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

# RDS Configuration
variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "medusa"
  sensitive   = true
}

variable "db_username" {
  description = "Master username for RDS database"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password for RDS database"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type        = number
  default     = 100
}

# ElastiCache Configuration
variable "redis_node_type" {
  description = "ElastiCache node type for Redis"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_num_cache_clusters" {
  description = "Number of cache clusters for Redis replication group"
  type        = number
  default     = 2
}

# ECS Configuration
variable "backend_cpu" {
  description = "CPU units for backend ECS task"
  type        = number
  default     = 512
}

variable "backend_memory" {
  description = "Memory (MB) for backend ECS task"
  type        = number
  default     = 1024
}

variable "backend_desired_count" {
  description = "Desired number of backend tasks"
  type        = number
  default     = 2
}

variable "backend_max_capacity" {
  description = "Maximum number of backend tasks for auto-scaling"
  type        = number
  default     = 4
}

variable "storefront_cpu" {
  description = "CPU units for storefront ECS task"
  type        = number
  default     = 512
}

variable "storefront_memory" {
  description = "Memory (MB) for storefront ECS task"
  type        = number
  default     = 1024
}

variable "storefront_desired_count" {
  description = "Desired number of storefront tasks"
  type        = number
  default     = 2
}

variable "storefront_max_capacity" {
  description = "Maximum number of storefront tasks for auto-scaling"
  type        = number
  default     = 4
}

# Domain Configuration
variable "domain_name" {
  description = "Primary domain name"
  type        = string
  default     = "tindaph.app"
}

variable "create_certificate" {
  description = "Whether to create ACM certificate"
  type        = bool
  default     = true
}

# Tags
variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "tindahang"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}