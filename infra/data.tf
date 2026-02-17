# Data source to get available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# Data source to get current AWS region
data "aws_region" "current" {}

# Data source to get default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source to get public subnets in default VPC
data "aws_subnets" "public_default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}