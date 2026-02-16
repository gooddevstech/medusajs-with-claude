# Claude Agent Configuration

This directory contains specialized agent configurations and commands for Claude Code to effectively work with the MedusaJS e-commerce codebase.

## Other details not yet added to this readme file
Architecture Overview
Frontend
TanStack Start with React

File-based routing ($param syntax)
TanStack Query for data fetching
Tailwind CSS styling
Medusa JS SDK integration
Backend
Medusa 2.0 Framework

Modular commerce architecture
Workflow-based mutations
Query.graph for data access
Built-in commerce modules
Development
Claude Code AI Assistant

Skill-based knowledge system
Task sub-agents for exploration
MedusaExec for database ops
Visual verification workflow



Claude Code Skills
Skills are specialized knowledge modules that contain proven patterns, workflows, and best practices for Medusa implementation. Each skill is loaded before implementing features to ensure consistency and prevent mistakes.

skills/adding-data-to-medusa
Use when creating products, categories, collections, sales channels, regions, or promotions in Medusa. Contains critical data structures, sales channel requirements, product options patterns, and common pitfalls to avoid.

skills/designing-storefronts
LOAD THIS when building UI or implementing visual changes. Contains design thinking process to create distinctive frontends that avoid generic AI aesthetics.

skills/fetching-medusa-product-data
CRITICAL for fetching or querying product data in storefront correctly or understanding product data structures. Contains product fetching patterns, filtering, sorting, and data relationships. Load before you need to implement fetching correctly in storefronts.

skills/building-with-medusa
LOAD THIS FIRST when implementing custom Medusa features. Contains essential patterns for middleware validation, custom API routes, workflows, SDK usage, and how to query custom data from storefronts and admin customizations.


## 📁 Directory Structure

```
.claude/
├── agents/           # Specialized agent definitions
│   ├── README.md            # Agent selection guide
│   ├── codebase-locator.md  # File location agent
│   └── codebase-analyzer.md # Code analysis agent
├── commands/         # Command templates
│   └── research.md          # Research codebase command
├── skills/           # Claude Code Skills
│   └── adding-data-to-medusa.md 
│   └── designing-storefronts.md 
│   └── fetching-medusa-product-data.md 
│   └── building-with-medusa.md 
└── README.md         # This file
```

## 🤖 Available Agents

### Codebase Locator
**Purpose**: Find WHERE code lives
**Use for**: Locating files, discovering components, mapping code organization

Example: "Where is the cart checkout logic?"

### Codebase Analyzer
**Purpose**: Understand HOW code works
**Use for**: Tracing execution flows, understanding implementation details

Example: "How does the payment processing workflow work?"

## 📝 Available Commands

### Research
**Purpose**: Comprehensive codebase investigation
**Use for**: Deep dives into features, architecture analysis, documentation

Example: "Research the complete checkout process from cart to order confirmation"

## 🚀 How to Use

### Using Agents

Agents are specialized sub-processes that focus on specific tasks:

```bash
# In Claude Code, spawn an agent:
Use the Task tool with subagent_type="Explore"
Description: "Find checkout files"
Prompt: "Locate all files related to the checkout process"
```

### Using Commands

Commands are invoked directly in conversation:

```
/research "How does authentication work in the storefront?"
```

## 📚 Project Context

This configuration is optimized for:

**Technology Stack**:
- MedusaJS v2.13.1 (Backend)
- Next.js 15.3.9 (Storefront)
- PostgreSQL 16 (Database)
- Redis 7 (Cache)
- Docker Compose (Infrastructure)

**Key Directories**:
- `/src` - MedusaJS backend
- `/storefront` - Next.js storefront
- `/docker-compose.yml` - Service configuration

## 🎯 Best Practices

1. **Start Simple**: Use codebase-locator first to map the territory
2. **Go Deep**: Use codebase-analyzer to understand implementation
3. **Document Findings**: Create research documents for complex investigations
4. **Stay Neutral**: Agents document reality, not opinions
5. **Be Specific**: Provide clear, focused questions

## 📖 Learning Resources

- `/PROJECT_SUMMARY.md` - Complete project documentation
- `/README.md` - Setup and usage guide
- MedusaJS Docs: https://docs.medusajs.com
- Next.js Docs: https://nextjs.org/docs

## 🔗 References

Based on the official MedusaJS Claude configuration:
https://github.com/medusajs/medusa/tree/develop/.claude

Adapted for this specific MedusaJS e-commerce implementation with Docker.

---

**Note**: These agents are read-only and designed for exploration and documentation. They do not modify code or suggest changes unless explicitly requested.
