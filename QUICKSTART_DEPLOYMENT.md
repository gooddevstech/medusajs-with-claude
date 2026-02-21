# Quick Start: Deploy Tindaph to AWS

Fast-track deployment checklist for experienced DevOps engineers.

## 1-Minute Setup

```bash
# Clone credentials from the team (stored securely)
# Copy AWS access keys to GitHub Secrets (prod environment)

# Generate strong passwords/secrets
RANDOM_32=$(head -c 32 /dev/urandom | base64)
RANDOM_64=$(head -c 64 /dev/urandom | base64)

# Set GitHub Secrets via CLI
gh secret set AWS_ACCESS_KEY_ID --body "AKIA..."
gh secret set AWS_SECRET_ACCESS_KEY --body "wJa..."
gh secret set AWS_ACCOUNT_ID --body "905418233489"
gh secret set AWS_REGION --body "ap-southeast-1"
gh secret set TF_VAR_db_password --body "$RANDOM_32"
gh secret set MEDUSA_JWT_SECRET --body "$RANDOM_64"
gh secret set COOKIE_SECRET --body "$RANDOM_32"
gh secret set NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY --body "pk_live_..."
gh secret set REVALIDATE_SECRET --body "$(head -c 16 /dev/urandom | base64)"
```

## Infrastructure Deployment (3 steps)

1. **Create S3 backend**
   ```bash
   aws s3api create-bucket \
     --bucket gooddevs-devops-base-infra-terraform \
     --region ap-southeast-1 \
     --create-bucket-configuration LocationConstraint=ap-southeast-1
   
   aws s3api put-bucket-versioning \
     --bucket gooddevs-devops-base-infra-terraform \
     --versioning-configuration Status=Enabled
   
   aws dynamodb create-table \
     --table-name gooddevs-devops-base-infra-terraform-lock \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST \
     --region ap-southeast-1
   ```

2. **Configure Terraform variables**
   ```bash
   cd infra
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

3. **Trigger infrastructure deployment**
   ```bash
   git push origin feat/infrastructure
   # Or manually trigger: gh workflow run terraform.yml --ref main
   ```

## Application Deployment (2 steps)

1. **Build and push backend image**
   ```bash
   git push origin feat/backend  # Triggers deploy-backend.yml
   ```

2. **Build and push storefront image**
   ```bash
   git push origin feat/storefront  # Triggers deploy-storefront.yml
   ```

## Post-Deployment (Optional but recommended)

```bash
# Create admin user
aws ecs run-task \
  --cluster tindaph-ecs \
  --task-definition tindaph-backend \
  --overrides 'containerOverrides=[{name=backend,command=["yarn","medusa","user","-e","admin@tindaph.app","-p","STRONG_PASSWORD"]}]'

# Seed products (if needed)
aws ecs run-task \
  --cluster tindaph-ecs \
  --task-definition tindaph-backend \
  --overrides 'containerOverrides=[{name=backend,command=["yarn","seed"]}]'

# Test endpoints
curl https://tindaph.app
curl https://api.tindaph.app/admin
curl https://admin.tindaph.app
```

## Verify Deployment

```bash
# Check infrastructure
aws ecs describe-services --cluster tindaph-ecs --services tindaph-backend tindaph-storefront

# Check logs
aws logs tail /ecs/tindaph-backend --follow
aws logs tail /ecs/tindaph-storefront --follow

# Get ALB DNS
aws elbv2 describe-load-balancers --query 'LoadBalancers[?Tags[?Key==`Name`].Value[]==`tindaph-alb`].DNSName' --output text
```

## Delete Everything (if needed)

```bash
# Destroy infrastructure
cd infra
terraform destroy -auto-approve

# Delete S3 bucket contents
aws s3 rm s3://gooddevs-devops-base-infra-terraform --recursive
```

## Common Commands

| Task | Command |
|------|---------|
| Restart backend | `aws ecs update-service --cluster tindaph-ecs --service tindaph-backend --force-new-deployment` |
| Restart storefront | `aws ecs update-service --cluster tindaph-ecs --service tindaph-storefront --force-new-deployment` |
| View backend logs | `aws logs tail /ecs/tindaph-backend --follow` |
| Scale backend to 4 | `aws ecs update-service --cluster tindaph-ecs --service tindaph-backend --desired-count 4` |
| SSH into task | `aws ecs execute-command --cluster tindaph-ecs --task <ARN> --container backend --interactive --command="/bin/sh"` |

See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for detailed instructions.