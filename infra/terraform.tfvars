# AWS Configuration
aws_region     = "ap-southeast-1"
aws_account_id = "905418233489"

# Project Configuration
project_name = "tindaph"
environment  = "production"

# VPC Configuration
vpc_cidr       = "172.31.0.0/16"
public_subnets = ["172.31.1.0/24", "172.31.2.0/24"]

# RDS Configuration
db_name              = "medusa"
db_username          = "medusa"
db_password          = "hyhwez-Fizdy1-xixrap"
db_instance_class    = "db.t3.micro"
db_allocated_storage = 100

# ElastiCache Redis Configuration
redis_node_type          = "cache.t3.micro"
redis_num_cache_clusters = 2

# ECS Backend Configuration
backend_cpu           = 512
backend_memory        = 1024
backend_desired_count = 2
backend_max_capacity  = 4

# ECS Storefront Configuration
storefront_cpu           = 512
storefront_memory        = 1024
storefront_desired_count = 2
storefront_max_capacity  = 4

# Domain Configuration
domain_name        = "tindaph.app"
create_certificate = true

# Tags
tags = {
  Project     = "tindaph"
  Environment = "production"
  ManagedBy   = "Terraform"
}