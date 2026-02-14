# MedusaJS E-commerce Project - Agent Selection Guide

This guide helps you choose the right specialized agent for exploring the MedusaJS e-commerce codebase.

## Available Agents

### 🔍 codebase-locator
**Purpose**: Find WHERE code lives in the repository

**Use when you need to:**
- Locate order processing functionality
- Find authentication middleware
- Discover product catalog implementation
- Identify payment integration code
- Find API routes and endpoints

**Output**: Grouped file paths by category (implementation, tests, config, docs, types)

**Example queries:**
- "Where is the cart checkout logic?"
- "Find all payment provider integrations"
- "Locate the admin dashboard components"

---

### 📖 codebase-analyzer
**Purpose**: Understand HOW code works

**Use when you need to:**
- Trace payment processing workflow
- Understand authentication flow from login to token generation
- Follow data transformations through the order lifecycle
- Analyze product search and filtering logic
- Understand database relationships and migrations

**Output**: Step-by-step code flow with file:line references

**Example queries:**
- "How does the checkout process work end-to-end?"
- "Explain the product variant selection logic"
- "Trace how cart items are persisted to the database"

---

### 🎨 codebase-pattern-finder
**Purpose**: Find similar implementations as templates

**Use when you need to:**
- Find examples of custom API endpoints
- Discover how other modules integrate with MedusaJS
- Learn patterns for custom workflow implementations
- Find examples of admin dashboard customizations
- Understand storefront component patterns

**Output**: Example implementations with usage patterns

**Example queries:**
- "Show me examples of custom payment providers"
- "Find patterns for extending product entities"
- "What are examples of custom admin widgets?"

---

### 🌐 web-search-researcher
**Purpose**: Research external resources and documentation

**Use when you need to:**
- Research MedusaJS v2 features and APIs
- Find Next.js 15 best practices
- Understand Docker deployment strategies
- Learn about PostgreSQL optimization
- Research Redis caching patterns

**Output**: Curated research with sources and links

**Example queries:**
- "What are MedusaJS v2 publishable API key best practices?"
- "How to optimize Next.js for production deployment?"
- "Docker multi-stage builds for Node.js applications"

---

## Recommended Workflow

1. **Start with codebase-locator** to find relevant files
   - Get the lay of the land
   - Identify all related components

2. **Use codebase-analyzer** to understand implementation
   - Trace code execution paths
   - Understand data flow and transformations

3. **Consult codebase-pattern-finder** for examples
   - Find proven patterns to follow
   - Learn from existing implementations

4. **Research with web-search-researcher** for external context
   - Fill knowledge gaps
   - Understand best practices
   - Learn from official documentation

---

## Key Principles

- All agents are **read-only** - they explore but don't modify
- All findings include **exact file references** with line numbers
- Agents work best when spawned in **parallel** for comprehensive research
- Always verify findings by reading the actual code

---

## Project-Specific Context

This is a **MedusaJS v2.13.1 e-commerce platform** with:
- **Backend**: MedusaJS API (Node.js, TypeScript)
- **Database**: PostgreSQL 16
- **Cache**: Redis 7
- **Admin**: Vite-powered dashboard
- **Storefront**: Next.js 15.3.9
- **Infrastructure**: Docker Compose

Key directories:
- `/src` - MedusaJS backend code
- `/storefront` - Next.js storefront
- `/docker-compose.yml` - Service orchestration
- `/PROJECT_SUMMARY.md` - Complete project documentation
