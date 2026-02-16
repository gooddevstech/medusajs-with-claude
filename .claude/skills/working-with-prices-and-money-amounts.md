---
name: working-with-prices-and-money-amounts
description: Use when working with prices, money amounts, or currency formatting in Medusa. Contains critical information about price storage (base units vs cents), currency handling, and common pitfalls.
---

# Prices

- Prices in Medusa are stored as base or major units.
  - For example, a `$20` price is stored as `20`.
- When you seed data in the store, such as products or shipping options, you MUST set the price in the base units. You MUST NOT set the price in the smallest currency unit.

## Critical Rules

**ALWAYS use base/major units:**
- ✅ Correct: `amount: 20` for $20.00
- ✅ Correct: `amount: 10.95` for $10.95
- ❌ Wrong: `amount: 2000` (this would be $2000.00, not $20.00)
- ❌ Wrong: `amount: 1095` (this would be $1095.00, not $10.95)

## Examples

### Product Pricing
```ts
prices: [
  {
    amount: 29.99,  // $29.99
    currency_code: "usd",
  },
  {
    amount: 25,     // €25.00
    currency_code: "eur",
  },
]
```

### Promotion/Discount Amounts
```ts
application_method: {
  type: "fixed",
  value: 5,           // $5.00 off
  currency_code: "usd",
}
```

### Shipping Prices
```ts
prices: [
  {
    amount: 10,       // $10.00 shipping
    currency_code: "usd",
  },
]
```

## Display Formatting

When displaying prices in the storefront, use proper currency formatting:
- Use browser's `Intl.NumberFormat` or library like `dinero.js`
- Include currency symbol
- Respect locale-specific formatting (e.g., €20,00 vs $20.00)