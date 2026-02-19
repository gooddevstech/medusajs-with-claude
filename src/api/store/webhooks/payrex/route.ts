import { MedusaRequest, MedusaResponse } from "@medusajs/framework/http"
import { IEventBusModuleService } from "@medusajs/framework/types"
import { Modules } from "@medusajs/framework/utils"
import { PaymentWebhookEvents } from "@medusajs/utils"

export async function POST(req: MedusaRequest, res: MedusaResponse) {
  try {
    const eventBus = req.scope.resolve<IEventBusModuleService>(Modules.EVENT_BUS)

    await eventBus.emit({
      name: PaymentWebhookEvents.WebhookReceived,
      data: {
        provider: "payrex_payrex",
        payload: {
          data: req.body,
          rawData: (req as unknown as { rawBody: string }).rawBody ?? JSON.stringify(req.body),
          headers: req.headers,
        },
      },
    })
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "Webhook processing failed"
    res.status(400).send(`Webhook Error: ${message}`)
    return
  }

  res.sendStatus(200)
}
