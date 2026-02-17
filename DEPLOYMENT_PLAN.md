# Deployment Plan

GitHub Actions CI/CD + Terraform infra + GitHub Secrets

## Confirmed Inputs

- AWS_ACCOUNT_ID: 905418233489
- AWS_REGION: ap-southeast-1
- Domain: tindaph.app
- Backend: ECS Fargate (port 9000) behind ALB — api.tindaph.app
- Admin: Served by backend (built into Medusa container) — admin.tindaph.app (or same ALB path)
- Storefront: ECS Fargate (port 8000) behind ALB — tindaph.app (SSR, NOT static export)
- Infra: Terraform (remote state in existing S3 bucket)
- Secrets: GitHub Secrets in `prod` environment

## 1) High-Level Architecture

```
                    ┌─────────────┐
                    │  Route 53   │
                    │ tindaph.app │
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
     tindaph.app    api.tindaph.app   admin.tindaph.app
              │            │            │
        ┌─────▼─────┐ ┌───▼────┐  ┌───▼────┐
        │ ALB       │ │  ALB   │  │  ALB   │
        │ :443→8000 │ │:443→9000│ │:443→9000│
        └─────┬─────┘ └───┬────┘  └───┬────┘
              │            │            │
     ┌────────▼───┐  ┌────▼─────┐     │
     │ ECS Fargate│  │ECS Fargate│◄────┘
     │ Storefront │  │ Backend  │
     │ (Next.js)  │  │ (Medusa) │
     └────────────┘  └────┬─────┘
                          │
                ┌─────────┼─────────┐
                │         │         │
          ┌─────▼──┐ ┌───▼───┐ ┌──▼───┐
          │RDS PG16│ │Redis 7│ │S3    │
          │        │ │       │ │Media │
          └────────┘ └───────┘ └──────┘
```

Terraform provisions:
- VPC with public + private subnets (2 AZs minimum)
- RDS Postgres 16 (private subnet, multi-AZ optional)
- ElastiCache Redis 7 (private subnet)
- ECR repos: `medusa-backend`, `medusa-storefront`
- ECS Cluster (Fargate) with 2 services: backend + storefront
- ALB with HTTPS listeners (ACM certificate for *.tindaph.app)
- Route53 hosted zone + DNS records
- S3 bucket for media/file uploads (product images)
- CloudFront distribution for S3 media bucket
- IAM roles, security groups, CloudWatch log groups

## 2) GitHub Actions Workflows

### .github/workflows/terraform.yml
- **Triggers:** workflow_dispatch (manual) + push to main (infra/** paths only)
- **Steps:**
  1. Checkout
  2. Configure AWS credentials
  3. hashicorp/setup-terraform
  4. terraform init (S3 backend)
  5. terraform plan (save plan artifact)
  6. terraform apply (requires manual approval via GitHub environment protection)

### .github/workflows/deploy-backend.yml
- **Triggers:** push to main (paths: src/**, package.json, Dockerfile, start.sh)
- **Steps:**
  1. Checkout
  2. Configure AWS credentials, login to ECR
  3. Build backend Docker image (multi-stage production build)
  4. Tag with `$GITHUB_SHA` + `latest`, push to ECR
  5. Run one-off ECS task for database migration (`yarn medusa db:migrate`)
  6. Register new ECS task definition with new image tag
  7. Update ECS backend service (rolling deploy)
  8. Wait for service stability

### .github/workflows/deploy-storefront.yml
- **Triggers:** push to main (paths: storefront/**)
- **Steps:**
  1. Checkout
  2. Configure AWS credentials, login to ECR
  3. Build storefront Docker image (multi-stage production build)
  4. Tag with `$GITHUB_SHA` + `latest`, push to ECR
  5. Register new ECS task definition with new image tag
  6. Update ECS storefront service (rolling deploy)
  7. Wait for service stability

## 3) Terraform Resource Outline

```
infra/
├── providers.tf          # AWS provider, ap-southeast-1
├── backend.tf            # S3 remote state + DynamoDB lock
├── variables.tf          # All input variables
├── terraform.tfvars.example
├── outputs.tf            # ECR URIs, ALB DNS, RDS endpoint, Redis endpoint, S3 bucket
├── vpc.tf                # VPC, 2 public + 2 private subnets, NAT gateway, IGW
├── security-groups.tf    # SGs for ALB, ECS tasks, RDS, Redis
├── acm.tf                # ACM certificate for *.tindaph.app + DNS validation
├── route53.tf            # Hosted zone, A records for api/admin/www → ALB
├── rds.tf                # Postgres 16 instance (private subnet)
├── elasticache.tf        # Redis 7 replication group (private subnet)
├── ecr.tf                # ECR repos (backend + storefront) + lifecycle policies
├── iam.tf                # ECS task execution role, task role, policies
├── alb.tf                # ALB, target groups (backend:9000, storefront:8000), HTTPS listeners, HTTP→HTTPS redirect
├── ecs.tf                # ECS cluster, task definitions, services (backend + storefront)
├── s3-media.tf           # S3 bucket for product images/media uploads
├── cloudfront-media.tf   # CloudFront distribution for media bucket
└── cloudwatch.tf         # Log groups, basic alarms (CPU, 5xx rate)
```

## 4) Docker Images — Production Fixes Needed

### Backend Dockerfile (needs separate migration + start)
Current `start.sh` runs migrations + seed on every boot. For production:
- **Migration:** Run as a one-off ECS task in CI before deploying
- **Seed:** Only run manually or gate behind `RUN_SEED=true` env var
- **CMD:** Should be `yarn medusa start` (not `./start.sh`)
- **Build:** Add `yarn medusa build` step for admin panel

### Storefront Dockerfile (needs production build)
Current Dockerfile runs `yarn dev`. For production:
- Multi-stage build: install deps → `yarn build` → production image with `yarn start`
- Set `NODE_ENV=production`

## 5) Environment Variables

### Backend ECS Task Definition
| Variable | Source |
|---|---|
| `DATABASE_URL` | Constructed from Terraform RDS output |
| `REDIS_URL` | Terraform ElastiCache output |
| `JWT_SECRET` | GitHub Secret → SSM Parameter → ECS |
| `COOKIE_SECRET` | GitHub Secret → SSM Parameter → ECS |
| `STORE_CORS` | `https://tindaph.app` |
| `ADMIN_CORS` | `https://admin.tindaph.app` |
| `AUTH_CORS` | `https://admin.tindaph.app,https://tindaph.app` |
| `NODE_ENV` | `production` |

### Storefront ECS Task Definition
| Variable | Source |
|---|---|
| `MEDUSA_BACKEND_URL` | Internal: `http://backend-alb:9000` or service discovery |
| `NEXT_PUBLIC_MEDUSA_BACKEND_URL` | `https://api.tindaph.app` |
| `NEXT_PUBLIC_BASE_URL` | `https://tindaph.app` |
| `NEXT_PUBLIC_DEFAULT_REGION` | `ph` |
| `NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY` | GitHub Secret |
| `REVALIDATE_SECRET` | GitHub Secret → SSM Parameter → ECS |
| `NODE_ENV` | `production` |

## 6) GitHub Secrets Required

Set in repo Settings → Environments → `prod`:

| Secret | Description |
|---|---|
| `AWS_ACCESS_KEY_ID` | IAM user for CI/CD |
| `AWS_SECRET_ACCESS_KEY` | IAM user for CI/CD |
| `AWS_REGION` | `ap-southeast-1` |
| `AWS_ACCOUNT_ID` | `905418233489` |
| `TF_VAR_db_username` | Postgres username |
| `TF_VAR_db_password` | Postgres password (strong, generated) |
| `TF_VAR_db_name` | `medusa` |
| `MEDUSA_JWT_SECRET` | Random 64-char string |
| `COOKIE_SECRET` | Random 64-char string |
| `NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY` | From Medusa admin |
| `REVALIDATE_SECRET` | Random string for ISR |

## 7) SSL/TLS & DNS

- ACM certificate: `*.tindaph.app` + `tindaph.app` (DNS validation via Route53)
- Route53 records:
  - `tindaph.app` → ALB (storefront target group)
  - `api.tindaph.app` → ALB (backend target group, path or host-based routing)
  - `admin.tindaph.app` → ALB (backend target group, port 9000 serves admin)
  - `media.tindaph.app` → CloudFront (S3 media bucket)

## 8) Deployment Sequence

### First-time setup
1. **Prerequisites:** Ensure S3 bucket `gooddevs-devops-base-infra-terraform` and DynamoDB table `gooddevs-devops-base-infra-terraform-lock` exist
2. **Run terraform.yml** (workflow_dispatch) → provisions all infra
3. **Push backend image** → deploy-backend.yml builds, pushes, runs migration, deploys
4. **Create admin user** → One-off ECS task: `yarn medusa user -e admin@tindaph.app -p <password>`
5. **Seed data** → One-off ECS task: `yarn seed` (run once only)
6. **Push storefront image** → deploy-storefront.yml builds, pushes, deploys
7. **Verify** → Health-check endpoints, test storefront, admin panel

### Subsequent deploys
- Backend changes → push to main triggers deploy-backend.yml (build → migrate → deploy)
- Storefront changes → push to main triggers deploy-storefront.yml (build → deploy)
- Infra changes → push to main (infra/**) or manual workflow_dispatch

### Rollback
- **Backend/Storefront:** Re-register previous task definition (prior image tag) + update service
- **Database:** Migrations are forward-only; test thoroughly before deploying
- **Infra:** `terraform plan` to review, manual `terraform apply` or `terraform destroy` (protected)

## 9) Security Considerations

- RDS and Redis in private subnets only (no public access)
- ECS tasks in private subnets with NAT gateway for outbound
- ALB in public subnets with security group allowing 80/443 only
- Secrets stored in AWS SSM Parameter Store (populated by Terraform from GitHub Secrets)
- ECS task role has least-privilege access (S3 media bucket read/write, SSM read)
- ECR lifecycle policy: keep last 10 images, expire untagged after 7 days
- DB access via ECS Exec (SSM Session Manager) for debugging — no bastion needed

## 10) Monitoring & Scaling

- CloudWatch log groups for backend + storefront ECS tasks
- CloudWatch alarms: CPU > 80%, memory > 80%, ALB 5xx > 5/min
- ECS auto-scaling: target tracking on CPU (target 70%), min 1 / max 4 tasks
- RDS: Enhanced monitoring enabled, storage auto-scaling

## 11) Product Image Migration

Current seed file uses `http://localhost:9000/static/...` URLs. Before go-live:
1. Configure Medusa S3 file provider module (`@medusajs/file-s3`)
2. Upload product images to S3 media bucket
3. Update seed file image URLs to use `https://media.tindaph.app/...`
4. Add `media.tindaph.app` to storefront `next.config.js` remote patterns

## Deliverables

1. Terraform code (all files listed in section 3)
2. GitHub Actions workflows (3 YAML files)
3. Production Dockerfiles (backend + storefront)
4. Production start script for backend (separate from dev start.sh)
