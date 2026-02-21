import { CreateInventoryLevelInput, ExecArgs } from "@medusajs/framework/types";
import {
  ContainerRegistrationKeys,
  Modules,
  ProductStatus,
} from "@medusajs/framework/utils";
import {
  createWorkflow,
  transform,
  WorkflowResponse,
} from "@medusajs/framework/workflows-sdk";
import {
  createApiKeysWorkflow,
  createInventoryLevelsWorkflow,
  createProductCategoriesWorkflow,
  createProductsWorkflow,
  createRegionsWorkflow,
  createSalesChannelsWorkflow,
  createShippingOptionsWorkflow,
  createShippingProfilesWorkflow,
  createStockLocationsWorkflow,
  createTaxRegionsWorkflow,
  linkSalesChannelsToApiKeyWorkflow,
  linkSalesChannelsToStockLocationWorkflow,
  updateStoresStep,
  updateStoresWorkflow,
} from "@medusajs/medusa/core-flows";
import { ApiKey } from "../../.medusa/types/query-entry-points";

const updateStoreCurrencies = createWorkflow(
  "update-store-currencies",
  (input: {
    supported_currencies: { currency_code: string; is_default?: boolean }[];
    store_id: string;
  }) => {
    const normalizedInput = transform({ input }, (data) => {
      return {
        selector: { id: data.input.store_id },
        update: {
          supported_currencies: data.input.supported_currencies.map(
            (currency) => {
              return {
                currency_code: currency.currency_code,
                is_default: currency.is_default ?? false,
              };
            }
          ),
        },
      };
    });

    const stores = updateStoresStep(normalizedInput);

    return new WorkflowResponse(stores);
  }
);

export default async function seedDemoData({ container }: ExecArgs) {
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER);
  const link = container.resolve(ContainerRegistrationKeys.LINK);
  const query = container.resolve(ContainerRegistrationKeys.QUERY);
  const fulfillmentModuleService = container.resolve(Modules.FULFILLMENT);
  const salesChannelModuleService = container.resolve(Modules.SALES_CHANNEL);
  const storeModuleService = container.resolve(Modules.STORE);

  const countries = ["ph"];

  logger.info("Seeding store data...");
  const [store] = await storeModuleService.listStores();
  let defaultSalesChannel = await salesChannelModuleService.listSalesChannels({
    name: "Default Sales Channel",
  });

  if (!defaultSalesChannel.length) {
    // create the default sales channel
    const { result: salesChannelResult } = await createSalesChannelsWorkflow(
      container
    ).run({
      input: {
        salesChannelsData: [
          {
            name: "Default Sales Channel",
          },
        ],
      },
    });
    defaultSalesChannel = salesChannelResult;
  }

  await updateStoreCurrencies(container).run({
    input: {
      store_id: store.id,
      supported_currencies: [
        {
          currency_code: "php",
          is_default: true,
        },
      ],
    },
  });

  await updateStoresWorkflow(container).run({
    input: {
      selector: { id: store.id },
      update: {
        default_sales_channel_id: defaultSalesChannel[0].id,
      },
    },
  });
  logger.info("Seeding region data...");
  await createRegionsWorkflow(container).run({
    input: {
      regions: [
        {
          name: "Philippines",
          currency_code: "php",
          countries: ["ph"],
          payment_providers: ["pp_system_default", "pp_payrex_payrex"],
        },
      ],
    },
  });
  logger.info("Finished seeding regions.");

  logger.info("Seeding tax regions...");
  await createTaxRegionsWorkflow(container).run({
    input: countries.map((country_code) => ({
      country_code,
      provider_id: "tp_system",
    })),
  });
  logger.info("Finished seeding tax regions.");

  logger.info("Seeding stock location data...");
  const { result: stockLocationResult } = await createStockLocationsWorkflow(
    container
  ).run({
    input: {
      locations: [
        {
          name: "Bloom Shop Warehouse",
          address: {
            city: "Makati",
            country_code: "PH",
            address_1: "123 Ayala Avenue",
          },
        },
      ],
    },
  });
  const stockLocation = stockLocationResult[0];

  await updateStoresWorkflow(container).run({
    input: {
      selector: { id: store.id },
      update: {
        default_location_id: stockLocation.id,
      },
    },
  });

  await link.create({
    [Modules.STOCK_LOCATION]: {
      stock_location_id: stockLocation.id,
    },
    [Modules.FULFILLMENT]: {
      fulfillment_provider_id: "manual_manual",
    },
  });

  logger.info("Seeding fulfillment data...");
  const shippingProfiles = await fulfillmentModuleService.listShippingProfiles({
    type: "default",
  });
  let shippingProfile = shippingProfiles.length ? shippingProfiles[0] : null;

  if (!shippingProfile) {
    const { result: shippingProfileResult } =
      await createShippingProfilesWorkflow(container).run({
        input: {
          data: [
            {
              name: "Default Shipping Profile",
              type: "default",
            },
          ],
        },
      });
    shippingProfile = shippingProfileResult[0];
  }

  const fulfillmentSet = await fulfillmentModuleService.createFulfillmentSets({
    name: "Bloom Shop Delivery",
    type: "shipping",
    service_zones: [
      {
        name: "Philippines",
        geo_zones: [
          {
            country_code: "ph",
            type: "country",
          },
        ],
      },
    ],
  });

  await link.create({
    [Modules.STOCK_LOCATION]: {
      stock_location_id: stockLocation.id,
    },
    [Modules.FULFILLMENT]: {
      fulfillment_set_id: fulfillmentSet.id,
    },
  });

  const phZoneId = fulfillmentSet.service_zones[0].id;

  const shippingRules = [
    {
      attribute: "enabled_in_store",
      value: "true",
      operator: "eq",
    },
    {
      attribute: "is_return",
      value: "false",
      operator: "eq",
    },
  ];

  await createShippingOptionsWorkflow(container).run({
    input: [
      // Philippines
      {
        name: "Standard Delivery",
        price_type: "flat",
        provider_id: "manual_manual",
        service_zone_id: phZoneId,
        shipping_profile_id: shippingProfile.id,
        type: {
          label: "Standard",
          description: "Delivery in 3-5 business days.",
          code: "standard",
        },
        prices: [
          {
            currency_code: "php",
            amount: 15000, // PHP 150.00
          },
        ],
        rules: shippingRules,
      },
      {
        name: "Express Delivery",
        price_type: "flat",
        provider_id: "manual_manual",
        service_zone_id: phZoneId,
        shipping_profile_id: shippingProfile.id,
        type: {
          label: "Express",
          description: "Same-day delivery for Metro Manila orders before 2 PM.",
          code: "express",
        },
        prices: [
          {
            currency_code: "php",
            amount: 30000, // PHP 300.00
          },
        ],
        rules: shippingRules,
      },
    ],
  });
  logger.info("Finished seeding fulfillment data.");

  await linkSalesChannelsToStockLocationWorkflow(container).run({
    input: {
      id: stockLocation.id,
      add: [defaultSalesChannel[0].id],
    },
  });
  logger.info("Finished seeding stock location data.");

  logger.info("Seeding publishable API key data...");
  let publishableApiKey: ApiKey | null = null;
  const { data } = await query.graph({
    entity: "api_key",
    fields: ["id"],
    filters: {
      type: "publishable",
    },
  });

  publishableApiKey = data?.[0];

  if (!publishableApiKey) {
    const {
      result: [publishableApiKeyResult],
    } = await createApiKeysWorkflow(container).run({
      input: {
        api_keys: [
          {
            title: "Webshop",
            type: "publishable",
            created_by: "",
          },
        ],
      },
    });

    publishableApiKey = publishableApiKeyResult as ApiKey;
  }

  await linkSalesChannelsToApiKeyWorkflow(container).run({
    input: {
      id: publishableApiKey.id,
      add: [defaultSalesChannel[0].id],
    },
  });
  logger.info("Finished seeding publishable API key data.");

  logger.info("Seeding product categories...");

  const { result: categoryResult } = await createProductCategoriesWorkflow(
    container
  ).run({
    input: {
      product_categories: [
        {
          name: "Tulips",
          description: "Handcrafted fuzzy wire tulips",
          is_active: true,
        },
        {
          name: "Roses",
          description: "Handcrafted fuzzy wire roses for every occasion",
          is_active: true,
        },
        {
          name: "Daisies",
          description: "Cheerful handcrafted daisies to brighten any day",
          is_active: true,
        },
        {
          name: "Craft Flowers",
          description: "Handmade fuzzy wire flowers",
          is_active: true,
        },
        {
          name: "Bouquets",
          description: "Pre-arranged fuzzy wire flower bouquets",
          is_active: true,
        },
      ],
    },
  });

  logger.info("Seeding product data...");

  await createProductsWorkflow(container).run({
    input: {
      products: [
        {
          title: "Tulips",
          category_ids: [
            categoryResult.find((cat) => cat.name === "Tulips")!.id,
          ],
          description:
            "Beautiful tulips, hand-crafted with love. Perfect for brightening any room or as a thoughtful gift.",
          handle: "tulips",
          weight: 200,
          status: ProductStatus.PUBLISHED,
          shipping_profile_id: shippingProfile.id,
          images: [
            {
              url: "http://localhost:9000/static/tulips.jpg",
            },
          ],
          options: [
            {
              title: "Color",
              values: ["Red", "Yellow", "Pink", "White", "Purple"],
            },
            {
              title: "Quantity",
              values: ["10 stems", "20 stems", "30 stems"],
            },
          ],
          variants: [
            {
              title: "Red / 10 stems",
              sku: "TULIP-RED-10",
              options: {
                Color: "Red",
                Quantity: "10 stems",
              },
              prices: [
                {
                  amount: 20000, // PHP 200.00
                  currency_code: "php",
                },
              ],
            },
            {
              title: "Red / 20 stems",
              sku: "TULIP-RED-20",
              options: {
                Color: "Red",
                Quantity: "20 stems",
              },
              prices: [
                {
                  amount: 50000, // PHP 500.00
                  currency_code: "php",
                },
              ],
            },
            {
              title: "Yellow / 10 stems",
              sku: "TULIP-YELLOW-10",
              options: {
                Color: "Yellow",
                Quantity: "10 stems",
              },
              prices: [
                {
                  amount: 20000,
                  currency_code: "php",
                },
              ],
            },
            {
              title: "Pink / 10 stems",
              sku: "TULIP-PINK-10",
              options: {
                Color: "Pink",
                Quantity: "10 stems",
              },
              prices: [
                {
                  amount: 20000,
                  currency_code: "php",
                },
              ],
            },
            {
              title: "White / 10 stems",
              sku: "TULIP-WHITE-10",
              options: {
                Color: "White",
                Quantity: "10 stems",
              },
              prices: [
                {
                  amount: 20000,
                  currency_code: "php",
                },
              ],
            },
            {
              title: "Purple / 10 stems",
              sku: "TULIP-PURPLE-10",
              options: {
                Color: "Purple",
                Quantity: "10 stems",
              },
              prices: [
                {
                  amount: 20000,
                  currency_code: "php",
                },
              ],
            },
          ],
          sales_channels: [
            {
              id: defaultSalesChannel[0].id,
            },
          ],
        },
        {
          title: "Roses",
          category_ids: [
            categoryResult.find((cat) => cat.name === "Roses")!.id,
          ],
          description:
            "Elegant crafted roses, perfect for expressing love, gratitude, or sympathy.",
          handle: "fresh-roses",
          weight: 300,
          status: ProductStatus.PUBLISHED,
          shipping_profile_id: shippingProfile.id,
          images: [
            {
              url: "http://localhost:9000/static/rose.png",
            },
          ],
          options: [
            {
              title: "Color",
              values: ["Red", "Pink", "White", "Yellow"],
            },
            {
              title: "Quantity",
              values: ["12 stems", "24 stems", "36 stems"],
            },
          ],
          variants: [
            {
              title: "Red / 12 stems",
              sku: "ROSE-RED-12",
              options: {
                Color: "Red",
                Quantity: "12 stems",
              },
              prices: [
                {
                  amount: 20000, // PHP 200.00
                  currency_code: "php",
                },
              ],
            },
            {
              title: "Red / 24 stems",
              sku: "ROSE-RED-24",
              options: {
                Color: "Red",
                Quantity: "24 stems",
              },
              prices: [
                {
                  amount: 50000, // PHP 500.00
                  currency_code: "php",
                },
              ],
            },
            {
              title: "Pink / 12 stems",
              sku: "ROSE-PINK-12",
              options: {
                Color: "Pink",
                Quantity: "12 stems",
              },
              prices: [
                {
                  amount: 20000,
                  currency_code: "php",
                },
              ],
            },
            {
              title: "White / 12 stems",
              sku: "ROSE-WHITE-12",
              options: {
                Color: "White",
                Quantity: "12 stems",
              },
              prices: [
                {
                  amount: 20000,
                  currency_code: "php",
                },
              ],
            },
            {
              title: "Yellow / 12 stems",
              sku: "ROSE-YELLOW-12",
              options: {
                Color: "Yellow",
                Quantity: "12 stems",
              },
              prices: [
                {
                  amount: 20000,
                  currency_code: "php",
                },
              ],
            },
          ],
          sales_channels: [
            {
              id: defaultSalesChannel[0].id,
            },
          ],
        },
        {
          title: "Cheerful Daisies",
          category_ids: [
            categoryResult.find((cat) => cat.name === "Daisies")!.id,
          ],
          description:
            "Bright and cheerful daisies that bring joy to any space. Perfect for casual bouquets and everyday celebrations.",
          handle: "cheerful-daisies",
          weight: 150,
          status: ProductStatus.PUBLISHED,
          shipping_profile_id: shippingProfile.id,
          images: [
            {
              url: "http://localhost:9000/static/daisies.jpg",
            },
          ],
          options: [
            {
              title: "Quantity",
              values: ["15 stems", "30 stems"],
            },
          ],
          variants: [
            {
              title: "15 stems",
              sku: "DAISY-15",
              options: {
                Quantity: "15 stems",
              },
              prices: [
                {
                  amount: 20000, // PHP 200.00
                  currency_code: "php",
                },
              ],
            },
            {
              title: "30 stems",
              sku: "DAISY-30",
              options: {
                Quantity: "30 stems",
              },
              prices: [
                {
                  amount: 35000, // PHP 350.00
                  currency_code: "php",
                },
              ],
            },
          ],
          sales_channels: [
            {
              id: defaultSalesChannel[0].id,
            },
          ],
        },
        {
          title: "Fuzzy Wire Flower",
          category_ids: [
            categoryResult.find((cat) => cat.name === "Craft Flowers")!.id,
          ],
          description:
            "Handmade fuzzy wire flowers that last forever. Perfect for crafts, decorations, or as a unique gift. These colorful pipe cleaner flowers never wilt!",
          handle: "fuzzy-wire-flower",
          weight: 50,
          status: ProductStatus.PUBLISHED,
          shipping_profile_id: shippingProfile.id,
          images: [
            {
              url: "http://localhost:9000/static/craft.jpg",
            },
          ],
          options: [
            {
              title: "Color",
              values: ["Rainbow", "Red", "Blue", "Pink", "Yellow", "Purple"],
            },
            {
              title: "Size",
              values: ["Small", "Medium", "Large"],
            },
          ],
          variants: [
            {
              title: "Rainbow / Medium",
              sku: "FUZZY-RAINBOW-M",
              options: {
                Color: "Rainbow",
                Size: "Medium",
              },
              prices: [
                {
                  amount: 10000, // PHP 100.00
                  currency_code: "php",
                },
              ],
            },
            {
              title: "Red / Medium",
              sku: "FUZZY-RED-M",
              options: {
                Color: "Red",
                Size: "Medium",
              },
              prices: [
                {
                  amount: 10000,
                  currency_code: "php",
                },
              ],
            },
            {
              title: "Blue / Medium",
              sku: "FUZZY-BLUE-M",
              options: {
                Color: "Blue",
                Size: "Medium",
              },
              prices: [
                {
                  amount: 10000,
                  currency_code: "php",
                },
              ],
            },
            {
              title: "Pink / Medium",
              sku: "FUZZY-PINK-M",
              options: {
                Color: "Pink",
                Size: "Medium",
              },
              prices: [
                {
                  amount: 10000,
                  currency_code: "php",
                },
              ],
            },
            {
              title: "Rainbow / Large",
              sku: "FUZZY-RAINBOW-L",
              options: {
                Color: "Rainbow",
                Size: "Large",
              },
              prices: [
                {
                  amount: 15000, // PHP 150.00
                  currency_code: "php",
                },
              ],
            },
          ],
          sales_channels: [
            {
              id: defaultSalesChannel[0].id,
            },
          ],
        },
        {
          title: "Bouquet",
          category_ids: [
            categoryResult.find((cat) => cat.name === "Bouquets")!.id,
          ],
          description:
            "A stunning pre-arranged bouquet featuring a mix of seasonal spring flowers including tulips, daisies, and greenery. Wrapped beautifully and ready to gift.",
          handle: "mixed-bouquet",
          weight: 400,
          status: ProductStatus.PUBLISHED,
          shipping_profile_id: shippingProfile.id,
          images: [
            {
              url: "http://localhost:9000/static/bouquet.jpeg",
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
              options: {
                Size: "Standard",
              },
              prices: [
                {
                  amount: 30000, // PHP 300.00
                  currency_code: "php",
                },
              ],
            },
            {
              title: "Deluxe",
              sku: "BOUQUET-SPRING-DLX",
              options: {
                Size: "Deluxe",
              },
              prices: [
                {
                  amount: 50000, // PHP 500.00
                  currency_code: "php",
                },
              ],
            },
            {
              title: "Premium",
              sku: "BOUQUET-SPRING-PRM",
              options: {
                Size: "Premium",
              },
              prices: [
                {
                  amount: 70000, // PHP 700.00
                  currency_code: "php",
                },
              ],
            },
          ],
          sales_channels: [
            {
              id: defaultSalesChannel[0].id,
            },
          ],
        },
      ],
    },
  });
  logger.info("Finished seeding product data.");

  logger.info("Seeding inventory levels.");

  const { data: inventoryItems } = await query.graph({
    entity: "inventory_item",
    fields: ["id"],
  });

  const inventoryLevels: CreateInventoryLevelInput[] = [];
  for (const inventoryItem of inventoryItems) {
    const inventoryLevel = {
      location_id: stockLocation.id,
      stocked_quantity: 1000,
      inventory_item_id: inventoryItem.id,
    };
    inventoryLevels.push(inventoryLevel);
  }

  await createInventoryLevelsWorkflow(container).run({
    input: {
      inventory_levels: inventoryLevels,
    },
  });

  logger.info("Finished seeding inventory levels data.");
  logger.info("✨ Bloom Shop seed data completed successfully!");
}
