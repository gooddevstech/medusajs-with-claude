# VPC Output
output "vpc_id" {
  description = "VPC ID"
  value       = data.aws_vpc.default.id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = data.aws_subnets.public_default.ids
}

output "private_subnets" {
  description = "List of private subnet IDs (used by Lambda)"
  value       = aws_subnet.private[*].id
}

# Lambda Outputs
output "backend_lambda_name" {
  description = "Backend Lambda function name"
  value       = aws_lambda_function.backend.function_name
}

output "backend_lambda_arn" {
  description = "Backend Lambda function ARN"
  value       = aws_lambda_function.backend.arn
}

output "storefront_lambda_name" {
  description = "Storefront Lambda function name"
  value       = aws_lambda_function.storefront.function_name
}

output "storefront_lambda_arn" {
  description = "Storefront Lambda function ARN"
  value       = aws_lambda_function.storefront.arn
}

output "backend_migrate_lambda_name" {
  description = "Backend migration Lambda function name"
  value       = aws_lambda_function.backend_migrate.function_name
}

output "backend_scripts_lambda_name" {
  description = "Backend scripts Lambda function name"
  value       = aws_lambda_function.backend_scripts.function_name
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

# API Gateway Outputs
output "backend_api_id" {
  description = "Backend API Gateway HTTP API ID"
  value       = aws_apigatewayv2_api.backend.id
}

output "storefront_api_id" {
  description = "Storefront API Gateway HTTP API ID"
  value       = aws_apigatewayv2_api.storefront.id
}

output "backend_api_endpoint" {
  description = "Backend API Gateway default endpoint"
  value       = aws_apigatewayv2_api.backend.api_endpoint
}

output "storefront_api_endpoint" {
  description = "Storefront API Gateway default endpoint"
  value       = aws_apigatewayv2_api.storefront.api_endpoint
}

# Aurora Serverless v2 Outputs
output "rds_endpoint" {
  description = "Aurora cluster writer endpoint"
  value       = aws_rds_cluster.postgres.endpoint
  sensitive   = true
}

output "rds_instance_id" {
  description = "Aurora cluster identifier"
  value       = aws_rds_cluster.postgres.cluster_identifier
}

output "rds_port" {
  description = "Aurora cluster port"
  value       = aws_rds_cluster.postgres.port
}

# Valkey Outputs
output "valkey_endpoint" {
  description = "ElastiCache Valkey primary endpoint"
  value       = aws_elasticache_replication_group.valkey.primary_endpoint_address
  sensitive   = true
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

# NAT Gateway
output "nat_gateway_ip" {
  description = "NAT Gateway public IP (for allowlisting outbound Lambda traffic)"
  value       = aws_eip.nat.public_ip
}
