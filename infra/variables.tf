variable "aws_region" {
  description = "AWS region for infrastructure"
  type        = string
  default     = "ap-southeast-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "tindaph"
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
  default     = "172.31.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["172.31.1.0/24", "172.31.2.0/24"]
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

# ElastiCache Serverless Valkey Configuration
variable "valkey_max_storage_gb" {
  description = "Maximum data storage in GB for Valkey serverless cache"
  type        = number
  default     = 5
}

variable "valkey_max_ecpu_per_second" {
  description = "Maximum ECPUs per second for Valkey serverless cache"
  type        = number
  default     = 1000
}

# ECS Configuration
variable "backend_cpu" {
  description = "CPU units for backend ECS task"
  type        = number
  default     = 256
}

variable "backend_memory" {
  description = "Memory (MB) for backend ECS task"
  type        = number
  default     = 512
}

variable "backend_desired_count" {
  description = "Desired number of backend tasks"
  type        = number
  default     = 1
}

variable "backend_max_capacity" {
  description = "Maximum number of backend tasks for auto-scaling"
  type        = number
  default     = 4
}

variable "storefront_cpu" {
  description = "CPU units for storefront ECS task"
  type        = number
  default     = 256
}

variable "storefront_memory" {
  description = "Memory (MB) for storefront ECS task"
  type        = number
  default     = 512
}

variable "storefront_desired_count" {
  description = "Desired number of storefront tasks"
  type        = number
  default     = 1
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

# Application Secrets (stored in SSM Parameter Store)
variable "jwt_secret" {
  description = "JWT secret for Medusa backend"
  type        = string
  sensitive   = true
}

variable "cookie_secret" {
  description = "Cookie secret for Medusa backend"
  type        = string
  sensitive   = true
}

variable "medusa_publishable_key" {
  description = "Medusa publishable API key for storefront (set after first Medusa deploy)"
  type        = string
  sensitive   = true
  default     = "pk_placeholder"
}

variable "revalidate_secret" {
  description = "Next.js revalidation secret for storefront"
  type        = string
  sensitive   = true
}

variable "payrex_publishable_key" {
  description = "PayRex client-side publishable key — it's used in the storefront to initialize the PayRex payment UI"
  type        = string
  sensitive   = true
  default     = "pk_placeholder"
}

variable "payrex_secret_key" {
  description = "PayRex secret key to authenticate requests from the backend"
  type        = string
  sensitive   = true
  default     = "sk_placeholder"
}

variable "payrex_webhook_secret" {
  description = "PayRex webhook signing or secret key to for verification of incoming webhook events"
  type        = string
  sensitive   = true
  default     = "whsk_placeholder"
}

# Tags
variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "tindaph"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}