import { ExecArgs } from "@medusajs/framework/types";
import {
  ContainerRegistrationKeys,
  Modules,
  ProductStatus,
} from "@medusajs/framework/utils";
import {
  createInventoryLevelsWorkflow,
  createProductCategoriesWorkflow,
  createProductsWorkflow,
} from "@medusajs/medusa/core-flows";

export default async function seedFlowerProducts({ container }: ExecArgs) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER);
  const query = container.resolve(ContainerRegistrationKeys.QUERY);
  const salesChannelModuleService = container.resolve(Modules.SALES_CHANNEL);
  const fulfillmentModuleService = container.resolve(Modules.FULFILLMENT);

  logger.info("🌸 Seeding Bloom Shop product data...");

  // Get existing sales channel
  const salesChannels = await salesChannelModuleService.listSalesChannels({
    name: "Default Sales Channel",
  });

  if (!salesChannels.length) {
    logger.error("No default sales channel found. Please run full seed first.");
    return;
  }

  const defaultSalesChannel = salesChannels[0];

  // Get existing shipping profile
  const shippingProfiles = await fulfillmentModuleService.listShippingProfiles({
    type: "default",
  });

  if (!shippingProfiles.length) {
    logger.error("No default shipping profile found. Please run full seed first.");
    return;
  }

  const shippingProfile = shippingProfiles[0];

  logger.info("Seeding product categories...");

  const { result: categoryResult } = await createProductCategoriesWorkflow(
    container
  ).run({
    input: {
      product_categories: [
        {
          name: "Tulips",
          description: "tulips in various colors",
          is_active: true,
        },
        {
          name: "Roses",
          description: "Classic roses for every occasion",
          is_active: true,
        },
        {
          name: "Daisies",
          description: "Cheerful daisies to brighten any day",
          is_active: true,
        },
        {
          name: "Craft Flowers",
          description: "Handmade fuzzy wire flowers",
          is_active: true,
        },
        {
          name: "Bouquets",
          description: "Pre-arranged flower bouquets",
          is_active: true,
        },
      ],
    },
  });

  logger.info("Seeding flower products...");

  await createProductsWorkflow(container).run({
    input: {
      products: [
        {
          title: "Tulips",
          category_ids: [
            categoryResult.find((cat) => cat.name === "Tulips")!.id,
          ],
          description:
            "Beautiful tulips, hand-picked from our greenhouse. Perfect for brightening any room or as a thoughtful gift.",
          handle: "fresh-tulips",
          weight: 200,
          status: ProductStatus.PUBLISHED,
          shipping_profile_id: shippingProfile.id,
          images: [
            {
              url: "https://images.unsplash.com/photo-1520763185298-1b434c919102?w=800",
            },
          ],
          options: [
            {
              title: "Color",
              values: ["Red", "Yellow", "Pink", "White", "Purple"],
            },
            {
              title: "Quantity",
              values: ["10 stems", "20 stems"],
            },
          ],
          variants: [
            {
              title: "Red / 10 stems",
              sku: "TULIP-RED-10",
              options: { Color: "Red", Quantity: "10 stems" },
              prices: [
                { amount: 2499, currency_code: "usd" },
                { amount: 2299, currency_code: "eur" },
              ],
            },
            {
              title: "Red / 20 stems",
              sku: "TULIP-RED-20",
              options: { Color: "Red", Quantity: "20 stems" },
              prices: [
                { amount: 4499, currency_code: "usd" },
                { amount: 4199, currency_code: "eur" },
              ],
            },
            {
              title: "Yellow / 10 stems",
              sku: "TULIP-YELLOW-10",
              options: { Color: "Yellow", Quantity: "10 stems" },
              prices: [
                { amount: 2499, currency_code: "usd" },
                { amount: 2299, currency_code: "eur" },
              ],
            },
            {
              title: "Pink / 10 stems",
              sku: "TULIP-PINK-10",
              options: { Color: "Pink", Quantity: "10 stems" },
              prices: [
                { amount: 2499, currency_code: "usd" },
                { amount: 2299, currency_code: "eur" },
              ],
            },
          ],
          sales_channels: [{ id: defaultSalesChannel.id }],
        },
        {
          title: "Roses",
          category_ids: [
            categoryResult.find((cat) => cat.name === "Roses")!.id,
          ],
          description:
            "Elegant long-stem roses, perfect for expressing love, gratitude, or sympathy.",
          handle: "fresh-roses",
          weight: 300,
          status: ProductStatus.PUBLISHED,
          shipping_profile_id: shippingProfile.id,
          images: [
            {
              url: "https://images.unsplash.com/photo-1518895949257-7621c3c786d7?w=800",
            },
          ],
          options: [
            {
              title: "Color",
              values: ["Red", "Pink", "White", "Yellow"],
            },
            {
              title: "Quantity",
              values: ["12 stems", "24 stems"],
            },
          ],
          variants: [
            {
              title: "Red / 12 stems",
              sku: "ROSE-RED-12",
              options: { Color: "Red", Quantity: "12 stems" },
              prices: [
                { amount: 4999, currency_code: "usd" },
                { amount: 4599, currency_code: "eur" },
              ],
            },
            {
              title: "Pink / 12 stems",
              sku: "ROSE-PINK-12",
              options: { Color: "Pink", Quantity: "12 stems" },
              prices: [
                { amount: 4999, currency_code: "usd" },
                { amount: 4599, currency_code: "eur" },
              ],
            },
          ],
          sales_channels: [{ id: defaultSalesChannel.id }],
        },
        {
          title: "Fuzzy Wire Flower",
          category_ids: [
            categoryResult.find((cat) => cat.name === "Craft Flowers")!.id,
          ],
          description:
            "Handmade fuzzy wire flowers that last forever. Perfect for crafts, decorations, or as a unique gift.",
          handle: "fuzzy-wire-flower",
          weight: 50,
          status: ProductStatus.PUBLISHED,
          shipping_profile_id: shippingProfile.id,
          images: [
            {
              url: "https://images.unsplash.com/photo-1563207153-f403bf289096?w=800",
            },
          ],
          options: [
            {
              title: "Color",
              values: ["Rainbow", "Red", "Blue", "Pink"],
            },
            {
              title: "Size",
              values: ["Medium", "Large"],
            },
          ],
          variants: [
            {
              title: "Rainbow / Medium",
              sku: "FUZZY-RAINBOW-M",
              options: { Color: "Rainbow", Size: "Medium" },
              prices: [
                { amount: 1299, currency_code: "usd" },
                { amount: 1199, currency_code: "eur" },
              ],
            },
            {
              title: "Red / Medium",
              sku: "FUZZY-RED-M",
              options: { Color: "Red", Size: "Medium" },
              prices: [
                { amount: 999, currency_code: "usd" },
                { amount: 899, currency_code: "eur" },
              ],
            },
          ],
          sales_channels: [{ id: defaultSalesChannel.id }],
        },
        {
          title: "Mixed Spring Bouquet",
          category_ids: [
            categoryResult.find((cat) => cat.name === "Bouquets")!.id,
          ],
          description:
            "A stunning pre-arranged bouquet featuring a mix of seasonal spring flowers.",
          handle: "mixed-spring-bouquet",
          weight: 400,
          status: ProductStatus.PUBLISHED,
          shipping_profile_id: shippingProfile.id,
          images: [
            {
              url: "https://images.unsplash.com/photo-1497276236755-0f85ba99a126?w=800",
            },
          ],
          options: [
            {
              title: "Size",
              values: ["Standard", "Deluxe", "Premium"],
            },
          ],
          variants: [
            {
              title: "Standard",
              sku: "BOUQUET-SPRING-STD",
              options: { Size: "Standard" },
              prices: [
                { amount: 3999, currency_code: "usd" },
                { amount: 3699, currency_code: "eur" },
              ],
            },
            {
              title: "Deluxe",
              sku: "BOUQUET-SPRING-DLX",
              options: { Size: "Deluxe" },
              prices: [
                { amount: 5999, currency_code: "usd" },
                { amount: 5499, currency_code: "eur" },
              ],
            },
          ],
          sales_channels: [{ id: defaultSalesChannel.id }],
        },
      ],
    },
  });

  logger.info("Finished seeding product data.");

  logger.info("Seeding inventory levels...");

  const { data: inventoryItems } = await query.graph({
    entity: "inventory_item",
    fields: ["id"],
  });

  const { data: stockLocations } = await query.graph({
    entity: "stock_location",
    fields: ["id"],
  });

  if (stockLocations.length > 0 && inventoryItems.length > 0) {
    const inventoryLevels = inventoryItems.map((item: any) => ({
      location_id: stockLocations[0].id,
      stocked_quantity: 1000,
      inventory_item_id: item.id,
    }));

    await createInventoryLevelsWorkflow(container).run({
      input: { inventory_levels: inventoryLevels },
    });
  }

  logger.info("✨ Bloom Shop flower products seeded successfully!");
}
