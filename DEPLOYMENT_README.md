# Deployment Infrastructure & CI/CD Implementation

This repository now includes a complete, production-ready deployment infrastructure for Tindahang e-commerce platform using **Terraform with terraform-aws-modules** and **GitHub Actions**.

## 📋 Documentation Index

Start with these documents in order:

1. **[DEPLOYMENT_PLAN.md](./DEPLOYMENT_PLAN.md)** - High-level architecture, design decisions, and technology choices
2. **[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)** - Detailed setup instructions and operational procedures
3. **[QUICKSTART_DEPLOYMENT.md](./QUICKSTART_DEPLOYMENT.md)** - Fast-track commands for experienced engineers
4. **[DEPLOYMENT_IMPLEMENTATION_SUMMARY.md](./DEPLOYMENT_IMPLEMENTATION_SUMMARY.md)** - What was built and how

## 🚀 Quick Deploy

```bash
# 1. Configure AWS credentials in GitHub Secrets (prod environment)
gh secret set AWS_ACCESS_KEY_ID --body "AKIA..."
gh secret set AWS_SECRET_ACCESS_KEY --body "wJa..."
# ... (see QUICKSTART_DEPLOYMENT.md for all secrets)

# 2. Create S3 backend (one-time setup)
aws s3api create-bucket --bucket gooddevs-devops-base-infra-terraform \
  --region ap-southeast-1 --create-bucket-configuration LocationConstraint=ap-southeast-1

# 3. Deploy infrastructure
git push origin main  # Triggers terraform.yml

# 4. Deploy backend & storefront
# Automatically triggered by pushes to src/ and storefront/
```

## 📁 Project Structure

```
infra/                          # Terraform Infrastructure
├── networking/                 # VPC, Security Groups, ACM, Route53
├── database/                   # RDS, ElastiCache
├── compute/                    # IAM, ECR, ALB, ECS
├── storage/                    # S3, CloudFront
├── monitoring/                 # CloudWatch alarms
├── variables.tf                # Input variables
├── providers.tf                # Providers config
├── outputs.tf                  # Infrastructure outputs
└── terraform.tfvars.example    # Example values

.github/workflows/              # CI/CD Automation
├── terraform.yml               # Infrastructure deployment
├── deploy-backend.yml          # Backend Docker build & ECS deploy
└── deploy-storefront.yml       # Storefront Docker build & ECS deploy

Dockerfile.prod                 # Backend production image
storefront/Dockerfile.prod      # Storefront production image
start-prod.sh                   # Backend production start script
```

## 🔧 Technologies Used

- **Infrastructure:** Terraform with terraform-aws-modules
- **Cloud:** AWS (ECS Fargate, RDS, ElastiCache, ALB, CloudFront, Route53)
- **CI/CD:** GitHub Actions
- **Containerization:** Docker (multi-stage builds)
- **Monitoring:** CloudWatch, SNS

## ✨ Key Features

### Infrastructure as Code
- Complete AWS infrastructure defined in Terraform
- Using terraform-aws-modules for best practices
- Version controlled infrastructure
- Automated validation and planning

### Continuous Integration/Deployment
- Automated infrastructure provisioning
- Automated application building and deployment
- Database migrations automated
- Health check verification
- Automatic rollback on deployment failure

### Security
- Security groups restrict traffic between layers
- Encrypted RDS database
- Redis with auth token
- Secrets stored in AWS Secrets Manager/SSM
- IAM roles with least-privilege access
- HTTPS/TLS for all traffic

### Scalability
- Auto-scaling policies based on CPU utilization
- Load balancing across multiple tasks
- Distributed caching with Redis
- CDN for static media (CloudFront)

### Monitoring
- CloudWatch logs for all services
- Performance alarms (CPU, memory, errors)
- Health checks on load balancer
- Automatic failure detection

## 📊 Architecture Overview

```
Domain (Route53)
    ↓
ACM Certificate (HTTPS)
    ↓
Application Load Balancer
    ↙        ↘
Backend (ECS)  Storefront (ECS)
    ↓          ↓
  :9000      :8000
    ↙        ↘
RDS Postgres  ElastiCache Redis
    ↓
S3 Media Bucket → CloudFront CDN
```

## 🎯 Deployment Workflows

### Infrastructure Changes
```
git push → infra/** → Terraform validation → Plan review → Auto-apply
```

### Backend Changes
```
git push → src/** → Docker build → ECR push → DB migration → ECS deploy
```

### Storefront Changes
```
git push → storefront/** → Docker build → ECR push → ECS deploy
```

## ⚙️ Configuration

### Required GitHub Secrets (prod environment)
- `AWS_ACCESS_KEY_ID` - AWS credentials
- `AWS_SECRET_ACCESS_KEY` - AWS credentials
- `AWS_REGION` - ap-southeast-1
- `AWS_ACCOUNT_ID` - 905418233489
- `TF_VAR_db_password` - Database password
- `MEDUSA_JWT_SECRET` - Auth secret
- `COOKIE_SECRET` - Cookie secret
- `NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY` - Medusa key
- `REVALIDATE_SECRET` - ISR revalidation secret

See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) for detailed setup instructions.

## 📈 Pre-Deployment Checklist

- [x] AWS account created and configured
- [x] IAM user created for CI/CD with appropriate permissions
- [ ] Route53 hosted zone created for tindaph.app
- [x] S3 bucket and DynamoDB table for Terraform state created
- [x] GitHub Secrets configured in prod environment
- [x] SSH/Git configured for repository access
- [ ] Docker login credentials available for local testing

## 🔀 Branching Strategy

- `main` - Production-ready code, auto-deploys
- `infra/implementation` - Infrastructure changes (merge to main to deploy)
- Feature branches for development

## 🗂️ Related Files

- `DEPLOYMENT_PLAN.md` - Architecture and high-level design
- `PROJECT_SUMMARY.md` - Project overview and components
- `README.md` - Main project README

## ❓ Common Tasks

| Task | How |
|------|-----|
| Deploy infrastructure | `git push origin infra/` |
| Deploy backend | `git push origin src/` |
| Deploy storefront | `git push origin storefront/` |
| View Terraform plan | Check GitHub Actions PR comments |
| Rollback backend | Change ECS service task definition |
| Scale services | Update desired count in ECS console or via AWS CLI |
| View logs | `aws logs tail /ecs/tindahang-{backend,storefront}` |

## 🆘 Support

For detailed information, refer to:
- [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) - Comprehensive guide
- [QUICKSTART_DEPLOYMENT.md](./QUICKSTART_DEPLOYMENT.md) - Quick commands
- AWS Documentation: https://docs.aws.amazon.com/
- Terraform Registry: https://registry.terraform.io/

## ✅ Status

Implementation complete and ready for production deployment.

---

**Next Step:** Read [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) to begin deployment setup.