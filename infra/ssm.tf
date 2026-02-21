# SSM Parameter Store - application secrets and config for ECS tasks

locals {
  rds_endpoint   = module.rds.db_instance_endpoint
  redis_endpoint = module.redis.replication_group_configuration_endpoint_address
  database_url   = "postgresql://${var.db_username}:${var.db_password}@${local.rds_endpoint}/${var.db_name}"
  redis_url      = "rediss://:${random_password.redis_auth_token.result}@${local.redis_endpoint}:6379"
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
  value = var.medusa_publishable_key

  tags = var.tags
}

resource "aws_ssm_parameter" "revalidate_secret" {
  name  = "/${var.project_name}/revalidate_secret"
  type  = "SecureString"
  value = var.revalidate_secret

  tags = var.tags
}
