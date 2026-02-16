[Twisted Petals](https://sb-40gqbkhez496.ai.prod.medusajs.cloud/us)

Cart (0)

``TECHNICAL DOCUMENTATION


# Twisted Petals Store

Complete development documentation showing Claude Code skills, tools, and agents used to build this Medusa 2.0 e-commerce storefront.

[View StoreJump to Skills](https://sb-40gqbkhez496.ai.prod.medusajs.cloud/us/store)


## Architecture Overview

### Frontend

TanStack Start with React

- File-based routing ($param syntax)
- TanStack Query for data fetching
- Tailwind CSS styling
- Medusa JS SDK integration


### Backend

Medusa 2.0 Framework

- Modular commerce architecture
- Workflow-based mutations
- Query.graph for data access
- Built-in commerce modules


### Development

Claude Code AI Assistant

- Skill-based knowledge system
- Task sub-agents for exploration
- MedusaExec for database ops
- Visual verification workflow


## Claude Code Skills

Skills are specialized knowledge modules that contain proven patterns, workflows, and best practices for Medusa implementation. Each skill is loaded before implementing features to ensure consistency and prevent mistakes.


### adding-data-to-medusa

Use when creating products, categories, collections, sales channels, regions, or promotions in Medusa. Contains critical data structures, sales channel requirements, product options patterns, and common pitfalls to avoid.

    # General Guidelines

    Use the examples below for common data operations. Only query MedusaDocs for workflows not documented here.

    **Reference Files Available:**
    - **products.md** - Complete product creation patterns (simple products, variants, fetching prerequisite data)
    - **categories-collections.md** - Categories, collections, tags, and types
    - **regions.md** - Region creation and management
    - **promotions.md** - Promotion and discount patterns

    ## Product Images

    When the user needs to add images to products or associate images with specific variants (e.g., different images per color), load the **working-with-product-images** skill. It covers critical rules for safely updating images, associating images with variants, setting thumbnails, and displaying variant-specific galleries on the storefront.

    ## Products - Critical Rules

    Adding products is a common task the user will often ask you to do. It's important that you do it correctly otherwise the user will not see the product and the experience will be bad.

    **CRITICAL**: ALL products MUST have the `options` array defined, even simple products.
    - Products with meaningful variants (size, color, etc.): Use descriptive options like "Size", "Color"
    - Simple products with no meaningful options: Use "Default option" as the title and "Default option value" in the values array
    - Each variant MUST reference these options in its `options` object
    - Missing options will cause: "Product options are not provided" error

    **ALWAYS follow these rules:**
    1. ALWAYS add products to a sales channel - list the sales channel and pick one - if there are multiple pick one and tell the user that they can add it to more sales channels if necessary. If you don't add it to a sales channel the product will not show up.
    2. ALWAYS create the product with "published" state otherwise the product won't show up. Only create "draft" products if explicitly asked to.
    3. ALWAYS give products prices that match the store's configured currencies.
    4. If the user wants to add a price in an unsupported currency ASK if you should add the currency to the store and which countries should shop in that currency.
    5. Make sure that any image urls you pass have been copied to workspace media using AddWorkspaceMedia

    **For detailed product examples, load the `products.md` reference file.**

    ## Categories, Collections, Types, and Tags

    When the user wants to organize their products you have different options:

    - **Categories** are used for broad categorization of products. This is frequently the base for navigation.
    - **Collections** are typically used for products that launch as part of the same campaign or season - e.g., Autumn/Winter, Spring/Summer.
    - **Tags** are helpful for general purpose feature implementations - e.g., featured products add a "featured" tag. Can be used for filtering and differentiated merchandizing.
    - **Types** are good to classify products that share the same properties - this can be good for determining the layout of a product page, or to determine if an admin customization should be shown or not. E.g., digital product show digital asset upload customization in admin dashboard, clothes show "size and fit" metadata input. Types are also typically used for determining tax rates where applicable. Types should be objective.

    **For detailed examples, load the `categories-collections.md` reference file.**

    ## Regions

    Regions are Medusa's structure for controlling where customers can shop from. A region can consist of one or more countries that will shop in the same currency and have shared properties.

    - A country can only be part of a single Region.
    - When updating a Region's countries you need to pass the entire list of countries that should be part of the region. If you don't it will remove any countries from the region that are not in the list. This is often not what you want to do.

    **For detailed region examples, load the `regions.md` reference file.**

    ## Promotions

    Promotions allow you to create discounts that apply to items, shipping methods, or entire orders.

    **Important notes:**
    - Fixed amounts use full currency units (5 = $5.00, NOT cents)
    - `currency_code` is REQUIRED for `fixed` type promotions
    - For more advanced promotions (buy X get Y, customer group restrictions, product/collection targeting, budgets, campaigns, etc.), ask MedusaDocs for examples

    **For detailed promotion examples, load the `promotions.md` reference file.**

    ## Pickup Options

    When implementing pickup/local fulfillment options:

    1. Create a fulfillment set with type "pickup" (NOT "pickup-local" or any custom type):
       ```typescript
       // Via workflow or admin API:
       // POST /admin/stock-locations/{id}/fulfillment-sets
       // { "name": "Pick-up", "type": "pickup" }
       ```
    2. Create a service zone within that fulfillment set for the applicable geo area.
    3. Create a shipping option in that service zone.

    IMPORTANT: The type MUST be "pickup" for the option to show up correctly in the admin dashboard's Pickup section. Custom types will not be recognized.

    Before creating fulfillment sets, query existing ones first - the stock location may already have one configured.


### designing-storefronts

LOAD THIS when building UI or implementing visual changes. Contains design thinking process to create distinctive frontends that avoid generic AI aesthetics.

    # Designing Storefronts

    This skill guides creation of distinctive, production-grade storefronts that avoid generic "AI slop" aesthetics. Implement real working code with exceptional attention to aesthetic details and creative choices.

    ## Design Thinking

    You tend to converge toward generic, "on distribution" outputs. In frontend design, this creates what users call the "AI slop" aesthetic. Avoid this: make creative, distinctive frontends that surprise and delight.

    Before coding, understand the context and commit to a BOLD aesthetic direction:

    - **Purpose**: What problem does this interface solve? Who is the customer?
    - **Tone - PICK AN EXTREME**: Commit to a direction: brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian. Use these for inspiration but design one true to the brand.
    - **Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?

    **CRITICAL**: Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work - the key is intentionality, not intensity. Timid, middle-ground aesthetics are forgettable.

    ## Frontend Aesthetics Guidelines

    ### Typography

    Choose fonts that are distinctive and characterful. Pair a bold display font with a refined body font.

    Avoid generic fonts like Inter, Roboto, Arial, system fonts. Choose something that elevates the aesthetics; unexpected, and beautiful. Pair a distinctive display font with a refined body font.

    ### Color

    Commit to a cohesive palette. Dominant colors with sharp accents outperform timid, evenly-distributed palettes.
    Use CSS variables for consistency and implement them using Tailwind (when available; check for theme.css files or similar).

    **Contrast**: Text MUST be readable. Light text on light backgrounds or dark text on dark backgrounds = failure.

    When changing a component's background color, check all nested interactive elements (dropdowns, selects, popovers, modals) - they often render their own panels with text colors that won't automatically adapt. A dark footer with a light-text dropdown menu will have unreadable options when the dropdown opens with dark text on its panel.

    NEVER default to: purple gradients on white, safe blue-gray palettes.

    ### Motion

    One well-orchestrated page load with staggered reveals creates more delight than scattered micro-interactions.
    Focus on high-impact moments: scroll-triggered animations, hover states that surprise.
    Use Motion library for React when available or Tailwind Animate.

    ### Spatial Composition

    Unexpected layouts. Asymmetry. Overlap. Grid-breaking elements. Generous negative space OR controlled density - not both half-heartedly.
    In luxury ecommerce experiences lots of negative space is common and gives a great aesthetic. Make sure things align nicely between sections, navbar, footer, etc.

    ### Navigation Styles

    **The navbar sets the tone for the entire site.** You MUST customize it - layout, colors, typography, background behavior. If there's a design reference, match its navbar. Don't leave the navbar as default.

    Use the existing Navbar component to compose custom variants. Update styling of navbar primitives to match the aesthetics.

    #### Layout Variations

    | Layout                      | Structure                                    | Best For                   |
    | --------------------------- | -------------------------------------------- | -------------------------- |
    | **Logo left, links right**  | `[Logo] -------- [Shop] [About] [Cart]`    | Most stores, clean         |
    | **Centered logo**           | `[Shop] [About] - [LOGO] - [Search] [Cart]`| Fashion, luxury, editorial |
    | **Logo left, links center** | `[Logo] - [Shop] [About] [Contact] - [Cart]`| Balanced, professional    |
    | **Minimal**                 | `[Logo] ---------------- [Menu]`           | Ultra-clean, mobile-first  |
    | **Split with CTA**          | `[Logo] [Links] ----- [Shop Now Button]`   | Conversion-focused         |

    #### Background Behaviors

    | Behavior                          | Implementation                               | Best For               |
    | --------------------------------- | -------------------------------------------- | ---------------------- |
    | **Transparent to solid on scroll**| Start transparent, add bg after scrollY > 50 | Full-bleed hero images |
    | **Always solid**                  | Consistent background color                  | Standard stores        |
    | **Blur/glassmorphism**            | `backdrop-blur-md bg-white/80`             | Modern, premium        |
    | **Color matches hero**            | Same bg color as hero section                | Seamless, editorial    |

    ## Working with Design References

    If the user provides a design reference URL or screenshot, use the Task tool with agent type `DesignAnalyzer` to get a detailed specification. This can be used for replication and design adaptation, but MUST not replace the need to still be extremely deliberate and intentional with great design execution.

    Get the `DesignAnalyzer` to provide its description first before you settle on a vision for the site.

    ## Execution

    If this is in the beginning of the conversation you should especially go hard on the design to wow the user. If you end up producing simple generic output the user will be bored and think you are not good, so make an effort to surprise and delight.

    NEVER use generic AI-generated aesthetics like overused font families (Inter, Roboto, Arial, system fonts), cliched color schemes (particularly purple gradients on white backgrounds), predictable layouts and component patterns, and cookie-cutter design that lacks context-specific character.

    Interpret creatively and make unexpected choices that feel genuinely designed for the context. No design should be the same. Vary between light and dark themes, different fonts, different aesthetics. NEVER converge on common choices (Space Grotesk, for example) across generations.

    IMPORTANT: Match implementation complexity to the aesthetic vision. Maximalist designs need elaborate code with extensive animations and effects. Minimalist or refined designs need restraint, precision, and careful attention to spacing, typography, and subtle details. Elegance comes from executing the vision well.

    Remember: Claude is capable of extraordinary creative work. Don't hold back, show what can truly be created when thinking outside the box and committing fully to a distinctive vision.

    Use theme.css for cohesiveness and maintainability.

    ## Known Issues - Icons

    When placing @medusajs/icons inside circular containers, icons may appear off-center because they lack a viewBox attribute in their SVGs. To fix: add the `viewBox="0 0 15 15"` prop directly on the icon component.


### fetching-medusa-product-data

CRITICAL for fetching or querying product data in storefront correctly or understanding product data structures. Contains product fetching patterns, filtering, sorting, and data relationships. Load before you need to implement fetching correctly in storefronts.

    # CRITICAL: Always Use the JS SDK for Product Fetching

    **WARNING:** ALL product requests MUST use the Medusa JS SDK (`@medusajs/js-sdk`). Using regular `fetch` will cause errors because:

    1. **Store API routes** require the publishable API key header
    2. The SDK automatically includes this header in every request
    3. **Regular fetch** will fail with authentication errors without the publishable API key

    **Always use:** `sdk.store.product.list()`, `sdk.store.product.retrieve()`, etc.

    # General Guidelines

    - Products in Medusa are structured with a variant model.
    - A product can have multiple **Product Options**. Each Product Option can have multiple **Product Option Values**. The combination of product option values defines the potential **Product Variants** that can exist.
    - Products have information like title, subtitle, description, images, etc. Each product is also connected to a **Sales Channel**.
    - If you create a product you MUST add it to a Sales Channel otherwise it will be hidden from customers.
    - Variants can have multiple prices. Either currency prices or region prices. You can find out the different currencies enabled for a store by checking the "store" entity.
    - Variants are connected to Inventory Items which are the ones that hold the different Inventory Levels for the product across a set of Stock Locations. You can ask MedusaDocs for more information about this if necessary.
    - When fetching products from the store api (e.g. GET /store/products) Medusa will automatically calculate availability for the products based on the sales channels associated with the publishable api key the request is made with. Prices will also be automatically calculated but you MUST pass the context for this to be enabled specifically region_id, currency_code as query params - if these are not passed and you request prices you will get an error.
    - ALWAYS check for existing product fetching patterns in the codebase. Look for the @medusajs/js-sdk usage to find examples.


### building-with-medusa

LOAD THIS FIRST when implementing custom Medusa features. Contains essential patterns for middleware validation, custom API routes, workflows, SDK usage, and how to query custom data from storefronts and admin customizations.

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


## Tools and Agents

Claude Code uses a comprehensive set of tools to interact with the codebase, generate assets, query documentation, and manage the development workflow. Each tool is designed for specific tasks.


#### Task (Explore Agent)

Codebase Analysis

Launches a sub-agent specialized in codebase exploration. Uses Glob, Grep, and Read tools to find files by patterns, search code for keywords, and understand how different parts of the codebase work.

Usage Example

    Task({ agent_type: "Explore", prompt: "Find all product-related components" })

Capabilities

- Pattern-based file search (Glob)
- Code content search (Grep)
- File reading and analysis
- Parallel independent searches


#### Task (DesignAnalyzer Agent)

Design Analysis

Analyzes design reference URLs to extract colors, typography, spacing, and layout patterns. Uses WebFetch and Screenshot tools internally.

Usage Example

    Task({ agent_type: "DesignAnalyzer", prompt: "Extract branding from https://example.com" })

Capabilities

- Color palette extraction
- Typography analysis
- Spacing and layout patterns
- Brand element identification


#### MedusaExec

Database Operations

Executes scripts against the Medusa server with full access to the Medusa environment. Enables CRUD operations on resources like products, categories, regions, and more.

Usage Example

    MedusaExec({
      script: `
        import { ExecArgs } from "@medusajs/framework/types";
        export default async function({ container }: ExecArgs) {
          const query = container.resolve("query")
          const { data } = await query.graph({
            entity: "product",
            fields: ["*"],
            pagination: { take: 10 }
          })
          console.log(data)
        }
      `,
      reason: "Query products"
    })

Capabilities

- Query.graph for data fetching
- Workflow execution for mutations
- Full container access
- Safe read operations


#### GenerateImage

Asset Generation

Generates images based on text prompts using AI (flux/schnell or flux/dev) and saves them to workspace media for use in storefronts.

Usage Example

    GenerateImage({
      prompt: "A delicate wire flower sculpture, soft pink petals",
      image_size: { width: 1024, height: 1024 },
      quality: "high"
    })

Capabilities

- AI-powered image generation
- Multiple quality modes
- Custom dimensions (512-1920px)
- Automatic workspace storage


#### Screenshot

Visual Verification

Takes screenshots of webpages for visual design analysis, layout verification, and UI comparison. Returns multimodal image output.

Usage Example

    Screenshot({ url: "https://example.com/page", skipCache: true })

Capabilities

- Visual design analysis
- Layout verification
- UI component inspection
- Before/after comparisons


#### Read / Write / Edit

File Operations

Core file manipulation tools. Read accesses files (including images/PDFs), Write creates or overwrites files, Edit performs precise string replacements.

Usage Example

    Read({ file_path: "/workspace/apps/storefront/src/pages/index.tsx" })
    Write({ file_path: "/path/to/file.tsx", content: "..." })
    Edit({ file_path: "/path/to/file.tsx", old_string: "...", new_string: "..." })

Capabilities

- Read any file type
- Line-specific reading (offset/limit)
- Safe file overwrites
- Precise string replacements


#### RunCommand

Command Execution

Executes commands in the sandbox environment. Supports package managers (pnpm, npm, yarn, npx) and git commands with proper security restrictions.

Usage Example

    RunCommand({
      cmd: "npx",
      args: ["tsc", "--noEmit"],
      cwd: "apps/storefront"
    })

Capabilities

- TypeScript compilation checks
- Package installation
- Background process execution (detached)
- Environment variable support


#### Skills

Knowledge Loading

Accesses specialized knowledge for Medusa implementation tasks. Skills contain proven patterns, workflows, and best practices.

Usage Example

    Skills({ action: "load", skill_name: "building-with-medusa" })
    Skills({ action: "load_reference", skill_name: "adding-data-to-medusa", reference: "products.md" })

Capabilities

- Load skill SKILL.md files
- Load reference files
- Access proven patterns
- Implementation best practices


#### MedusaDocs

Documentation

Queries Medusa's documentation agent for specific framework and API information. Best for concise, code-focused answers.

Usage Example

    MedusaDocs({ query: "Show me a code example for creating an admin customization" })

Capabilities

- Framework documentation
- API endpoint references
- Code examples
- Workflow inputs/outputs


#### TodoWrite

Task Management

Creates and manages structured task lists for tracking progress during complex operations.

Usage Example

    TodoWrite({
      todos: [
        { content: "Create component", status: "completed", activeForm: "Creating component" },
        { content: "Add routing", status: "in_progress", activeForm: "Adding routing" }
      ]
    })

Capabilities

- Multi-step task tracking
- Status management (pending/in\_progress/completed)
- Progress visibility
- Organized workflow


#### Glob / Grep

Search

Glob finds files by pattern matching. Grep searches file contents with regex support. Both optimized for codebase exploration.

Usage Example

    Glob({ pattern: "**/*.tsx", path: "apps/storefront/src" })
    Grep({ pattern: "useQuery", path: "apps/storefront", type: "tsx" })

Capabilities

- Fast file pattern matching
- Regex content search
- File type filtering
- Context lines (-A/-B/-C)


#### WebFetch

Web Content

Fetches and extracts content from webpages. Supports markdown, HTML, and branding extraction formats.

Usage Example

    WebFetch({ url: "https://example.com", formats: ["markdown", "branding"] })

Capabilities

- Markdown text extraction
- Full HTML structure
- Branding elements (logos, colors, fonts)
- 1-hour caching


#### AddWorkspaceMedia

Media Management

Saves images or videos to permanent workspace storage from temporary uploads or external URLs.

Usage Example

    AddWorkspaceMedia({ media_url: "https://example.com/image.jpg" })

Capabilities

- Temp to permanent storage
- External URL downloads
- Image and video support
- Workspace database records


## Development Workflow

1


### Research

Load skills, explore codebase with Task agent

2


### Plan

Create todos, outline implementation approach

3


### Implement

Write code, create files in correct order

4


### Verify

Run TypeScript checks, take screenshots

5


### Complete

Mark todos done, summarize changes

Built with Medusa 2.0, TanStack Start, and Claude Code

Twisted Petals - Handcrafted Wire Flower Art

[Twisted Petals](https://sb-40gqbkhez496.ai.prod.medusajs.cloud/us)

Handcrafted fuzzy wire flowers made with love. Forever blooms that never wilt.

United States (USD)


### Shop

- [All Creations](https://sb-40gqbkhez496.ai.prod.medusajs.cloud/us/store)


### Info

- Shipping
- [About Our Craft](https://sb-40gqbkhez496.ai.prod.medusajs.cloud/us/about)
- Custom Orders


### Contact

- hello\@twistedpetals.com
- +1 (555) 123-4567

2026 Twisted Petals. All rights reserved.

[Privacy PolicyTerms of Service](https://sb-40gqbkhez496.ai.prod.medusajs.cloud/)
