export type PayRexOptions = {
  secretKey: string
  webhookSecret: string
  captureType?: "automatic" | "manual"
}

export type PayRexPaymentIntentStatus =
  | "awaiting_payment_method"
  | "awaiting_next_action"
  | "awaiting_capture"
  | "processing"
  | "succeeded"
  | "cancelled"

export type PayRexPaymentMethod = "card" | "gcash" | "maya" | "qrph"

export type PayRexPaymentIntent = {
  id: string
  resource: "payment_intent"
  amount: number
  amount_capturable: number
  amount_received: number
  currency: string
  status: PayRexPaymentIntentStatus
  payment_methods: PayRexPaymentMethod[]
  client_secret: string
  livemode: boolean
  description?: string
  metadata?: Record<string, string>
  latest_payment?: PayRexPayment
  last_payment_error?: Record<string, unknown>
  capture_before_at?: number
  created_at: number
  updated_at: number
}

export type PayRexPayment = {
  id: string
  resource: "payment"
  amount: number
  currency: string
  payment_intent_id: string
  status: string
  livemode: boolean
  created_at: number
  updated_at: number
}

export type PayRexRefund = {
  id: string
  resource: "refund"
  amount: number
  currency: string
  payment_id: string
  reason: string
  status: "pending" | "succeeded" | "failed"
  description?: string
  created_at: number
  updated_at: number
}

export type PayRexWebhookEvent = {
  id: string
  resource: "event"
  type: string
  livemode: boolean
  pending_webhooks: number
  data: {
    resource: PayRexPaymentIntent | Record<string, unknown>
    previous_attributes?: Record<string, unknown>
  }
  created_at: number
  updated_at: number
}

export type PayRexSignatureHeader = {
  t: string
  te: string
  li: string
}
