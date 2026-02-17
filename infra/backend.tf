# Backend configuration is in providers.tf (S3 + DynamoDB lock)
#
# Prerequisites (one-time setup):
#
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
