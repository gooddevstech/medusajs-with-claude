import { ExecArgs } from "@medusajs/framework/types"
import { Modules } from "@medusajs/framework/utils"
import { ApiKeyType } from "@medusajs/utils"

export default async function createPublishableKey({ container }: ExecArgs) {
  const apiKeyModuleService = container.resolve(Modules.API_KEY) as any
  const salesChannelModuleService = container.resolve(Modules.SALES_CHANNEL) as any

  // Get the default sales channel
  const [salesChannel] = await salesChannelModuleService.listSalesChannels()

  if (!salesChannel) {
    console.log("No sales channel found. Please seed the database first.")
    return
  }

  // Check if publishable key already exists
  const existingKeys = await apiKeyModuleService.listApiKeys({
    title: "Storefront",
    type: ApiKeyType.PUBLISHABLE,
  })

  if (existingKeys.length > 0) {
    console.log("\nPublishable API Key already exists:")
    console.log(existingKeys[0].token)
    console.log("\nAdd this to storefront/.env.local:")
    console.log(`NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=${existingKeys[0].token}`)
    return
  }

  // Create the publishable API key
  const publishableApiKey = await apiKeyModuleService.createApiKeys({
    title: "Storefront",
    type: ApiKeyType.PUBLISHABLE,
    created_by: "seed",
  })

  const key = Array.isArray(publishableApiKey) ? publishableApiKey[0] : publishableApiKey

  console.log("\nPublishable API Key created successfully!")
  console.log(key.token)
  console.log("\nAdd this to storefront/.env.local:")
  console.log(`NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=${key.token}`)
}
