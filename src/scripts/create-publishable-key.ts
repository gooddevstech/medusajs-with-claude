import { ExecArgs } from "@medusajs/framework/types"
import { Modules } from "@medusajs/framework/utils"
import { ApiKeyType } from "@medusajs/utils"
import { linkSalesChannelsToApiKeyWorkflow } from "@medusajs/core-flows"

export default async function createPublishableKey({ container }: ExecArgs) {
  const apiKeyModuleService = container.resolve(Modules.API_KEY) as any
  const salesChannelModuleService = container.resolve(Modules.SALES_CHANNEL) as any

  const [salesChannel] = await salesChannelModuleService.listSalesChannels()

  if (!salesChannel) {
    console.log("No sales channel found. Please seed the database first.")
    return
  }

  const existingKeys = await apiKeyModuleService.listApiKeys({
    type: ApiKeyType.PUBLISHABLE,
  })

  let key = existingKeys[0]

  if (!key) {
    const publishableApiKey = await apiKeyModuleService.createApiKeys({
      title: "Storefront",
      type: ApiKeyType.PUBLISHABLE,
      created_by: "seed",
    })
    key = Array.isArray(publishableApiKey) ? publishableApiKey[0] : publishableApiKey
    console.log("\nPublishable API Key created successfully!")
  } else {
    console.log("\nPublishable API Key already exists:")
  }

  await linkSalesChannelsToApiKeyWorkflow(container).run({
    input: { id: key.id, add: [salesChannel.id] },
  })

  console.log(key.token)
  console.log(`\nNEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=${key.token}`)
  console.log(`\nSales channel linked: ${salesChannel.name} (${salesChannel.id})`)
}
