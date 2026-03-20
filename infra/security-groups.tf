# Security Groups using terraform-aws-modules/security-group/aws

# Lambda Security Group — allows all outbound (for NAT → internet, RDS, Valkey)
module "lambda_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.project_name}-lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = data.aws_vpc.default.id

  egress_rules = ["all-all"]

  tags = merge(var.tags, { Name = "${var.project_name}-lambda-sg" })
}

# RDS Security Group — allows PostgreSQL from Lambda and VPC
module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS - allows PostgreSQL from Lambda"
  vpc_id      = data.aws_vpc.default.id

  ingress_with_source_security_group_id = [
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      description              = "PostgreSQL from Lambda"
      source_security_group_id = module.lambda_sg.security_group_id
    }
  ]

  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL from VPC"
      cidr_blocks = data.aws_vpc.default.cidr_block
    }
  ]

  egress_rules = ["all-all"]

  tags = merge(var.tags, { Name = "${var.project_name}-rds-sg" })
}

# Valkey Security Group — allows Valkey/Redis from Lambda and VPC
module "redis_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.project_name}-valkey-sg"
  description = "Security group for Valkey serverless cache - allows access from Lambda"
  vpc_id      = data.aws_vpc.default.id

  ingress_with_source_security_group_id = [
    {
      from_port                = 6379
      to_port                  = 6379
      protocol                 = "tcp"
      description              = "Valkey from Lambda"
      source_security_group_id = module.lambda_sg.security_group_id
    }
  ]

  ingress_with_cidr_blocks = [
    {
      from_port   = 6379
      to_port     = 6379
      protocol    = "tcp"
      description = "Valkey from VPC"
      cidr_blocks = data.aws_vpc.default.cidr_block
    }
  ]

  egress_rules = ["all-all"]

  tags = merge(var.tags, { Name = "${var.project_name}-valkey-sg" })
}
