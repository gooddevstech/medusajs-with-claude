Use when creating Medusa Admin dashboard customizations (widgets, routes, UI extensions).

# Medusa Admin Customizations

## Widget vs Route

**Widgets** extend existing pages:
```tsx
import { defineWidgetConfig } from "@medusajs/admin-sdk"
export const config = defineWidgetConfig({
  zone: "product.details.after",
})
```

**Routes** create new pages:
```tsx
import { defineRouteConfig } from "@medusajs/admin-sdk"
export const config = defineRouteConfig({
  label: "Custom Page",
})
```

## SDK Client Setup

```tsx
import Medusa from "@medusajs/js-sdk"
export const sdk = new Medusa({
  baseUrl: "/",
  auth: { type: "jwt" },
})
```

**CRITICAL**: Always use auth.type: "jwt" and "/" as the base URL.

## Design Consistency

Always use Medusa UI's built-in color tokens:
- bg-ui-bg-base, bg-ui-bg-subtle
- text-ui-fg-base, text-ui-fg-subtle