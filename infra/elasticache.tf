# ElastiCache Provisioned Valkey (single-node, cluster mode disabled)
# Serverless was replaced because Medusa's ioredis client doesn't support
# cluster mode, and ElastiCache Serverless always runs in cluster mode.
resource "aws_elasticache_subnet_group" "valkey" {
  name       = "${var.project_name}-valkey-subnet-group"
  subnet_ids = data.aws_subnets.public_default.ids

  tags = merge(var.tags, { Name = "${var.project_name}-valkey-subnet-group" })
}

resource "aws_elasticache_replication_group" "valkey" {
  replication_group_id = "${var.project_name}-valkey"
  description          = "Valkey cache for ${var.project_name}"

  engine         = "valkey"
  engine_version = "8.0"
  node_type      = var.elasticache_node_type

  num_cache_clusters = 1

  subnet_group_name  = aws_elasticache_subnet_group.valkey.name
  security_group_ids = [module.redis_sg.security_group_id]

  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
  automatic_failover_enabled = false

  tags = merge(var.tags, { Name = "${var.project_name}-valkey" })
}
