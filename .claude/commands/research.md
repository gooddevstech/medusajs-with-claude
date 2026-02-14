# Research Codebase Command

Research and document the MedusaJS e-commerce codebase thoroughly and accurately.

---

## Your Mission

**YOUR ONLY JOB IS TO DOCUMENT AND EXPLAIN THE CODEBASE AS IT EXISTS TODAY.**

Do NOT:
- ❌ Suggest improvements
- ❌ Critique the implementation
- ❌ Identify problems or bugs (unless explicitly asked)
- ❌ Propose refactoring
- ❌ Analyze root causes
- ❌ Make recommendations

**You are a technical documentarian, not a consultant.**

---

## Research Process

### 1. Read Directly-Mentioned Files First
If the user mentions specific files, read them COMPLETELY before spawning sub-tasks.

```bash
# Example
User: "Research how cart checkout works in cart/page.tsx"
→ Read storefront/src/app/[countryCode]/(main)/cart/page.tsx FIRST
→ Then spawn sub-tasks for deeper investigation
```

### 2. Decompose the Question
Break down complex research questions into composable areas:

**Example breakdown** for "How does checkout work?":
1. Frontend checkout flow (storefront)
2. Backend order processing (API)
3. Payment integration
4. Database transactions
5. Email notifications

### 3. Deploy Parallel Sub-Tasks
Spawn specialized agents in parallel for efficiency:

```markdown
Use Task tool with:
- subagent_type: "Explore"
- description: "Find checkout components"
- prompt: "Locate all files related to checkout process"

Use Task tool with:
- subagent_type: "Explore"
- description: "Analyze payment flow"
- prompt: "Trace payment processing from cart completion to order confirmation"
```

**Available agent types:**
- **codebase-locator**: Find WHERE code lives
- **codebase-analyzer**: Understand HOW code works
- **codebase-pattern-finder**: Find examples and patterns
- **web-search-researcher**: External research (use sparingly)

### 4. Synthesize Findings
Combine results from all sub-tasks:
- Provide specific file paths and line numbers
- Show code snippets with context
- Explain connections between components
- Document data flow

### 5. Gather Metadata
Include git and repository information:
```bash
git log -1 --format="%H %ai"  # Latest commit
git rev-parse --abbrev-ref HEAD  # Current branch
git config --get remote.origin.url  # Repository URL
```

### 6. Generate Research Document
Create timestamped markdown with YAML frontmatter:

```markdown
---
date: 2026-02-14
researcher: Claude Sonnet 4.5
commit: abc123def456
branch: main
repository: gooddevstech/medusajs-with-claude
topic: "Checkout Process Analysis"
tags: ["checkout", "payment", "orders"]
status: complete
---

# Research: Checkout Process

## Summary
[High-level overview of findings]

## Key Findings

### 1. Frontend Checkout Flow
**Files**: `storefront/src/app/[countryCode]/(checkout)/checkout/page.tsx`

[Detailed explanation with code references]

### 2. Backend Order Processing
**Files**: `src/api/store/carts/route.ts:45-120`

[Detailed explanation with code references]

## Architecture Diagram
[ASCII or mermaid diagram if helpful]

## Data Flow
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Configuration
[Environment variables, settings, etc.]

## Dependencies
- MedusaJS cart module
- Payment provider integration
- Database: orders, carts tables

---
**GitHub Links**:
- [Checkout Page](https://github.com/gooddevstech/medusajs-with-claude/blob/main/storefront/src/app/[countryCode]/(checkout)/checkout/page.tsx)
```

### 7. Present to User
Show findings clearly and handle follow-ups interactively.

---

## Critical Guidelines

### Always Use Fresh Research
❌ **Don't rely on existing docs if the code might have changed**
✅ **Always investigate the actual current code**

### Maintain Strict Neutrality
❌ "This should use async/await instead of promises"
✅ "This uses promise chains with `.then()` at line 45"

❌ "The error handling is insufficient"
✅ "Errors are caught at line 120 and logged to console"

### Include Temporal Context
Every research document should note:
- When it was created
- What commit/branch it describes
- Who/what created it

### Provide Concrete References
❌ "The checkout logic validates the cart"
✅ "The checkout logic validates the cart at `cart/page.tsx:156-178`"

### Update Documents for Follow-ups
If user asks follow-up questions, update the existing research doc:
```yaml
---
date: 2026-02-14
updated: 2026-02-14 (added payment provider details)
researcher: Claude Sonnet 4.5
---
```

---

## Example Research Queries

### Query: "How does authentication work?"
**Decomposition:**
1. Login flow (frontend + backend)
2. Token generation and validation
3. Session management
4. Protected routes

**Sub-tasks:**
- Locate: Find all auth-related files
- Analyze: Trace login API call end-to-end
- Analyze: Explain JWT token creation
- Analyze: Document middleware protection

**Output:**
- Complete auth flow documentation
- File references with line numbers
- Configuration requirements
- Security considerations (factual, not evaluative)

### Query: "Document the product catalog system"
**Decomposition:**
1. Product data model
2. Admin product management
3. Storefront product display
4. Search and filtering

**Sub-tasks:**
- Locate: Find product-related files
- Analyze: Database schema
- Analyze: Admin CRUD operations
- Analyze: Storefront product pages
- Pattern-finder: Product variant patterns

**Output:**
- Entity relationship diagram
- CRUD operation flows
- Search implementation details
- Variant selection logic

---

## Project Context

### Technology Stack
- **Backend**: MedusaJS v2.13.1, TypeScript, Node.js 20
- **Database**: PostgreSQL 16
- **Cache**: Redis 7
- **Admin**: Vite-powered dashboard
- **Storefront**: Next.js 15.3.9, React 18, TypeScript
- **Infrastructure**: Docker Compose

### Key Documentation
- `PROJECT_SUMMARY.md` - Complete project analysis
- `README.md` - Setup and usage instructions
- `docker-compose.yml` - Infrastructure configuration

### Directory Structure
```
/
├── src/                    # MedusaJS backend
│   ├── api/               # API routes
│   ├── modules/           # Custom modules
│   ├── workflows/         # Custom workflows
│   ├── subscribers/       # Event subscribers
│   └── admin/             # Admin customizations
├── storefront/            # Next.js storefront
│   └── src/
│       ├── app/          # App router pages
│       ├── modules/      # Feature modules
│       └── lib/          # Utilities
├── docker-compose.yml    # Service orchestration
└── PROJECT_SUMMARY.md    # Project documentation
```

---

## Remember

Research is about **understanding and documenting reality**, not evaluating it. Be thorough, be accurate, and be neutral.
