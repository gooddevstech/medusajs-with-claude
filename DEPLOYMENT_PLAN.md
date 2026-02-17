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
- Default VPC + public subnets (no custom VPC, no NAT gateway — cost savings)
- RDS Postgres 16 (public subnet, access restricted via security group)
- ElastiCache Redis 7 (public subnet, access restricted via security group)
- ECR repos: `medusa-backend`, `medusa-storefront`
- ECS Cluster (Fargate) with 2 services: backend + storefront (public subnets, public IP)
- ALB with HTTPS listeners (ACM certificate for *.tindaph.app)
- Route53 hosted zone + DNS records
- S3 bucket for media/file uploads (product images)
- CloudFront distribution for S3 media bucket
- IAM roles, security groups, CloudWatch log groups

> **Cost note:** Using default VPC with public subnets avoids NAT gateway costs (~$32/mo per AZ). Security is enforced via security groups — only the ALB accepts public traffic; RDS/Redis SGs only allow inbound from the ECS task SG.

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

## 3) Terraform Resource Outline (Using terraform-aws-modules)

All modules are sourced from [terraform-aws-modules](https://github.com/orgs/terraform-aws-modules/repositories):

```
infra/
├── providers.tf              # AWS provider, ap-southeast-1
├── backend.tf                # S3 remote state + DynamoDB lock
├── variables.tf              # All input variables
├── terraform.tfvars.example  # Example values
├── outputs.tf                # ECR URIs, ALB DNS, RDS endpoint, Redis endpoint, S3 bucket
│
├── networking/
│   ├── vpc.tf                # Module: terraform-aws-modules/vpc/aws
│   │                          # Manages VPC, public subnets, IGW, route tables
│   ├── security-groups.tf    # Module: terraform-aws-modules/security-group/aws (×4)
│   │                          # ALB SG, ECS task SG, RDS SG, Redis SG
│   ├── acm.tf                # ACM certificate for *.tindaph.app + DNS validation (Route53)
│   └── route53.tf            # Route53 hosted zone + DNS records for api/admin/www/media → ALB/CloudFront
│
├── database/
│   ├── rds.tf                # Module: terraform-aws-modules/rds/aws
│   │                          # Postgres 16 instance (public subnet, SG-restricted)
│   └── elasticache.tf        # Manual: Redis 7 replication group (public subnet, SG-restricted)
│                              # [Note: elasticache module available at terraform-aws-modules/elasticache/aws]
│
├── compute/
│   ├── ecr.tf                # ECR repos (backend + storefront) + lifecycle policies
│   ├── iam.tf                # ECS task execution role, task role, policies
│   ├── ecs.tf                # Module: terraform-aws-modules/ecs/aws
│   │                          # ECS cluster, task definitions, services (backend + storefront)
│   └── alb.tf                # Module: terraform-aws-modules/alb/aws
│                              # ALB, target groups (backend:9000, storefront:8000), HTTPS listeners
│
├── storage/
│   ├── s3-media.tf           # Module: terraform-aws-modules/s3-bucket/aws
│   │                          # S3 bucket for product images/media uploads with versioning, encryption
│   └── cloudfront-media.tf   # Module: terraform-aws-modules/cloudfront/aws
│                              # CloudFront distribution for S3 media bucket with caching
│
└── monitoring/
    └── cloudwatch.tf         # CloudWatch log groups, alarms (CPU, memory, 5xx rate)
```

### Module References

| Component | Module | Repository |
|---|---|---|
| VPC & Networking | `terraform-aws-modules/vpc/aws` | [github.com/terraform-aws-modules/terraform-aws-vpc](https://github.com/terraform-aws-modules/terraform-aws-vpc) |
| Security Groups | `terraform-aws-modules/security-group/aws` | [github.com/terraform-aws-modules/terraform-aws-security-group](https://github.com/terraform-aws-modules/terraform-aws-security-group) |
| Application Load Balancer | `terraform-aws-modules/alb/aws` | [github.com/terraform-aws-modules/terraform-aws-alb](https://github.com/terraform-aws-modules/terraform-aws-alb) |
| ECS (Cluster & Services) | `terraform-aws-modules/ecs/aws` | [github.com/terraform-aws-modules/terraform-aws-ecs](https://github.com/terraform-aws-modules/terraform-aws-ecs) |
| RDS Database | `terraform-aws-modules/rds/aws` | [github.com/terraform-aws-modules/terraform-aws-rds](https://github.com/terraform-aws-modules/terraform-aws-rds) |
| S3 Bucket | `terraform-aws-modules/s3-bucket/aws` | [github.com/terraform-aws-modules/terraform-aws-s3-bucket](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket) |
| ElastiCache | `terraform-aws-modules/elasticache/aws` | [github.com/terraform-aws-modules/terraform-aws-elasticache](https://github.com/terraform-aws-modules/terraform-aws-elasticache) |
| CloudFront | `terraform-aws-modules/cloudfront/aws` | [github.com/terraform-aws-modules/terraform-aws-cloudfront](https://github.com/terraform-aws-modules/terraform-aws-cloudfront) |

### Example Module Usage

**VPC Module** (`networking/vpc.tf`):
```hcl
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "tindahang-vpc"
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.available.names
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway = false  # Cost savings: use public subnets only, SG for security
  enable_vpn_gateway = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "production"
    Project     = "tindahang"
  }
}
```

**ALB Module** (`compute/alb.tf`):
```hcl
module "alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name            = "tindahang-alb"
  load_balancer_type = "application"
  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.alb_sg.security_group_id]

  # HTTPS listeners with ACM certificate
  https_listeners = [
    {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = aws_acm_certificate.main.arn
      action_type     = "forward"
      target_group_index = 0  # storefront
    }
  ]

  # HTTP → HTTPS redirect
  http_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  target_groups = [
    {
      name        = "storefront-tg"
      backend_protocol = "HTTP"
      backend_port = 8000
      target_type  = "ip"
      health_check = {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        interval            = 30
        path                = "/"
        matcher             = "200"
      }
    },
    {
      name        = "backend-tg"
      backend_protocol = "HTTP"
      backend_port = 9000
      target_type  = "ip"
      health_check = {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        interval            = 30
        path                = "/admin"
        matcher             = "200-399"
      }
    }
  ]

  tags = {
    Environment = "production"
    Project     = "tindahang"
  }
}
```

**ECS Module** (`compute/ecs.tf`):
```hcl
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  version = "~> 5.0"

  name = "tindahang-ecs"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "DEFAULT"
    }
  }

  # Backend service
  services = {
    backend = {
      cpu    = 512
      memory = 1024
      container_definitions = {
        backend = {
          image  = "${aws_ecr_repository.backend.repository_url}:latest"
          port_mappings = [
            {
              name          = "backend"
              containerPort = 9000
              hostPort      = 9000
              protocol      = "tcp"
            }
          ]
          environment = [
            { name = "DATABASE_URL", value = aws_db_instance.postgres.endpoint },
            { name = "REDIS_URL", value = aws_elasticache_replication_group.redis.configuration_endpoint_address },
            # ... other env vars
          ]
          log_configuration = {
            logDriver = "awslogs"
            options = {
              "awslogs-group"         = aws_cloudwatch_log_group.backend.name
              "awslogs-region"        = var.aws_region
              "awslogs-stream-prefix" = "ecs"
            }
          }
        }
      }
      load_balancer = [
        {
          target_group_arn = module.alb.target_group_arns[1]
          container_name   = "backend"
          container_port   = 9000
        }
      ]
      desired_count = 2
      deployment_configuration = {
        maximum_percent         = 200
        minimum_healthy_percent = 100
      }
    },
    # storefront service similarly configured
  }

  tags = {
    Environment = "production"
    Project     = "tindahang"
  }
}
```

**RDS Module** (`database/rds.tf`):
```hcl
module "rds" {
  source = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = "tindahang-postgres"

  engine               = "postgres"
  engine_version       = "16"
  family               = "postgres16"
  major_engine_version = "16"
  instance_class       = "db.t3.micro"

  allocated_storage = 100
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = 5432

  vpc_security_group_ids = [module.rds_sg.security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
  publicly_accessible    = false

  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"

  enabled_cloudwatch_logs_exports = ["postgresql"]
  create_cloudwatch_log_group     = true

  skip_final_snapshot = false
  final_snapshot_identifier = "tindahang-postgres-final-snapshot"

  tags = {
    Environment = "production"
    Project     = "tindahang"
  }
}
```

**S3 Module** (`storage/s3-media.tf`):
```hcl
module "s3_media" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = "tindahang-media-${data.aws_caller_identity.current.account_id}"

  versioning = {
    enabled = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  lifecycle_rule = [
    {
      id     = "keep-versions"
      status = "Enabled"
      
      noncurrent_version_expiration = {
        days = 30
      }
    }
  ]

  tags = {
    Environment = "production"
    Project     = "tindahang"
  }
}
```

**CloudFront Module** (`storage/cloudfront-media.tf`):
```hcl
module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"
  version = "~> 3.0"

  enabled = true
  is_ipv6_enabled = true

  origin = {
    s3_bucket = {
      domain_name = module.s3_media.s3_bucket_bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = aws_cloudfront_origin_access_identity.s3_oai.etag
      }
    }
  }

  default_cache_behavior = {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3_bucket"
    compress         = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values = {
      query_string = false
      cookies = {
        forward = "none"
      }
    }
  }

  viewer_certificate = {
    acm_certificate_arn      = aws_acm_certificate.cloudfront.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  domain_name_aliases = ["media.tindaph.app"]

  tags = {
    Environment = "production"
    Project     = "tindahang"
  }
}
```

### Key Benefits of Module-Based Approach

1. **Reduced Code:** ~60-70% less Terraform code compared to raw resource definitions
2. **Best Practices:** Modules follow AWS Well-Architected best practices and recommendations
3. **Consistency:** Standardized naming, tagging, and resource configuration across the infrastructure
4. **Maintainability:** Regular updates from terraform-aws-modules team address security patches and new features
5. **Reusability:** Modules can be easily imported into other projects with minimal changes
6. **Documentation:** Extensive module documentation and examples available on each module's GitHub repository

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

- All resources in default VPC public subnets — security enforced via security groups:
  - ALB SG: inbound 80/443 from 0.0.0.0/0
  - ECS SG: inbound from ALB SG only (on ports 9000/8000)
  - RDS SG: inbound 5432 from ECS SG only
  - Redis SG: inbound 6379 from ECS SG only
- RDS `publicly_accessible = false` (no public endpoint despite public subnet)
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
