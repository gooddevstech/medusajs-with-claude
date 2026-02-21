# Tindaph AI - E-Commerce Platform

## Project Overview
Tindaph is a production-ready e-commerce platform ("The Bloom Shop" - online flower store) built on MedusaJS v2 with a Next.js storefront, deployed to AWS via Terraform.

## Technical Architecture

### Architecture
```
Route53 (tindaph.app) → ALB (HTTPS/ACM)
  ├── /api/* → Backend ECS (port 9000)
  └── /* → Storefront ECS (port 8000)
Backend → RDS PostgreSQL 16 + ElastiCache Redis 7
Media → S3 → CloudFront CDN
```

### Services Overview

```
┌─────────────────────────────────────────────────┐
│           MedusaJS Docker Environment           │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌─────────────┐      ┌──────────────┐        │
│  │ PostgreSQL  │◄─────┤   Backend    │        │
│  │  (16-alpine)│      │  (Node 20)   │        │
│  └─────────────┘      └──────┬───────┘        │
│                              │                  │
│  ┌─────────────┐             │                 │
│  │    Redis    │◄────────────┤                 │
│  │  (7-alpine) │             │                 │
│  └─────────────┘             │                 │
│                              │                  │
│                       ┌──────▼────────┐        │
│                       │ Admin Dashboard│        │
│                       │   (Vite HMR)  │        │
│                       └───────────────┘        │
│                              │                  │
│                       ┌──────▼────────┐        │
│                       │  Storefront   │        │
│                       │  (Next.js 15) │        │
│                       └───────────────┘        │
└─────────────────────────────────────────────────┘
```

### Technology Stack

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Backend Framework | MedusaJS | 2.13.1 | E-commerce API & business logic |
| Database | PostgreSQL | 16-alpine | Primary data store |
| Cache & Events | Redis | 7-alpine | Caching & event bus |
| Admin UI | Vite | 5.4.14 | Admin dashboard with HMR |
| Storefront | Next.js | 15.3.9 | Customer-facing store |
| Container Runtime | Docker | - | Containerization |
| Orchestration | Docker Compose | - | Multi-container management |
| Package Manager | Yarn | 4.12.0 | Dependency management |
| Base Image | Node.js | 20-alpine | Runtime environment |

### Port Mapping

| Service | Internal Port | External Port | Purpose |
|---------|--------------|---------------|---------|
| Backend API | 9000 | 9000 | REST API endpoints |
| Admin Dashboard | 5173 | 5173 | Vite dev server (HMR) |
| Storefront | 8000 | 8000 | Next.js storefront |
| PostgreSQL | 5432 | 5432 | Database access |
| Redis | 6379 | 6379 | Cache/event bus |

## Project Structure
```
src/                    # MedusaJS backend
  api/                  # Custom API routes (admin/, store/)
  modules/              # Custom Medusa modules
  workflows/            # Custom workflows
  subscribers/          # Event subscribers
  scripts/              # Seed scripts, utility scripts
  jobs/                 # Scheduled jobs
  admin/                # Admin dashboard customizations
storefront/             # Next.js 15 storefront (port 8000)
infra/                  # Terraform IaC (flat structure, no subdirectories)
.github/workflows/      # CI/CD pipelines
```

## Key Commands
```bash
# Local development (Docker)
docker compose up --build -d     # Start all services
docker compose down              # Stop all services

# Backend
yarn dev                         # Start Medusa dev server (port 9000)
yarn build                       # Build for production
yarn seed                        # Seed database with demo data
medusa exec ./src/scripts/seed.ts  # Alt: run seed inside container

# Storefront (from storefront/)
yarn dev                         # Start Next.js dev server (port 8000)
yarn build                       # Build storefront

# Testing
yarn test:unit                   # Unit tests
yarn test:integration:http       # HTTP integration tests
yarn test:integration:modules    # Module integration tests

# Infrastructure (from infra/)
terraform init                   # Initialize providers
terraform validate               # Validate configuration
terraform plan                   # Preview changes
terraform apply                  # Apply changes
```

## Environment Variables
- Backend: see `.env.template` (DATABASE_URL, REDIS_URL, JWT_SECRET, COOKIE_SECRET, CORS settings)
- Storefront: see `storefront/.env.template` (MEDUSA_BACKEND_URL, NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY, Stripe keys)
- Infrastructure: see `infra/variables.tf` (AWS region, project name, DB credentials)

## Conventions
- **Medusa modules:** Follow MedusaJS v2 module pattern (service, models, migrations)
- **API routes:** Place in `src/api/{admin,store}/` following Medusa route conventions
- **Storefront:** Uses Next.js App Router (file-based routing in `storefront/app/`)
- **Infrastructure:** Flat Terraform files in `infra/` (no subdirectories), uses terraform-aws-modules
- **Git:** `main` branch auto-deploys; feature branches for development
- **Docker:** `docker-compose.yml` for local dev; `Dockerfile.prod` for production builds
- **Secrets:** Never commit `.env`, `terraform.tfvars`, or credential files

## Coding Guidelines
- Always use `fetch` when querying an API
- Add TypeScript types to dedicated `types/` folders
- Follow existing code patterns in the repository
- Avoid unnecessary comments in generated code
- Use Medusa workflows (not direct module access) for data operations
- Storefront design: warm craft aesthetic (terracotta, honey, sage, cream palette)

## CI/CD Triggers
- `infra/**` changes → `terraform.yml` (validate + plan + apply)
- `src/**`, `package.json`, `Dockerfile`, `start.sh` → `deploy-backend.yml` (build + migrate + deploy)
- `storefront/**` → `deploy-storefront.yml` (build + deploy)

## Important Notes
- Infra was recently flattened from subdirectories into `infra/` root
- Terraform state uses S3 backend (not Terraform Cloud)
- The storefront is "The Bloom Shop" themed - a flower/bouquet store
- Admin dashboard runs on port 5173 (Vite HMR) during development
- Always use the Medusa MCP server and medusa-dev skills for Medusa-specific work
