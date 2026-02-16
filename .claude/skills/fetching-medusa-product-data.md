---
name: fetching-medusa-product-data
description: CRITICAL for fetching or querying product data in storefront correctly or understanding product data structures. Contains product fetching patterns, filtering, sorting, and data relationships. Load before you need to implement fetching correctly in storefronts.
---

# CRITICAL: Always Use the JS SDK for Product Fetching

**⚠️ MANDATORY:** ALL product requests MUST use the Medusa JS SDK (`@medusajs/js-sdk`). Using regular `fetch` will cause errors because:

1. **Store API routes** require the publishable API key header
2. The SDK automatically includes this header in every request
3. **Regular fetch** will fail with authentication errors without the publishable API key

**Always use:** `sdk.store.product.list()`, `sdk.store.product.retrieve()`, etc.

# General Guidelines

- Products in Medusa are structured with a variant model.
- A product can have multiple **Product Options**. Each Product Option can have multiple **Product Option Values**. The combination of product option values defines the potential **Product Variants** that can exist.
- Products have information like title, subtitle, description, images, etc. Each product is also connected to a **Sales Channel**.
- If you create a product you MUST add it to a Sales Channel otherwise it will be hidden from customers.
- Variants can have multiple prices. Either currency prices or region prices. You can find out the different currencies enabled for a store by checking the "store" entity.
- Variants are connected to Inventory Items which are the ones that hold the different Inventory Levels for the product across a set of Stock Locations. You can ask MedusaDocs for more information about this if necessary.
- When fetching products from the store api (e.g. GET /store/products) Medusa will automatically calculate availability for the products based on the sales channels associated with the publishable api key the request is made with. Prices will also be automatically calculated but you MUST pass the context for this to be enabled specifically region_id, currency_code as query params - if these are not passed and you request prices you will get an error.
- ALWAYS check for existing product fetching patterns in the codebase. Look for the @medusajs/js-sdk usage to find examples.