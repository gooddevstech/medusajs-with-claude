import { createHmac } from "crypto"
import { medusaIntegrationTestRunner } from "@medusajs/test-utils"
import { Modules } from "@medusajs/framework/utils"

// ─── Test credentials ─────────────────────────────────────────────────────────
const WEBHOOK_SECRET = "whsec_test_e2e_secret"
const SECRET_KEY = "sk_test_e2e_fake_key"
const FAKE_INTENT_ID = "pi_test_e2e_abc123"

// ─── Helpers ──────────────────────────────────────────────────────────────────

/**
 * Produces a valid `payrex-signature` header value for the given raw body.
 * Mirrors the HMAC-SHA256 algorithm in PayRexProviderService.verifyWebhookSignature.
 */
function buildSignatureHeader(rawBody: string): string {
  const t = Math.floor(Date.now() / 1000).toString()
  const sig = createHmac("sha256", WEBHOOK_SECRET)
    .update(`${t}.${rawBody}`)
    .digest("hex")
  return `t=${t},te=${sig},li=dummy`
}

function makeIntentData(
  intentId: string,
  status: string,
  metadata?: Record<string, string>
) {
  return {
    id: intentId,
    resource: "payment_intent",
    amount: 5000,
    amount_capturable: status === "awaiting_capture" ? 5000 : 0,
    amount_received: status === "succeeded" ? 5000 : 0,
    currency: "PHP",
    status,
    payment_methods: ["qrph"],
    client_secret: `${intentId}_secret`,
    livemode: false,
    created_at: 1700000000,
    updated_at: 1700000000,
    ...(metadata ? { metadata } : {}),
  }
}

function makeWebhookEvent(
  intentId: string,
  type = "payment_intent.succeeded",
  metadata?: Record<string, string>
) {
  return {
    id: `evt_${Date.now()}`,
    resource: "event",
    type,
    livemode: false,
    pending_webhooks: 1,
    data: { resource: makeIntentData(intentId, "succeeded", metadata) },
    created_at: 1700000000,
    updated_at: 1700000000,
  }
}

// ─── Test runner ──────────────────────────────────────────────────────────────

jest.setTimeout(120_000)

medusaIntegrationTestRunner({
  inApp: true,
  env: {
    PAYREX_SECRET_KEY: SECRET_KEY,
    PAYREX_WEBHOOK_SECRET: WEBHOOK_SECRET,
  },
  testSuite: ({ api, getContainer }) => {
    describe("POST /webhooks/payrex", () => {
      // ═══════════════════════════════════════════════════════════════════════
      // 1. Signature validation — negative-path tests only.
      //
      // With the in-memory (local) event bus used in integration tests, errors
      // thrown inside the payment subscriber propagate synchronously back to
      // `eventBus.emit`, causing the route to return 400.  This lets us verify
      // that invalid signatures are rejected without needing a real payment
      // session in the DB.
      // ═══════════════════════════════════════════════════════════════════════
      describe("signature validation", () => {
        it("returns 400 when the payrex-signature header is missing", async () => {
          const body = makeWebhookEvent(FAKE_INTENT_ID)

          await expect(
            api.post("/webhooks/payrex", body)
          ).rejects.toMatchObject({ response: { status: 400 } })
        })

        it("returns 400 when the signature value is wrong", async () => {
          const body = makeWebhookEvent(FAKE_INTENT_ID)
          const raw = JSON.stringify(body)

          await expect(
            api.post("/webhooks/payrex", raw, {
              headers: {
                "content-type": "application/json",
                "payrex-signature":
                  "t=9999999999,te=0000000000000000000000000000000000000000000000000000000000000000,li=dummy",
              },
            })
          ).rejects.toMatchObject({ response: { status: 400 } })
        })

        it("returns 400 when the payload is tampered after signing", async () => {
          const body = makeWebhookEvent(FAKE_INTENT_ID)
          const raw = JSON.stringify(body)
          // Signature computed over the correct body …
          const sig = buildSignatureHeader(raw)
          // … but a different body is sent.
          const tampered = { ...body, type: "payment_intent.cancelled" }

          await expect(
            api.post("/webhooks/payrex", JSON.stringify(tampered), {
              headers: {
                "content-type": "application/json",
                "payrex-signature": sig,
              },
            })
          ).rejects.toMatchObject({ response: { status: 400 } })
        })
      })

      // ═══════════════════════════════════════════════════════════════════════
      // 2. Order confirmation
      //
      // Strategy:
      //  a) Mock global.fetch to intercept PayRex API calls so no real
      //     credentials are needed.
      //  b) Create a PaymentCollection + PaymentSession via the Medusa payment
      //     module service.  `createPaymentSession` calls `initiatePayment`
      //     internally, which hits the mocked PayRex API and returns
      //     FAKE_INTENT_ID.  Our service.ts sends the Medusa session UUID as
      //     PayRex metadata so that getWebhookActionAndData can read it back.
      //  c) Send a `payment_intent.succeeded` webhook whose intent resource
      //     carries `metadata.session_id = medusaSessionId`.  The provider's
      //     getWebhookActionAndData reads that field and returns the Medusa
      //     session UUID as session_id for processPaymentWorkflow.
      //  d) Verify the route returned 200 and the session status is "authorized".
      //
      // NOTE: beforeEach (not beforeAll) is used because the test runner tears
      // down the database between tests, so the session must be recreated
      // before each test.
      // ═══════════════════════════════════════════════════════════════════════
      describe("order confirmation", () => {
        const savedFetch = global.fetch
        let medusaSessionId: string

        // provider_id uses the full container key: pp_<identifier>_<moduleId>
        const PROVIDER_ID = "pp_payrex_payrex"

        const payrexFetch = jest.fn(
          (url: RequestInfo | URL, init?: RequestInit) => {
            const urlStr = String(url)

            if (!urlStr.includes("payrexhq.com")) {
              return savedFetch(url as RequestInfo, init)
            }

            // POST /payment_intents  →  initiatePayment
            if (
              urlStr.endsWith("/payment_intents") &&
              init?.method === "POST"
            ) {
              return Promise.resolve(
                new Response(
                  JSON.stringify(
                    makeIntentData(FAKE_INTENT_ID, "awaiting_payment_method")
                  ),
                  {
                    status: 200,
                    headers: { "content-type": "application/json" },
                  }
                )
              )
            }

            // GET /payment_intents/:id  →  authorizePayment
            if (urlStr.includes(`/payment_intents/${FAKE_INTENT_ID}`)) {
              return Promise.resolve(
                new Response(
                  JSON.stringify(makeIntentData(FAKE_INTENT_ID, "succeeded")),
                  {
                    status: 200,
                    headers: { "content-type": "application/json" },
                  }
                )
              )
            }

            return savedFetch(url as RequestInfo, init)
          }
        ) as typeof global.fetch

        // beforeEach instead of beforeAll: the test runner tears down the DB
        // between tests, so the payment collection and session must be
        // recreated fresh for every test in this describe block.
        beforeEach(async () => {
          global.fetch = payrexFetch

          const container = getContainer()
          const paymentModule = container.resolve<any>(Modules.PAYMENT)

          // Create a payment collection (region_id is optional in Medusa v2).
          const [collection] = await paymentModule.createPaymentCollections([
            {
              currency_code: "php",
              amount: 5000,
            },
          ])

          // createPaymentSession calls initiatePayment internally →
          // hits the mocked PayRex API → returns { id: FAKE_INTENT_ID }.
          // Our service.ts sends session_id as PayRex metadata so that
          // getWebhookActionAndData can read intent.metadata.session_id.
          // Medusa stores the session with id = Medusa UUID (not PayRex ID).
          const session = await paymentModule.createPaymentSession(
            collection.id,
            {
              provider_id: PROVIDER_ID,
              currency_code: "php",
              amount: 5000,
              data: {},
            }
          )

          medusaSessionId = session.id
        })

        afterEach(() => {
          global.fetch = savedFetch
        })

        it("returns 200 with a valid payrex-signature", async () => {
          console.log("[DEBUG] medusaSessionId =", medusaSessionId)
          const body = makeWebhookEvent(
            FAKE_INTENT_ID,
            "payment_intent.succeeded",
            { session_id: medusaSessionId }
          )
          const raw = JSON.stringify(body)

          let response: any
          try {
            response = await api.post("/webhooks/payrex", raw, {
              headers: {
                "content-type": "application/json",
                "payrex-signature": buildSignatureHeader(raw),
              },
            })
          } catch (err: any) {
            console.log("[DEBUG] 400 error body:", err.response?.data)
            throw err
          }

          expect(response.status).toBe(200)
        })

        it("authorizes the payment session after payment_intent.succeeded fires", async () => {
          // Re-send the webhook (idempotent) and verify session status afterwards.
          const body = makeWebhookEvent(
            FAKE_INTENT_ID,
            "payment_intent.succeeded",
            { session_id: medusaSessionId }
          )
          const raw = JSON.stringify(body)

          const response = await api.post("/webhooks/payrex", raw, {
            headers: {
              "content-type": "application/json",
              "payrex-signature": buildSignatureHeader(raw),
            },
          })

          expect(response.status).toBe(200)

          // With the local (synchronous) event bus the session update has already
          // happened by the time we reach here.  With Redis it might need a short
          // wait — add one just in case.
          await new Promise((r) => setTimeout(r, 500))

          const container = getContainer()
          const paymentModule = container.resolve<any>(Modules.PAYMENT)
          const sessions = await paymentModule.listPaymentSessions({
            id: [medusaSessionId],
          })

          expect(sessions).toHaveLength(1)
          expect(["authorized", "captured"]).toContain(sessions[0].status)
        })
      })
    })
  },
})
