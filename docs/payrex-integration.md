# PayRex Payment Integration

PayRex QRPh payment provider for The Bloom Shop (PHP transactions).

## Provider ID

```
pp_payrex_payrex
```

Medusa format: `pp_{module-id}_{service.identifier}` — module registered as `payrex`, service identifier `"payrex"`.

## Architecture

```
Customer selects QRPh at checkout
    ↓
initiatePayment() → POST https://api.payrexhq.com/payment_intents
                 ← { id: "pi_xxx", data: { qr_code, ... } }
    ↓
Storefront shows QR code from paymentSession.data.qr_code
    ↓
Customer scans QR in banking app (BDO, BPI, GCash, Maya, UnionBank…)
    ↓
PayRex → POST /hooks/payment/payrex_payrex  (built-in Medusa endpoint)
    ↓
getWebhookActionAndData() verifies signature → action: "authorized"
    ↓
Medusa auto-completes cart → creates order
    ↓
Storefront polling detects authorized → placeOrder() → /order/confirmed
```

## File Map

### Backend

| File | Purpose |
|------|---------|
| `src/modules/payrex/types.ts` | TypeScript types for PayRex API responses |
| `src/modules/payrex/service.ts` | `AbstractPaymentProvider` — all 9 required methods |
| `src/modules/payrex/index.ts` | `ModuleProvider` export |
| `medusa-config.ts` | Registers provider under `modules.payment.providers` |
| `src/api/store/webhooks/payrex/route.ts` | Optional custom webhook URL (forwards to Medusa EventBus) |

### Storefront

| File | Change |
|------|--------|
| `storefront/src/lib/constants.tsx` | Added `pp_payrex_payrex` to `paymentInfoMap`; added `isPayRex()` helper |
| `storefront/src/modules/checkout/components/payment/index.tsx` | QR code display block when PayRex session is active |
| `storefront/src/modules/checkout/components/payment-button/index.tsx` | `PayRexQRPhButton` — polls cart every 3s, auto-completes on `authorized` |

## Environment Variables

### Backend (`.env` / `.env.local`)

```env
PAYREX_SECRET_KEY=sk_test_...      # From PayRex Dashboard > Developers
PAYREX_WEBHOOK_SECRET=whsec_...    # Generated when registering a webhook
```

### Storefront (`storefront/.env.local`)

```env
NEXT_PUBLIC_PAYREX_PUBLIC_KEY=pk_test_...   # For future PayRexJS embedded form
```

## PayRex API Reference

- **Base URL:** `https://api.payrexhq.com`
- **Auth:** HTTP Basic Auth — `Authorization: Basic base64(secretKey:)`
- **Docs:** https://docs.payrex.com

### Key Endpoints Used

| Method | Endpoint | Used In |
|--------|----------|---------|
| `POST` | `/payment_intents` | `initiatePayment` |
| `GET` | `/payment_intents/:id` | `authorizePayment`, `retrievePayment`, `getPaymentStatus` |
| `POST` | `/payment_intents/:id/capture` | `capturePayment` (manual mode only) |
| `POST` | `/payment_intents/:id/cancel` | `cancelPayment`, `deletePayment` |
| `POST` | `/refunds` | `refundPayment` |

### PaymentIntent Lifecycle

```
awaiting_payment_method → awaiting_next_action → processing → succeeded
                                                     ↓
                                               awaiting_capture  (manual mode)
```

Medusa status mapping:

| PayRex status | Medusa status |
|---------------|---------------|
| `succeeded` | `authorized` |
| `awaiting_capture` | `authorized` |
| `processing` | `pending` |
| `awaiting_next_action` | `pending` |
| `awaiting_payment_method` | `pending` |
| `cancelled` | `canceled` |

## Webhook Setup

### Recommended: Medusa built-in endpoint

Point PayRex webhooks to:

```
https://api.tindaph.app/hooks/payment/payrex_payrex
```

This is Medusa's built-in handler — it validates the signature via `getWebhookActionAndData`, then fires internal events to update payment session status.

### Alternative: Custom endpoint

```
https://api.tindaph.app/store/webhooks/payrex
```

This custom route (`src/api/store/webhooks/payrex/route.ts`) forwards the payload to the same Medusa EventBus mechanism.

### Signature Verification

PayRex sends a `Payrex-Signature` header:

```
Payrex-Signature: t=1680064018,te=abc123,li=def456
```

Verification (implemented in `service.ts#verifyWebhookSignature`):

1. Parse `t`, `te`, `li` from header
2. Compute `HMAC-SHA256("{t}.{rawBody}", webhookSecret)`
3. Compare with `te` (test mode) or `li` (live mode)

### Webhook Events Handled

| PayRex Event | `getWebhookActionAndData` returns | Medusa effect |
|---|---|---|
| `payment_intent.succeeded` | `action: "authorized"` | Completes cart → creates order |
| `payment_intent.awaiting_capture` | `action: "authorized"` | Marks session authorized |
| Everything else | `action: "not_supported"` | No-op |

## Admin Setup (After Deploying)

1. Log in to Admin at `https://api.tindaph.app/app`
2. Navigate to **Settings → Regions → Philippines**
3. Under **Payment Providers**, enable **PayRex**

The seed script (`src/scripts/seed.ts`) also pre-registers `pp_payrex_payrex` for the Philippines region so it works immediately after seeding.

## Storefront UX Flow

1. Customer adds items to cart (PHP region)
2. At checkout, selects **"QRPh (Pay via banking app QR)"**
3. `initiatePaymentSession` is called → PayRex creates a PaymentIntent
4. QR code image from `paymentSession.data.qr_code` is displayed
5. Customer opens their banking app, scans the QR code, and confirms payment
6. Customer clicks **"I have scanned and paid"**
7. Storefront polls `GET /store/carts/:id` every 3 seconds
8. When `paymentSession.status === "authorized"` (set by webhook), `placeOrder()` is called automatically
9. Customer is redirected to order confirmation

**Timeout:** If payment is not detected within 5 minutes, a "Check payment again" button appears.

## Refunds

Refunds reference the `payment_id` from the PaymentIntent's `latest_payment` field (not the intent ID itself). The `refundPayment` method reads `input.data.latest_payment.id`.

Supported refund reasons (mapped to `requested_by_customer` by default):
`fraudulent`, `requested_by_customer`, `product_out_of_stock`, `service_not_provided`, `product_was_damaged`, `service_misaligned`, `wrong_product_received`, `others`

## Extending to Other Payment Methods

To add GCash or Maya in a future phase:

1. In `service.ts#initiatePayment`, change `"payment_methods[]": "qrph"` to `"gcash"` or `"maya"` (or make it configurable via provider options)
2. GCash/Maya are redirect-based — `initiatePayment` will return a `redirect_url` instead of a QR code
3. The storefront would need a redirect handler + callback route for those flows
4. Add separate provider registrations in `medusa-config.ts` with different `id` values if you want GCash and Maya as distinct payment options in the UI

## Testing

### Local test with curl

Simulate a `payment_intent.succeeded` webhook (signature verification is skipped in development if `PAYREX_WEBHOOK_SECRET` is not set or you bypass with a valid test signature):

```bash
curl -X POST http://localhost:9000/hooks/payment/payrex_payrex \
  -H "Content-Type: application/json" \
  -H "Payrex-Signature: t=1234567890,te=test,li=test" \
  -d '{
    "id": "evt_test_123",
    "resource": "event",
    "type": "payment_intent.succeeded",
    "livemode": false,
    "data": {
      "resource": {
        "id": "pi_test_xxx",
        "amount": 50000,
        "currency": "PHP",
        "status": "succeeded"
      }
    }
  }'
```

### Go-live checklist

- [ ] Add live PayRex keys to AWS Secrets Manager / GitHub Secrets
- [ ] Register webhook URL in PayRex Dashboard (`https://api.tindaph.app/hooks/payment/payrex_payrex`)
- [ ] Subscribe to events: `payment_intent.succeeded`, `payment_intent.awaiting_capture`
- [ ] Enable PayRex in Admin → Regions → Philippines
- [ ] Test a live QRPh payment end-to-end
