---
name: building-customer-login
description: Use when building customer accounts and login in the storefront.
---

Use when building customer accounts and login in the storefront.

# Customer Account Implementation

## Route Structure

```
/login, /register, /reset-password
/account, /account/profile, /account/addresses, /account/orders
```

## Registration (Two-Step)

```typescript
// Step 1: Create auth identity
await sdk.auth.register("customer", "emailpass", { email, password })

// Step 2: Create customer record
await sdk.store.customer.create({ email, first_name, last_name })
```

## Login

```typescript
await sdk.auth.login("customer", "emailpass", { email, password })
const { customer } = await sdk.store.customer.retrieve()
```

## Auth Guard Pattern

1. Try sdk.store.customer.retrieve()
2. If 401, redirect to /login
3. If successful, render account layout