---
name: creating-promotions
description: Use when implementing sales, promotions, discounts, or special offers.
---

Use when implementing sales, promotions, discounts, or special offers.

# Creating Promotions

## Sales vs Discounts

**Sale (Price List):**
- Products get price reduction for limited time
- Shows on product pages with strike-through pricing

**Discount Code:**
- Customer enters code to unlock
- Enables Buy X Get Y, order level discounts, limits

## Promotion Rules

- **target_rules** - Items the promotion can apply to
- **buy_rules** - What needs to be bought (BuyGet)
- **rules** - Global conditions (region, customer group)

## CRITICAL

Always create with `status: "active"` - default is "draft".