---
name: implementing-newsletter-features
description: Guide for implementing newsletter subscription features.
---

Guide for implementing newsletter subscription features.

# Newsletter Features

## Implementation Steps

1. **Setup Customer Group** - "Newsletter Subscribers"
2. **Create API Endpoint** - /store/newsletter-signup
3. **Storefront Integration** - Use SDK + React Query

## API Logic

```typescript
// Find or create customer
// Link customer to newsletter group
await linkCustomersToCustomerGroupWorkflow(req.scope).run({
  input: { id: groupId, add: [customerId] }
})
```

## CRITICAL

- MUST use sdk.client.fetch() - regular fetch fails
- Do NOT send emails without user confirmation