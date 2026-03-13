# ElastiCache Redis Module
module "redis" {
  source  = "terraform-aws-modules/elasticache/aws"
  version = "~> 1.0"

  replication_group_id = "${var.project_name}-redis"
  description          = "${var.project_name} Redis replication group"

  engine_version = "7.0"
  node_type      = var.redis_node_type
  port           = 6379

  num_cache_clusters         = var.redis_num_cache_clusters
  automatic_failover_enabled = var.redis_num_cache_clusters > 1 ? true : false
  transit_encryption_enabled = true
  auth_token                 = random_password.redis_auth_token.result

  at_rest_encryption_enabled = true

  subnet_ids             = data.aws_subnets.public_default.ids
  security_group_ids     = [module.redis_sg.security_group_id]
  create_parameter_group = true
  parameter_group_family = "redis7"

  # Maintenance and backup
  maintenance_window        = "sun:05:00-sun:06:00"
  snapshot_retention_limit  = 5
  snapshot_window           = "04:00-05:00"
  final_snapshot_identifier = "${var.project_name}-redis-final-snapshot"
  apply_immediately         = false

  tags = merge(var.tags, { Name = "${var.project_name}-redis" })

  depends_on = [aws_secretsmanager_secret_version.redis_auth_token]
}

# Generate random password for Redis auth token
resource "random_password" "redis_auth_token" {
  length           = 32
  special          = true
  override_special = "!#$%&*-_=+"
}

# Store Redis auth token in Secrets Manager
resource "aws_secretsmanager_secret" "redis_auth_token" {
  name_prefix             = "${var.project_name}-redis-auth-"
  recovery_window_in_days = 0

  tags = merge(var.tags, { Name = "${var.project_name}-redis-auth-token" })
}

resource "aws_secretsmanager_secret_version" "redis_auth_token" {
  secret_id     = aws_secretsmanager_secret.redis_auth_token.id
  secret_string = random_password.redis_auth_token.result
}