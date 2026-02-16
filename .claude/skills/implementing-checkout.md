Use when implementing or modifying checkout flows.

# Checkout Flow

## Key Components

1. **Shipping Information** - Address, shipping method
2. **Billing Information** - Payment method, billing address
3. **Order Review** - Summary, promotions, confirmation

## Best Practices

- Keep flow simple and linear
- Show progress indicators
- Allow editing of previous steps
- Support guest checkout

## CRITICAL: Use JS SDK

```typescript
await sdk.store.cart.update(cartId, { email })
await sdk.store.cart.addShippingMethod(cartId, { option_id })
await sdk.store.payment.initiatePaymentSession(cartId, { provider_id })
await sdk.store.cart.complete(cartId)
```