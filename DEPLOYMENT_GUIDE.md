# Deployment Guide

This guide provides step-by-step instructions for deploying the Tindahang e-commerce platform to AWS using Terraform infrastructure-as-code and GitHub Actions CI/CD.

## Prerequisites

- AWS Account with appropriate permissions
- GitHub repository with admin access
- AWS CLI v2 installed locally
- Terraform CLI v1.6+ installed locally
- Docker installed locally (for building and testing images)

## Setup Steps

### 1. AWS Account Setup

#### Create IAM User for CI/CD

```bash
# Create CI/CD IAM user
aws iam create-user --user-name tindahang-cicd

# Create access key
aws iam create-access-key --user-name tindahang-cicd > cicd-credentials.json

# Attach necessary policies (or create custom policy with required permissions)
aws iam attach-user-policy \
  --user-name tindahang-cicd \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
```

### 2. Backend Infrastructure

#### Create S3 bucket for Terraform state

```bash
aws s3api create-bucket \
  --bucket gooddevs-devops-base-infra-terraform \
  --region ap-southeast-1 \
  --create-bucket-configuration LocationConstraint=ap-southeast-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket gooddevs-devops-base-infra-terraform \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket gooddevs-devops-base-infra-terraform \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

#### Create DynamoDB table for state locking

```bash
aws dynamodb create-table \
  --table-name gooddevs-devops-base-infra-terraform-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-southeast-1
```

### 3. Route53 Setup

Ensure your Route53 hosted zone exists for `tindaph.app`:

```bash
# List hosted zones
aws route53 list-hosted-zones-by-name --dns-name tindaph.app
```

### 4. GitHub Secrets Configuration

Set the following secrets in your GitHub repository (Settings → Environments → prod):

| Secret | Description | Example |
|--------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | IAM user access key | `AKIA...` |
| `AWS_SECRET_ACCESS_KEY` | IAM user secret key | `wJa...` |
| `AWS_REGION` | AWS region | `ap-southeast-1` |
| `AWS_ACCOUNT_ID` | AWS account ID | `905418233489` |
| `TF_VAR_db_username` | RDS master username | `medusa_user` |
| `TF_VAR_db_password` | RDS master password | `<strong-random-password>` |
| `TF_VAR_db_name` | Database name | `medusa` |
| `TF_VAR_redis_password` | Redis auth token | `<strong-random-password>` |
| `MEDUSA_JWT_SECRET` | JWT secret for auth | `<random-64-char-string>` |
| `COOKIE_SECRET` | Cookie secret | `<random-32-char-string>` |
| `NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY` | Medusa publishable key | `pk_live_...` |
| `REVALIDATE_SECRET` | ISR revalidation secret | `<random-string>` |

### 5. Terraform Configuration

Create `infra/terraform.tfvars`:

```bash
cp infra/terraform.tfvars.example infra/terraform.tfvars
# Edit with your specific values
```

### 6. SSM Parameters (Automated)

SSM Parameters are automatically created by the Terraform workflow after infrastructure deployment. The following parameters are created in AWS Systems Manager Parameter Store:

| Parameter | Source | Purpose |
|-----------|--------|---------|
| `/tindahang/database_url` | Constructed from RDS endpoint + DB credentials | Backend database connection |
| `/tindahang/redis_url` | Constructed from ElastiCache endpoint + auth token | Backend Redis cache connection |
| `/tindahang/jwt_secret` | `MEDUSA_JWT_SECRET` GitHub Secret | JWT token signing |
| `/tindahang/cookie_secret` | `COOKIE_SECRET` GitHub Secret | Session cookie encryption |
| `/tindahang/medusa_publishable_key` | `NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY` GitHub Secret | Frontend API access |
| `/tindahang/revalidate_secret` | `REVALIDATE_SECRET` GitHub Secret | Next.js ISR webhooks |

**No manual setup required.** Parameters are automatically created/updated when the Terraform workflow runs on the main branch.

## Deployment Process

### Stage 1: Infrastructure Deployment

1. Push infrastructure changes to `infra/` directory on main branch
2. GitHub Actions automatically triggers `terraform.yml` workflow
3. Terraform plan is generated and commented on the PR
4. Merge PR to main
5. Terraform automatically applies infrastructure changes

Alternatively, manually trigger:

```bash
gh workflow run terraform.yml --ref main
```

### Stage 2: Backend Deployment

1. Push backend code changes (src/**, Dockerfile, etc.) to main
2. GitHub Actions triggers `deploy-backend.yml`
3. Docker image is built and pushed to ECR
4. Database migration runs automatically
5. ECS service is updated with new image
6. Service health is verified

### Stage 3: Storefront Deployment

1. Push storefront changes (storefront/**) to main
2. GitHub Actions triggers `deploy-storefront.yml`
3. Docker image is built and pushed to ECR
4. ECS service is updated with new image
5. Service health is verified

## Local Testing

### Test Terraform Configuration

```bash
cd infra

# Format check
terraform fmt -check -recursive

# Validate configuration
terraform init
terraform validate

# Plan changes
terraform plan -out=tfplan
```

### Build Docker Images Locally

```bash
# Backend production image
docker build -f Dockerfile.prod -t tindahang-backend:local .
docker run -p 9000:9000 tindahang-backend:local

# Storefront production image
docker build -f storefront/Dockerfile.prod -t tindahang-storefront:local storefront/
docker run -p 8000:8000 tindahang-storefront:local
```

## Monitoring & Operations

### View Logs

```bash
# Backend logs
aws logs tail /ecs/tindahang-backend --follow

# Storefront logs
aws logs tail /ecs/tindahang-storefront --follow
```

### ECS Operations

```bash
# Describe service
aws ecs describe-services --cluster tindahang-ecs --services tindahang-backend

# View tasks
aws ecs list-tasks --cluster tindahang-ecs --service-name tindahang-backend

# Get task details
aws ecs describe-tasks --cluster tindahang-ecs --tasks <task-arn>

# Execute command in running task (for debugging)
aws ecs execute-command \
  --cluster tindahang-ecs \
  --task <task-arn> \
  --container backend \
  --interactive \
  --command "/bin/sh"
```

### Database Operations

```bash
# Connect to RDS database
psql -h <rds-endpoint> -U medusa_user -d medusa

# Run migrations (one-off task)
aws ecs run-task \
  --cluster tindahang-ecs \
  --task-definition tindahang-backend \
  --overrides 'containerOverrides=[{name=backend,command=["yarn","medusa","db:migrate"]}]'

# Create admin user (one-off task)
aws ecs run-task \
  --cluster tindahang-ecs \
  --task-definition tindahang-backend \
  --overrides 'containerOverrides=[{name=backend,command=["yarn","medusa","user","-e","admin@tindaph.app","-p","<password>"]}]'
```

## Rollback Procedures

### Rollback Backend

1. In AWS Console or CLI, find the previous backend task definition
2. Update ECS service to use previous task definition
3. Service will re-deploy with previous image

```bash
aws ecs update-service \
  --cluster tindahang-ecs \
  --service tindahang-backend \
  --task-definition tindahang-backend:N \
  --force-new-deployment
```

### Rollback Storefront

Same process as backend for storefront service.

### Rollback Infrastructure

```bash
cd infra

# Review changes
terraform plan -destroy

# If acceptable, destroy resources
terraform destroy -auto-approve

# Or revert to previous state version and reapply
terraform apply -var="skip_final_snapshot=true"
```

## Important Notes

- Database migrations are cumulative and forward-only. Always test migrations in staging first.
- RDS backups are retained for 7 days. Ensure critical data is backed up before destructive operations.
- Auto-scaling policies are configured with CPU target of 70%. Adjust based on workload.
- All secrets should use strong, randomly generated values. Never use default/simple passwords.
- ECR images are retained for the last 10 tags. Older images are automatically cleaned up.

## Troubleshooting

### Terraform Plan Fails

1. Check AWS credentials: `aws sts get-caller-identity`
2. Verify IAM permissions for resources being created
3. Check Terraform state: `terraform show`
4. Review AWS CloudTrail for API errors

### Deployment Fails

1. Check ECS task logs: `aws logs tail /ecs/<service-name>`
2. Verify security group rules allow traffic
3. Confirm database connectivity: Check RDS security group
4. Verify Docker image exists in ECR

### Services Won't Start

1. Check container health checks in task definition
2. Verify environment variables are set correctly
3. Check application logs for startup errors
4. Verify database and Redis connectivity

## Support

For issues or questions, refer to:
- [Deployment Plan Documentation](./DEPLOYMENT_PLAN.md)
- [Project Summary](./PROJECT_SUMMARY.md)
- AWS Documentation: https://docs.aws.amazon.com/
- Terraform AWS Provider: https://registry.terraform.io/providers/hashicorp/aws/latest