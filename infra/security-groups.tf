# Security Groups using terraform-aws-modules/security-group/aws

# ALB Security Group - allows HTTP/HTTPS from internet
module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.project_name}-alb-sg"
  description = "Security group for ALB - allows HTTP and HTTPS from internet"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]

  egress_rules = ["all-all"]

  tags = merge(var.tags, { Name = "${var.project_name}-alb-sg" })
}

# ECS Tasks Security Group - allows traffic from ALB
module "ecs_tasks_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.project_name}-ecs-tasks-sg"
  description = "Security group for ECS tasks - allows traffic from ALB"
  vpc_id      = data.aws_vpc.default.id

  ingress_with_source_security_group_id = [
    {
      from_port                = 8000
      to_port                  = 8000
      protocol                 = "tcp"
      description              = "Storefront from ALB"
      source_security_group_id = module.alb_sg.security_group_id
    },
    {
      from_port                = 9000
      to_port                  = 9000
      protocol                 = "tcp"
      description              = "Backend from ALB"
      source_security_group_id = module.alb_sg.security_group_id
    }
  ]

  egress_rules = ["all-all"]

  tags = merge(var.tags, { Name = "${var.project_name}-ecs-tasks-sg" })
}

# RDS Security Group - allows PostgreSQL from ECS tasks
module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS - allows PostgreSQL from ECS tasks"
  vpc_id      = data.aws_vpc.default.id

  ingress_with_source_security_group_id = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL from ECS tasks"
      source_security_group_id = module.ecs_tasks_sg.security_group_id
    }
  ]

  egress_rules = ["all-all"]

  tags = merge(var.tags, { Name = "${var.project_name}-rds-sg" })
}

# Redis Security Group - allows Redis from ECS tasks
module "redis_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.project_name}-redis-sg"
  description = "Security group for Redis - allows Redis from ECS tasks"
  vpc_id      = data.aws_vpc.default.id

  ingress_with_source_security_group_id = [
    {
      from_port                = 6379
      to_port                  = 6379
      protocol                 = "tcp"
      description              = "Redis from ECS tasks"
      source_security_group_id = module.ecs_tasks_sg.security_group_id
    }
  ]

  egress_rules = ["all-all"]

  tags = merge(var.tags, { Name = "${var.project_name}-redis-sg" })
}
