import { createHmac } from "crypto"
import { AbstractPaymentProvider, BigNumber, MedusaError } from "@medusajs/framework/utils"
import {
  AuthorizePaymentInput,
  AuthorizePaymentOutput,
  CancelPaymentInput,
  CancelPaymentOutput,
  CapturePaymentInput,
  CapturePaymentOutput,
  DeletePaymentInput,
  DeletePaymentOutput,
  GetPaymentStatusInput,
  GetPaymentStatusOutput,
  InitiatePaymentInput,
  InitiatePaymentOutput,
  PaymentSessionStatus,
  ProviderWebhookPayload,
  RefundPaymentInput,
  RefundPaymentOutput,
  RetrievePaymentInput,
  RetrievePaymentOutput,
  UpdatePaymentInput,
  UpdatePaymentOutput,
  WebhookActionResult,
} from "@medusajs/framework/types"
import {
  PayRexOptions,
  PayRexPaymentIntent,
  PayRexRefund,
  PayRexSignatureHeader,
  PayRexWebhookEvent,
} from "./types"

class PayRexProviderService extends AbstractPaymentProvider<PayRexOptions> {
  static identifier = "payrex"

  protected secretKey_: string
  protected webhookSecret_: string
  protected captureType_: "automatic" | "manual"
  protected baseUrl_: string

  constructor(container: Record<string, unknown>, options: PayRexOptions) {
    super(container, options)
    this.secretKey_ = options.secretKey
    this.webhookSecret_ = options.webhookSecret
    this.captureType_ = options.captureType ?? "automatic"
    this.baseUrl_ = "https://api.payrexhq.com"
  }

  private authHeader(): string {
    return "Basic " + Buffer.from(`${this.secretKey_}:`).toString("base64")
  }

  private async request<T>(
    path: string,
    method: "GET" | "POST",
    body?: Record<string, unknown>
  ): Promise<T> {
    const url = `${this.baseUrl_}${path}`
    const headers: Record<string, string> = {
      Authorization: this.authHeader(),
      "Content-Type": "application/x-www-form-urlencoded",
    }

    const init: RequestInit = { method, headers }

    if (body && method === "POST") {
      init.body = new URLSearchParams(
        Object.entries(body).flatMap(([k, v]) =>
          typeof v === "object" && v !== null
            ? Object.entries(v as Record<string, string>).map(([mk, mv]) => [
                `${k}[${mk}]`,
                String(mv),
              ])
            : [[k, String(v)]]
        )
      ).toString()
    }

    const response = await fetch(url, init)
    const json = await response.json()

    if (!response.ok) {
      throw new MedusaError(
        MedusaError.Types.UNEXPECTED_STATE,
        `PayRex API error ${response.status}: ${JSON.stringify(json)}`
      )
    }

    return json as T
  }

  async initiatePayment(
    input: InitiatePaymentInput
  ): Promise<InitiatePaymentOutput> {
    const { amount, currency_code } = input

    const intent = await this.request<PayRexPaymentIntent>(
      "/payment_intents",
      "POST",
      {
        amount: String(amount),
        currency: currency_code.toUpperCase(),
        "payment_methods[]": "qrph",
        ...(input.data?.cart_id
          ? { "metadata[cart_id]": String(input.data.cart_id) }
          : {}),
        ...(this.captureType_ === "manual"
          ? { "payment_method_options[card][capture_type]": "manual" }
          : {}),
      }
    )

    return {
      id: intent.id,
      data: intent as unknown as Record<string, unknown>,
    }
  }

  async authorizePayment(
    input: AuthorizePaymentInput
  ): Promise<AuthorizePaymentOutput> {
    const intentId = input.data?.id as string

    if (!intentId) {
      return { status: "error" as PaymentSessionStatus, data: input.data ?? {} }
    }

    const intent = await this.request<PayRexPaymentIntent>(
      `/payment_intents/${intentId}`,
      "GET"
    )

    const status = this.toMedusaStatus(intent.status)

    return {
      status,
      data: intent as unknown as Record<string, unknown>,
    }
  }

  async capturePayment(
    input: CapturePaymentInput
  ): Promise<CapturePaymentOutput> {
    const intent = input.data as unknown as PayRexPaymentIntent
    const intentId = intent?.id

    if (!intentId) {
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        "PayRex: missing payment intent ID for capture"
      )
    }

    if (this.captureType_ === "manual" && intent.status === "awaiting_capture") {
      const captured = await this.request<PayRexPaymentIntent>(
        `/payment_intents/${intentId}/capture`,
        "POST",
        { amount: String(intent.amount) }
      )
      return { data: captured as unknown as Record<string, unknown> }
    }

    return { data: input.data ?? {} }
  }

  async refundPayment(
    input: RefundPaymentInput
  ): Promise<RefundPaymentOutput> {
    const intent = input.data as unknown as PayRexPaymentIntent
    const paymentId = intent?.latest_payment?.id

    if (!paymentId) {
      throw new MedusaError(
        MedusaError.Types.INVALID_DATA,
        "PayRex: missing payment ID for refund (latest_payment not found)"
      )
    }

    const refund = await this.request<PayRexRefund>("/refunds", "POST", {
      amount: String(input.amount),
      currency: "PHP",
      payment_id: paymentId,
      reason: "requested_by_customer",
    })

    return { data: refund as unknown as Record<string, unknown> }
  }

  async cancelPayment(
    input: CancelPaymentInput
  ): Promise<CancelPaymentOutput> {
    const intentId = (input.data as Record<string, unknown>)?.id as string

    if (!intentId) {
      return { data: input.data ?? {} }
    }

    try {
      const cancelled = await this.request<PayRexPaymentIntent>(
        `/payment_intents/${intentId}/cancel`,
        "POST"
      )
      return { data: cancelled as unknown as Record<string, unknown> }
    } catch {
      return { data: input.data ?? {} }
    }
  }

  async retrievePayment(
    input: RetrievePaymentInput
  ): Promise<RetrievePaymentOutput> {
    const intentId = (input.data as Record<string, unknown>)?.id as string

    if (!intentId) {
      return { data: input.data ?? {} }
    }

    const intent = await this.request<PayRexPaymentIntent>(
      `/payment_intents/${intentId}`,
      "GET"
    )

    return { data: intent as unknown as Record<string, unknown> }
  }

  async getPaymentStatus(
    input: GetPaymentStatusInput
  ): Promise<GetPaymentStatusOutput> {
    const intentId = (input.data as Record<string, unknown>)?.id as string

    if (!intentId) {
      return { status: "pending" }
    }

    const intent = await this.request<PayRexPaymentIntent>(
      `/payment_intents/${intentId}`,
      "GET"
    )

    return { status: this.toMedusaStatus(intent.status) }
  }

  async updatePayment(
    input: UpdatePaymentInput
  ): Promise<UpdatePaymentOutput> {
    return { data: input.data ?? {} }
  }

  async deletePayment(
    input: DeletePaymentInput
  ): Promise<DeletePaymentOutput> {
    return this.cancelPayment(input)
  }

  async getWebhookActionAndData(
    payload: ProviderWebhookPayload["payload"]
  ): Promise<WebhookActionResult> {
    const { rawData, headers, data } = payload

    this.verifyWebhookSignature(
      rawData as string,
      headers["payrex-signature"] as string
    )

    const event = data as unknown as PayRexWebhookEvent
    const intent = event.data?.resource as PayRexPaymentIntent

    switch (event.type) {
      case "payment_intent.succeeded":
        return {
          action: "authorized",
          data: {
            session_id: intent.id,
            amount: new BigNumber(intent.amount),
          },
        }

      case "payment_intent.awaiting_capture":
        return {
          action: "authorized",
          data: {
            session_id: intent.id,
            amount: new BigNumber(intent.amount_capturable ?? intent.amount),
          },
        }

      default:
        return {
          action: "not_supported",
          data: {
            session_id: intent?.id ?? "",
            amount: new BigNumber(0),
          },
        }
    }
  }

  private verifyWebhookSignature(rawBody: string, signatureHeader: string): void {
    if (!signatureHeader) {
      throw new MedusaError(
        MedusaError.Types.UNAUTHORIZED,
        "PayRex webhook: missing Payrex-Signature header"
      )
    }

    const parts = signatureHeader.split(",").reduce<Record<string, string>>(
      (acc, part) => {
        const [k, v] = part.split("=")
        acc[k.trim()] = v.trim()
        return acc
      },
      {}
    ) as PayRexSignatureHeader

    const { t, te, li } = parts
    const signedPayload = `${t}.${rawBody}`
    const expected = createHmac("sha256", this.webhookSecret_)
      .update(signedPayload)
      .digest("hex")

    const signature = this.secretKey_.startsWith("sk_test_") ? te : li

    if (expected !== signature) {
      throw new MedusaError(
        MedusaError.Types.UNAUTHORIZED,
        "PayRex webhook: signature verification failed"
      )
    }
  }

  private toMedusaStatus(payrexStatus: string): PaymentSessionStatus {
    switch (payrexStatus) {
      case "succeeded":
        return "authorized"
      case "awaiting_capture":
        return "authorized"
      case "processing":
        return "pending"
      case "awaiting_next_action":
        return "pending"
      case "awaiting_payment_method":
        return "pending"
      case "cancelled":
        return "canceled"
      default:
        return "pending"
    }
  }
}

export default PayRexProviderService
