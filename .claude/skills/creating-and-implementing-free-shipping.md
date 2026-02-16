Use when implementing free shipping promotions with and without thresholds.

# Free Shipping Implementation

## Medusa Configuration

```typescript
prices: [
  { currency_code: "usd", amount: 10, rules: [] }, // Regular price
  {
    currency_code: "usd",
    amount: 0,
    rules: [{ attribute: "item_total", operator: "gte", value: 100 }]
  } // Free over $100
]
```

## Storefront Display

Create custom API endpoint to get threshold:

1. Accept country_code parameter
2. Find region by country
3. Find service zones for country
4. Get shipping options with prices
5. Find free shipping threshold (amount: 0, item_total rule)
6. Return: has_free_shipping, cart_item_threshold, currency_code