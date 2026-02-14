import { MedusaContainer } from "@medusajs/framework/types"

export default async function createPublishableKey(container: MedusaContainer) {
  const publishableApiKeyModuleService = container.resolve("publishableApiKeyModuleService")
  const salesChannelModuleService = container.resolve("salesChannelModuleService")
  
  // Get the default sales channel
  const [salesChannel] = await salesChannelModuleService.listSalesChannels()
  
  if (!salesChannel) {
    console.log("No sales channel found. Please seed the database first.")
    return
  }
  
  // Check if key already exists
  const existingKeys = await publishableApiKeyModuleService.listPublishableApiKeys({
    title: "Storefront"
  })
  
  if (existingKeys.length > 0) {
    console.log("\nPublishable API Key already exists:")
    console.log(existingKeys[0].id)
    console.log("\nAdd this to storefront/.env.local:")
    console.log(`NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=${existingKeys[0].id}`)
    return
  }
  
  // Create the publishable API key
  const publishableApiKey = await publishableApiKeyModuleService.createPublishableApiKeys({
    title: "Storefront",
    sales_channel_ids: [salesChannel.id]
  })
  
  console.log("\nPublishable API Key created successfully!")
  console.log(publishableApiKey.id)
  console.log("\nAdd this to storefront/.env.local:")
  console.log(`NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY=${publishableApiKey.id}`)
}
