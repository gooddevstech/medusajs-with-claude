# Note: This file shows the S3 backend configuration
# Since backend is configured in providers.tf via Terraform Cloud,
# you can optionally use this configuration for local S3 backend instead

# To use S3 backend instead of Terraform Cloud, replace the cloud block in providers.tf with:
# terraform {
#   backend "s3" {
#     bucket         = "gooddevs-devops-base-infra-terraform"
#     key            = "tindahang/production/terraform.tfstate"
#     region         = "ap-southeast-1"
#     encrypt        = true
#     dynamodb_table = "gooddevs-devops-base-infra-terraform-lock"
#   }
# }

# Ensure S3 bucket and DynamoDB table exist before terraform init:
# aws s3api create-bucket \
#   --bucket gooddevs-devops-base-infra-terraform \
#   --region ap-southeast-1 \
#   --create-bucket-configuration LocationConstraint=ap-southeast-1
#
# aws s3api put-bucket-versioning \
#   --bucket gooddevs-devops-base-infra-terraform \
#   --versioning-configuration Status=Enabled
#
# aws dynamodb create-table \
#   --table-name gooddevs-devops-base-infra-terraform-lock \
#   --attribute-definitions AttributeName=LockID,AttributeType=S \
#   --key-schema AttributeName=LockID,KeyType=HASH \
#   --billing-mode PAY_PER_REQUEST \
#   --region ap-southeast-1