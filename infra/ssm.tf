# SSM Parameter Store - application secrets and config for ECS tasks

locals {
  rds_endpoint    = aws_rds_cluster.postgres.endpoint
  valkey_endpoint = aws_elasticache_serverless_cache.valkey.endpoint[0].address
  valkey_port     = aws_elasticache_serverless_cache.valkey.endpoint[0].port
  database_url    = "postgresql://${var.db_username}:${var.db_password}@${local.rds_endpoint}:5432/${var.db_name}"
  redis_url       = "rediss://${local.valkey_endpoint}:${local.valkey_port}"
}

resource "aws_ssm_parameter" "database_host" {
  name  = "/${var.project_name}/database_host"
  type  = "SecureString"
  value = local.rds_endpoint

  tags = var.tags
}

resource "aws_ssm_parameter" "database_name" {
  name  = "/${var.project_name}/database_name"
  type  = "SecureString"
  value = var.db_name

  tags = var.tags
}

resource "aws_ssm_parameter" "database_password" {
  name  = "/${var.project_name}/database_password"
  type  = "SecureString"
  value = var.db_password

  tags = var.tags
}

resource "aws_ssm_parameter" "database_username" {
  name  = "/${var.project_name}/database_username"
  type  = "SecureString"
  value = var.db_username

  tags = var.tags
}

resource "aws_ssm_parameter" "database_url" {
  name  = "/${var.project_name}/database_url"
  type  = "SecureString"
  value = local.database_url

  tags = var.tags
}

resource "aws_ssm_parameter" "redis_url" {
  name  = "/${var.project_name}/redis_url"
  type  = "SecureString"
  value = local.redis_url

  tags = var.tags
}

resource "aws_ssm_parameter" "jwt_secret" {
  name  = "/${var.project_name}/jwt_secret"
  type  = "SecureString"
  value = var.jwt_secret

  tags = var.tags
}

resource "aws_ssm_parameter" "cookie_secret" {
  name  = "/${var.project_name}/cookie_secret"
  type  = "SecureString"
  value = var.cookie_secret

  tags = var.tags
}

resource "aws_ssm_parameter" "medusa_publishable_key" {
  name  = "/${var.project_name}/medusa_publishable_key"
  type  = "SecureString"
  value = var.medusa_publishable_key != "" ? var.medusa_publishable_key : "placeholder"

  tags = var.tags
}

resource "aws_ssm_parameter" "revalidate_secret" {
  name  = "/${var.project_name}/revalidate_secret"
  type  = "SecureString"
  value = var.revalidate_secret

  tags = var.tags
}

resource "aws_ssm_parameter" "payrex_publishable_key" {
  name  = "/${var.project_name}/payrex_publishable_key"
  type  = "SecureString"
  value = var.payrex_publishable_key != "" ? var.payrex_publishable_key : "placeholder"

  tags = var.tags
}

resource "aws_ssm_parameter" "payrex_secret_key" {
  name  = "/${var.project_name}/payrex_secret_key"
  type  = "SecureString"
  value = var.payrex_secret_key != "" ? var.payrex_secret_key : "placeholder"

  tags = var.tags
}


resource "aws_ssm_parameter" "payrex_webhook_secret" {
  name  = "/${var.project_name}/payrex_webhook_secret"
  type  = "SecureString"
  value = var.payrex_webhook_secret != "" ? var.payrex_webhook_secret : "placeholder"

  tags = var.tags
}
