# ElastiCache Serverless Valkey Cache
resource "aws_elasticache_serverless_cache" "valkey" {
  engine = "valkey"
  name   = "${var.project_name}-valkey"

  major_engine_version = "8"

  cache_usage_limits {
    data_storage {
      maximum = var.valkey_max_storage_gb
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = var.valkey_max_ecpu_per_second
    }
  }

  subnet_ids         = data.aws_subnets.public_default.ids
  security_group_ids = [module.redis_sg.security_group_id]

  tags = merge(var.tags, { Name = "${var.project_name}-valkey" })
}
