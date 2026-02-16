---
name: building-with-medusa
description: LOAD THIS FIRST when implementing custom Medusa features. Contains essential patterns for middleware validation, custom API routes, workflows, SDK usage, and how to query custom data from storefronts and admin customizations.
---

# Building with Medusa - Standard Patterns

This skill contains the foundational patterns used across all Medusa custom implementations. Load this skill before implementing any custom features.

**Note:** For admin dashboard UI customizations (widgets, routes, admin components), load the `building-admin-dashboard-customizations` skill instead.

## Medusa Architecture Quick Reference

**Building blocks:**

- **Triggers** - Entry points: API routes (`/api`), subscribers (events), scheduled jobs (cron)
- **Workflows** - Orchestrate mutations with automatic rollbacks
- **Modules** - Encapsulated domain logic with data models (built-in: Product, Customer, Cart, Order, etc.)
- **Links** - Connect entities across modules for cross-module queries

**Tools:**

- **query.graph** - Query entities and join data across linked modules
- **Middlewares** - `validateAndTransformBody`, `validateAndTransformQuery`, `authenticate`
- **Error handling** - `MedusaError` with types: `NOT_FOUND`, `INVALID_DATA`, `UNAUTHORIZED`, etc.
- **Built-in services** - Cache, Notifications (email, SMS), File (upload/storage)

**Key conventions:**

- Use workflows for mutations (create/update/delete)
- Use `query.graph()` for reading data
- Validate inputs with middlewares
- Handle errors with `MedusaError`
- Storefronts consume `/store` endpoints, admin consumes `/admin` endpoints

## Custom API Endpoints

### Path Conventions & Authentication

Custom API endpoints extend Medusa's functionality with custom business logic. The implementation and consumption patterns differ based on whether the endpoint is for storefront or admin dashboard use.

**Store Endpoints (Storefront)**

- **Path prefix**: Always use `/store/<rest-of-path>` for endpoints consumed by the storefront
- **Examples**: `/store/newsletter-signup`, `/store/custom-search`, `/store/loyalty-points`
- **Authentication**: The Medusa SDK automatically includes the publishable API key header
- **Backend URL**: Configured when initializing `@medusajs/js-sdk` (typically from env var like `NEXT_PUBLIC_MEDUSA_BACKEND_URL`)

**Admin Endpoints (Dashboard)**

- **Path prefix**: Always use `/admin/<rest-of-path>` for endpoints consumed by the admin dashboard
- **Examples**: `/admin/custom-reports`, `/admin/bulk-operations`, `/admin/analytics`
- **Authentication**: The Medusa SDK automatically includes authentication headers (bearer token or session)
- **Backend URL**: Configured when initializing `@medusajs/js-sdk` in the admin application

**Key Points:**

- The SDK's `sdk.client.fetch()` automatically handles authentication headers and uses the configured Backend URL
- Always use the correct path prefix (`/store/` or `/admin/`)
- The Backend URL is specified when initializing the `@medusajs/js-sdk` instance
- Follow RESTful conventions for endpoint design

### Middleware Validation

Always validate request bodies using Zod schemas and the `validateAndTransformBody` middleware:

```typescript
// api/store/[feature]/middlewares.ts
import { MiddlewareRoute, validateAndTransformBody } from "@medusajs/framework"
import { z } from "zod"

const MySchema = z.object({
  email: z.string().email(),
  // other fields
})

export const myMiddlewares: MiddlewareRoute[] = [
  {
    matcher: "/store/my-endpoint",
    method: "POST",
    middlewares: [validateAndTransformBody(MySchema)],
  },
]
```

Then register in `api/middlewares.ts`:

```typescript
import { defineMiddlewares } from "@medusajs/framework/http"
import { myMiddlewares } from "./store/[feature]/middlewares"

export default defineMiddlewares({
  routes: [...myMiddlewares],
})
```

### API Route Structure

NOTE: Medusa uses only GET, POST and DELETE as a convention. GET for reads, POST for mutations (create/update). Don't use PUT or PATCH.

```typescript
// api/store/my-endpoint/route.ts
import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"

export async function POST(req: MedusaRequest, res: MedusaResponse) {
  const { field } = req.validatedBody
  const query = req.scope.resolve("query")

  // Your implementation here

  return res.status(200).json({ message: "Success" })
}
```

### Error Handling

Use `MedusaError` for consistent error responses:

```typescript
import { MedusaError } from "@medusajs/framework/utils"

// Not found
throw new MedusaError(MedusaError.Types.NOT_FOUND, "Resource not found")

// Invalid data
throw new MedusaError(MedusaError.Types.INVALID_DATA, "Invalid input")

// Other error types: UNAUTHORIZED, CONFLICT, etc.
```

## Using Workflows in API Routes

Workflows are the standard way to perform mutations (create, update, delete) in modules in Medusa.

```typescript
// Example
import { createCustomersWorkflow } from "@medusajs/medusa/core-flows"

export async function POST(req: MedusaRequest, res: MedusaResponse) {
  const { email } = req.validatedBody

  const { result } = await createCustomersWorkflow(req.scope).run({
    input: {
      customersData: [
        {
          email,
          has_account: false,
        },
      ],
    },
  })

  return res.json({ customer: result[0] })
}
```

**Common workflows:**

- See adding-data-to-medusa skill for common workflows
- For other workflows, ask MedusaDocs for specific workflow names and inputs

## Query Pattern

Use `query.graph()` to fetch data across modules:

```typescript
const query = req.scope.resolve("query")

const { data: items } = await query.graph({
  entity: "entity_name", // product, customer, customer_group, etc.
  fields: ["id", "name", "email"],
  filters: {
    email: "user@example.com",
  },
})
```

**Common entities:**

- `product`, `product_variant`, `product_category`
- `customer`, `customer_group`
- `region`, `shipping_option`
- `order`, `cart`

**Filtering examples:**

```typescript
// Exact match
filters: { email: "user@example.com" }

// Multiple values
filters: { id: ["id1", "id2"] }

// Range
filters: {
  created_at: {
    $gte: startDate,
    $lte: endDate
  }
}

// Like (text search)
filters: {
  name: { $like: "%search%" }
}
```

# Building with Medusa - Standard Patterns

This skill contains the foundational patterns used across all Medusa custom implementations. Load this skill before implementing any custom features.

**Note:** For admin dashboard UI customizations (widgets, routes, admin components), load the `building-admin-dashboard-customizations` skill instead.

## Medusa Architecture Quick Reference

**Building blocks:**

- **Triggers** - Entry points: API routes (`/api`), subscribers (events), scheduled jobs (cron)
- **Workflows** - Orchestrate mutations with automatic rollbacks
- **Modules** - Encapsulated domain logic with data models (built-in: Product, Customer, Cart, Order, etc.)
- **Links** - Connect entities across modules for cross-module queries

**Tools:**

- **query.graph** - Query entities and join data across linked modules
- **Middlewares** - `validateAndTransformBody`, `validateAndTransformQuery`, `authenticate`
- **Error handling** - `MedusaError` with types: `NOT_FOUND`, `INVALID_DATA`, `UNAUTHORIZED`, etc.
- **Built-in services** - Cache, Notifications (email, SMS), File (upload/storage)

**Key conventions:**

- Use workflows for mutations (create/update/delete)
- Use `query.graph()` for reading data
- Validate inputs with middlewares
- Handle errors with `MedusaError`
- Storefronts consume `/store` endpoints, admin consumes `/admin` endpoints

## Custom API Endpoints

### Path Conventions & Authentication

Custom API endpoints extend Medusa's functionality with custom business logic. The implementation and consumption patterns differ based on whether the endpoint is for storefront or admin dashboard use.

**Store Endpoints (Storefront)**

- **Path prefix**: Always use `/store/<rest-of-path>` for endpoints consumed by the storefront
- **Examples**: `/store/newsletter-signup`, `/store/custom-search`, `/store/loyalty-points`
- **Authentication**: The Medusa SDK automatically includes the publishable API key header
- **Backend URL**: Configured when initializing `@medusajs/js-sdk` (typically from env var like `NEXT_PUBLIC_MEDUSA_BACKEND_URL`)

**Admin Endpoints (Dashboard)**

- **Path prefix**: Always use `/admin/<rest-of-path>` for endpoints consumed by the admin dashboard
- **Examples**: `/admin/custom-reports`, `/admin/bulk-operations`, `/admin/analytics`
- **Authentication**: The Medusa SDK automatically includes authentication headers (bearer token or session)
- **Backend URL**: Configured when initializing `@medusajs/js-sdk` in the admin application

### Middleware Validation

Always validate request bodies using Zod schemas and the `validateAndTransformBody` middleware:

```typescript
// api/store/[feature]/middlewares.ts
import { MiddlewareRoute, validateAndTransformBody } from "@medusajs/framework"
import { z } from "zod"

const MySchema = z.object({
  email: z.string().email(),
  // other fields
})

export const myMiddlewares: MiddlewareRoute[] = [
  {
    matcher: "/store/my-endpoint",
    method: "POST",
    middlewares: [validateAndTransformBody(MySchema)],
  },
]
```

Then register in `api/middlewares.ts`:

```typescript
import { defineMiddlewares } from "@medusajs/framework/http"
import { myMiddlewares } from "./store/[feature]/middlewares"

export default defineMiddlewares({
  routes: [...myMiddlewares],
})
```

### API Route Structure

NOTE: Medusa uses only GET, POST and DELETE as a convention. GET for reads, POST for mutations (create/update). Don't use PUT or PATCH.

```typescript
// api/store/my-endpoint/route.ts
import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"

export async function POST(req: MedusaRequest, res: MedusaResponse) {
  const { field } = req.validatedBody
  const query = req.scope.resolve("query")

  // Your implementation here

  return res.status(200).json({ message: "Success" })
}
```

### Error Handling

Use `MedusaError` for consistent error responses:

```typescript
import { MedusaError } from "@medusajs/framework/utils"

// Not found
throw new MedusaError(MedusaError.Types.NOT_FOUND, "Resource not found")

// Invalid data
throw new MedusaError(MedusaError.Types.INVALID_DATA, "Invalid input")

// Other error types: UNAUTHORIZED, CONFLICT, etc.
```

## Using Workflows in API Routes

Workflows are the standard way to perform mutations (create, update, delete) in modules in Medusa.

```typescript
// Example
import { createCustomersWorkflow } from "@medusajs/medusa/core-flows"

export async function POST(req: MedusaRequest, res: MedusaResponse) {
  const { email } = req.validatedBody

  const { result } = await createCustomersWorkflow(req.scope).run({
    input: {
      customersData: [
        {
          email,
          has_account: false,
        },
      ],
    },
  })

  return res.json({ customer: result[0] })
}
```

## Creating workflows

If you have built a custom module and need to perform mutations on models in the module you should create a workflow.

```typescript
// src/workflows/create-my-model.ts
import {
  createStep,
  StepResponse,
  createWorkflow,
  WorkflowResponse,
} from "@medusajs/framework/workflows-sdk"

type Input = {
  my_key: string
}

// Note: a step should only do one mutation this ensures rollback mechanisms work
// For workflows that retry build your steps to be idempotent
const createMyModelStep = createStep(
  "create-my-model",
  async (input: Input, { container }) => {
    const myModule = container.resolve("my")

    const [newMy] = await myModule.createMyModels({
      ...input,
    })

    return new StepResponse(
      newMy,
      newMy.id // explicit compensation input
    )
  },
  // Optional compensation function
  async (id, { container }) => {
    const myModule = container.resolve("my")
    await myModule.deleteMyModels(id)
  }
)

const createMyModel = createWorkflow(
  "create-my-model",
  function (input: Input) {
    const newMy = createMyModelStep(input)

    return new WorkflowResponse({
      myNew,
    })
  }
)

export default createMyModel
```

## Custom Modules

A module is a reusable package of functionalities related to a single domain or integration. Modules contain data models (database tables) and a service class that provides methods to manage them.

### When to Create a Custom Module

- **New domain concepts**: Brands, wishlists, reviews, loyalty points
- **Third-party integrations**: ERPs, CMSs, custom services
- **Isolated business logic**: Features that don't fit existing commerce modules

### Module Structure

```
src/modules/blog/
|-- models/
|   |-- post.ts          # Data model definitions
|-- service.ts           # Main service class
|-- index.ts             # Module definition export
```

### Creating a Module

**1. Create the data model** in `src/modules/[name]/models/`:

```typescript
// src/modules/blog/models/post.ts
import { model } from "@medusajs/framework/utils"

const Post = model.define("post", {
  id: model.id().primaryKey(),
  title: model.text(),
  content: model.text().nullable(),
  published: model.boolean().default(false),
})

export default Post
```

**2. Create the service** in `src/modules/[name]/service.ts`:

```typescript
// src/modules/blog/service.ts
import { MedusaService } from "@medusajs/framework/utils"
import Post from "./models/post"

class BlogModuleService extends MedusaService({
  Post,
}) {}

export default BlogModuleService
```

**3. Export the module definition** in `src/modules/[name]/index.ts`:

```typescript
// src/modules/blog/index.ts
import BlogModuleService from "./service"
import { Module } from "@medusajs/framework/utils"

export default Module("blog", {
  service: BlogModuleService,
})
```

**4. Register in medusa-config.ts**:

```typescript
// medusa-config.ts
module.exports = defineConfig({
  // ...
  modules: [{ resolve: "./src/modules/blog" }],
})
```

**5. Generate and run migrations**:

```bash
npx medusa db:generate blog
npx medusa db:migrate
```

## Data Models

Data models represent tables in the database. Use Medusa's Data Model Language (DML) to define them.

### Property Types

```typescript
import { model } from "@medusajs/framework/utils"

const MyModel = model.define("my_model", {
  // Primary key (required)
  id: model.id().primaryKey(),

  // Text
  name: model.text(),
  description: model.text().nullable(),

  // Numbers
  quantity: model.number(),
  price: model.bigNumber(), // For high precision

  // Boolean
  is_active: model.boolean().default(true),

  // Enum
  status: model.enum(["draft", "published", "archived"]).default("draft"),

  // Date/Time
  published_at: model.dateTime().nullable(),

  // JSON (for flexible data)
  metadata: model.json().nullable(),

  // Array
  tags: model.array().nullable(),
})
```

## Module Links

Module links create associations between data models in different modules while maintaining module isolation. Use links to connect your custom models to Commerce Module models (products, customers, orders, etc.).

### Defining a Link

Create link files in `src/links/`:

```typescript
// src/links/product-brand.ts
import { defineLink } from "@medusajs/framework/utils"
import ProductModule from "@medusajs/medusa/product"
import BrandModule from "../modules/brand"

export default defineLink(
  ProductModule.linkable.product,
  BrandModule.linkable.brand
)
```

After defining, sync links to create the database table:

```bash
npx medusa db:migrate
```

### Managing Links

Use the `link` utility to create and manage links between records:

```typescript
import { ContainerRegistrationKeys } from "@medusajs/framework/utils"

const link = container.resolve(ContainerRegistrationKeys.LINK)

// Create a link
await link.create({
  product: { product_id: "prod_123" },
  brand: { brand_id: "brand_456" },
})

// Dismiss (remove) a link
await link.dismiss({
  product: { product_id: "prod_123" },
  brand: { brand_id: "brand_456" },
})
```

## Query Pattern

Use `query.graph()` to fetch data across modules:

```typescript
const query = req.scope.resolve("query")

const { data: items } = await query.graph({
  entity: "entity_name", // product, customer, customer_group, etc.
  fields: ["id", "name", "email"],
  filters: {
    email: "user@example.com",
  },
})
```

**Common entities:**

- `product`, `product_variant`, `product_category`
- `customer`, `customer_group`
- `region`, `shipping_option`
- `order`, `cart`

## Frontend SDK Pattern

### CRITICAL: Always Use the JS SDK for Backend Requests

**WARNING:** ALL requests to the Medusa backend MUST use the Medusa JS SDK (`@medusajs/js-sdk`). Using regular `fetch` or other HTTP clients will cause authentication errors.

**Why the SDK is required:**

1. **Store API routes** (`/store/*`) require the publishable API key header - the SDK adds this automatically
2. **Admin API routes** (`/admin/*`) require authentication headers (bearer token/session) - the SDK adds these automatically
3. **Regular fetch** does NOT include these headers, causing authentication failures

### Using sdk.client.fetch() (Custom Endpoints)

ALWAYS use `sdk.client.fetch()` for ALL API calls from the storefront. Never create custom fetch utilities or use raw `fetch()`.

```typescript
import { sdk } from "[LOCATE SDK INSTANCE IN PROJECT]"

const result = await sdk.client.fetch("/store/my-endpoint", {
  method: "POST",
  body: {
    email: "user@example.com",
  },
})
```

## React Query Pattern

Use `useQuery` for GET requests and `useMutation` for POST/DELETE. **ALWAYS use the SDK** in the query/mutation functions:

```typescript
import { sdk } from "[LOCATE SDK INSTANCE IN PROJECT]"
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query"

function MyComponent({ userId }: { userId: string }) {
  const queryClient = useQueryClient()

  // GET request - fetching data using SDK
  const { data, isLoading } = useQuery({
    queryKey: ["my-data", userId],
    queryFn: () => sdk.client.fetch(`/store/my-endpoint?userId=${userId}`),
    enabled: !!userId,
  })

  // POST request - mutation with cache invalidation using SDK
  const mutation = useMutation({
    mutationFn: (input: { email: string }) =>
      sdk.client.fetch("/store/my-endpoint", { method: "POST", body: input }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["my-data"] })
    },
  })

  if (isLoading) return <p>Loading...</p>

  return (
    <div>
      <p>{data?.title}</p>
      <button
        onClick={() => mutation.mutate({ email: "test@example.com" })}
        disabled={mutation.isPending}
      >
        {mutation.isPending ? "Loading..." : "Submit"}
      </button>
    </div>
  )
}
```

## Common Imports

```typescript
// API Routes
import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { MedusaError } from "@medusajs/framework/utils"

// Workflows
import {
  createCustomersWorkflow,
  linkCustomersToCustomerGroupWorkflow,
} from "@medusajs/medusa/core-flows"

// Middleware
import { MiddlewareRoute, validateAndTransformBody } from "@medusajs/framework"
import { z } from "zod"
```

## Existing commerce modules

Medusa has built-in commerce modules that contain core commerce logic:

- API Key Module
- Auth Module
- Cart Module
- Currency Module
- Customer Module
- Fulfillment Module
- Inventory Module
- Order Module
- Payment Module
- Pricing Module
- Product Module
- Promotion Module
- Region Module
- Sales Channel Module
- Stock Location Module
- Store Module
- Tax Module
- User Module