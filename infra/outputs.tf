# VPC Output
output "vpc_id" {
  description = "VPC ID"
  value       = data.aws_vpc.default.id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = data.aws_subnets.public_default.ids
}

# ECS Outputs
output "ecs_cluster_id" {
  description = "ECS cluster ID"
  value       = module.ecs.cluster_id
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  value       = module.ecs.cluster_arn
}

# ECR Outputs
output "backend_repository_url" {
  description = "Backend ECR repository URL"
  value       = aws_ecr_repository.backend.repository_url
}

output "storefront_repository_url" {
  description = "Storefront ECR repository URL"
  value       = aws_ecr_repository.storefront.repository_url
}

# ALB Outputs
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = module.alb.dns_name
}

output "alb_arn" {
  description = "ALB ARN"
  value       = module.alb.arn
}

output "alb_zone_id" {
  description = "ALB Zone ID"
  value       = module.alb.zone_id
}

output "backend_target_group_arn" {
  description = "Backend target group ARN"
  value       = module.alb.target_groups["backend"].arn
}

output "storefront_target_group_arn" {
  description = "Storefront target group ARN"
  value       = module.alb.target_groups["storefront"].arn
}

# RDS Outputs
output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = module.rds.db_instance_endpoint
  sensitive   = true
}

output "rds_instance_id" {
  description = "RDS database instance ID"
  value       = module.rds.db_instance_identifier
}

output "rds_port" {
  description = "RDS database port"
  value       = module.rds.db_instance_port
}

# Valkey Serverless Outputs
output "valkey_endpoint" {
  description = "ElastiCache Serverless Valkey endpoint"
  value       = aws_elasticache_serverless_cache.valkey.endpoint[0].address
  sensitive   = true
}

output "valkey_port" {
  description = "ElastiCache Serverless Valkey port"
  value       = aws_elasticache_serverless_cache.valkey.endpoint[0].port
}

# S3 Outputs
output "media_bucket_name" {
  description = "S3 media bucket name"
  value       = module.s3_media.s3_bucket_id
}

output "media_bucket_arn" {
  description = "S3 media bucket ARN"
  value       = module.s3_media.s3_bucket_arn
}

# CloudFront Outputs
output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cloudfront.cloudfront_distribution_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.cloudfront_distribution_id
}

# Route53 Outputs
output "route53_zone_id" {
  description = "Route53 hosted zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "route53_nameservers" {
  description = "Route53 nameservers - point your domain registrar to these after first apply"
  value       = aws_route53_zone.main.name_servers
}

# DNS Records
output "domain_urls" {
  description = "Application URLs"
  value = {
    storefront = "https://${var.domain_name}"
    api        = "https://api.${var.domain_name}"
    admin      = "https://admin.${var.domain_name}"
    media      = "https://media.${var.domain_name}"
  }
}

# ECS Services Outputs
output "backend_service_name" {
  description = "Backend ECS service name"
  value       = aws_ecs_service.backend.name
}

output "storefront_service_name" {
  description = "Storefront ECS service name"
  value       = aws_ecs_service.storefront.name
}