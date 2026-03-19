# DB Subnet Group
resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = data.aws_subnets.public_default.ids

  tags = merge(var.tags, { Name = "${var.project_name}-db-subnet-group" })
}

# Aurora PostgreSQL Serverless v2 Cluster
resource "aws_rds_cluster" "postgres" {
  cluster_identifier = "${var.project_name}-postgres"

  engine         = "aurora-postgresql"
  engine_version = "16.6"

  database_name   = var.db_name
  master_username = var.db_username
  master_password = var.db_password
  port            = 5432

  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [module.rds_sg.security_group_id]

  storage_encrypted = true

  serverlessv2_scaling_configuration {
    min_capacity = var.aurora_min_capacity
    max_capacity = var.aurora_max_capacity
  }

  backup_retention_period      = 1
  preferred_backup_window      = "03:00-04:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"
  copy_tags_to_snapshot        = true

  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.project_name}-postgres-final"

  enabled_cloudwatch_logs_exports      = ["postgresql"]
  iam_database_authentication_enabled  = true

  tags = merge(var.tags, { Name = "${var.project_name}-postgres" })
}

# Aurora Serverless v2 Writer Instance
resource "aws_rds_cluster_instance" "postgres_writer" {
  identifier         = "${var.project_name}-postgres-writer"
  cluster_identifier = aws_rds_cluster.postgres.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.postgres.engine
  engine_version     = aws_rds_cluster.postgres.engine_version

  db_subnet_group_name = aws_db_subnet_group.default.name

  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  publicly_accessible = false

  tags = merge(var.tags, { Name = "${var.project_name}-postgres-writer" })
}

# IAM role for RDS enhanced monitoring
resource "aws_iam_role" "rds_monitoring" {
  name_prefix = "${var.project_name}-rds-monitoring-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
