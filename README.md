# Tindahang AI - The Bloom Shop

An e-commerce platform for an online flower shop, built on [MedusaJS v2](https://medusajs.com) with a [Next.js 15](https://nextjs.org) storefront, deployed to AWS.

## Quick Start (Local Development)

### Prerequisites
- Docker & Docker Compose
- Node.js 20+
- Yarn

### With Docker (recommended)
```bash
# Start all services (Postgres, Redis, Medusa backend, Storefront)
docker compose up --build -d

# Seed the database with demo data
docker compose exec medusa yarn seed

# Generate a publishable API key for the storefront
docker compose exec medusa medusa exec ./src/scripts/create-publishable-key.ts
```

- Backend + Admin: http://localhost:9000
- Storefront: http://localhost:8000
- Admin Dashboard: http://localhost:5173

### Without Docker
```bash
# Backend (requires Postgres + Redis running locally)
cp .env.template .env
# Edit .env with your DATABASE_URL and REDIS_URL
yarn install
yarn dev

# Storefront (in a separate terminal)
cd storefront
cp .env.template .env.local
yarn install
yarn dev
```

## Project Structure

```
src/                    # MedusaJS v2 backend
  api/                  # Custom API routes
  modules/              # Custom commerce modules
  workflows/            # Business logic workflows
  subscribers/          # Event handlers
  scripts/              # Seed & utility scripts
  admin/                # Admin dashboard customizations
storefront/             # Next.js 15 storefront ("The Bloom Shop")
infra/                  # Terraform IaC for AWS deployment
.github/workflows/      # CI/CD pipelines
```

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | MedusaJS v2.13.1, Node.js 20, TypeScript |
| Frontend | Next.js 15, React 19, Tailwind CSS, Medusa JS SDK |
| Database | PostgreSQL 16 |
| Cache & Events | Redis 7 |
| Infrastructure | AWS (ECS Fargate, RDS, ElastiCache, ALB, CloudFront) |
| IaC | Terraform with terraform-aws-modules |
| CI/CD | GitHub Actions, Docker |

## Deployment

This project includes full production infrastructure. See [DEPLOYMENT_README.md](./DEPLOYMENT_README.md) for setup instructions.

**CI/CD triggers:**
- Push to `src/` or `package.json` → deploys backend
- Push to `storefront/` → deploys storefront
- Push to `infra/` → runs Terraform plan + apply

## Testing

```bash
yarn test:unit                    # Unit tests
yarn test:integration:http        # HTTP integration tests
yarn test:integration:modules     # Module integration tests
```

## Documentation

- [DEPLOYMENT_README.md](./DEPLOYMENT_README.md) - Infrastructure & CI/CD overview
- [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md) - Detailed deployment setup
- [QUICKSTART_DEPLOYMENT.md](./QUICKSTART_DEPLOYMENT.md) - Fast-track deployment commands
- [MedusaJS Docs](https://docs.medusajs.com) - Framework documentation

## AI-Assisted Development

This project uses the [medusa-dev Claude Code plugin](https://github.com/medusajs/medusa-claude-plugins) for AI-assisted development with specialized skills and MCP server integration. See [CLAUDE.md](./CLAUDE.md) for project context used by Claude Code.
