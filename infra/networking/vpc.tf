# VPC using terraform-aws-modules/vpc/aws
# Note: By default, we're using the existing default VPC and public subnets for cost savings
# To create a new VPC, uncomment the module below and update networking/security-groups.tf to use it

# Uncomment to use custom VPC instead of default VPC:
# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"
#   version = "~> 5.0"
# 
#   name = "${var.project_name}-vpc"
#   cidr = var.vpc_cidr
#   
#   azs             = data.aws_availability_zones.available.names
#   public_subnets = var.public_subnets
#   
#   enable_nat_gateway = false  # Cost savings: use public subnets only, SG for security
#   enable_vpn_gateway = false
#   enable_dns_hostnames = true
#   enable_dns_support   = true
#   
#   enable_flow_log                      = true
#   create_flow_log_cloudwatch_iam_role = true
#   create_flow_log_cloudwatch_log_group = true
#   
#   tags = merge(var.tags, { Name = "${var.project_name}-vpc" })
# }

# Using default VPC + public subnets (already defined in data.tf)
# This provides the same security model with cost savings