import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import {
  IEventBusModuleService,
  IPaymentModuleService,
  ProviderWebhookPayload,
} from "@medusajs/framework/types"
import { Modules } from "@medusajs/framework/utils"
import { PaymentWebhookEvents } from "@medusajs/utils"

export async function POST(req: MedusaRequest, res: MedusaResponse) {
  const rawBody =
    (req as unknown as { rawBody: string }).rawBody ?? JSON.stringify(req.body)

  const webhookPayload: ProviderWebhookPayload = {
    provider: "payrex_payrex",
    payload: {
      data: req.body as Record<string, unknown>,
      rawData: rawBody,
      headers: req.headers,
    },
  }

  // Validate the webhook signature synchronously before emitting.
  // getWebhookActionAndData calls verifyWebhookSignature internally and
  // throws MedusaError(UNAUTHORIZED) on failure, which we surface as HTTP 400.
  try {
    const paymentModule =
      req.scope.resolve<IPaymentModuleService>(Modules.PAYMENT)
    await paymentModule.getWebhookActionAndData(webhookPayload)
  } catch (err: unknown) {
    const message =
      err instanceof Error ? err.message : "Webhook signature validation failed"
    res.status(400).send(`Webhook Error: ${message}`)
    return
  }

  // Signature is valid — emit for async processing by the payment subscriber.
  try {
    const eventBus =
      req.scope.resolve<IEventBusModuleService>(Modules.EVENT_BUS)
    await eventBus.emit({
      name: PaymentWebhookEvents.WebhookReceived,
      data: webhookPayload,
    })
  } catch (err: unknown) {
    const message =
      err instanceof Error ? err.message : "Webhook processing failed"
    res.status(400).send(`Webhook Error: ${message}`)
    return
  }

  res.sendStatus(200)
}
