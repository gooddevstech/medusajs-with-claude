---
name: adding-data-to-medusa
description: Use when creating products, categories, collections, sales channels, regions, or promotions in Medusa. Contains critical data structures, sales channel requirements, product options patterns, and common pitfalls to avoid.
---

# General Guidelines

Use the examples below for common data operations. Only query MedusaDocs for workflows not documented here.

**Reference Files Available:**
- **products.md** - Complete product creation patterns (simple products, variants, fetching prerequisite data)
- **categories-collections.md** - Categories, collections, tags, and types
- **regions.md** - Region creation and management
- **promotions.md** - Promotion and discount patterns

## Product Images

When the user needs to add images to products or associate images with specific variants (e.g., different images per color), load the **working-with-product-images** skill. It covers critical rules for safely updating images, associating images with variants, setting thumbnails, and displaying variant-specific galleries on the storefront.

## Products - Critical Rules

Adding products is a common task the user will often ask you to do. It's important that you do it correctly otherwise the user will not see the product and the experience will be bad.

**CRITICAL**: ALL products MUST have the `options` array defined, even simple products.
- Products with meaningful variants (size, color, etc.): Use descriptive options like "Size", "Color"
- Simple products with no meaningful options: Use "Default option" as the title and "Default option value" in the values array
- Each variant MUST reference these options in its `options` object
- Missing options will cause: "Product options are not provided" error

**ALWAYS follow these rules:**
1. ALWAYS add products to a sales channel - list the sales channel and pick one - if there are multiple pick one and tell the user that they can add it to more sales channels if necessary. If you don't add it to a sales channel the product will not show up.
2. ALWAYS create the product with "published" state otherwise the product won't show up. Only create "draft" products if explicitly asked to.
3. ALWAYS give products prices that match the store's configured currencies.
4. If the user wants to add a price in an unsupported currency ASK if you should add the currency to the store and which countries should shop in that currency.
5. Make sure that any image urls you pass have been copied to workspace media using AddWorkspaceMedia

**For detailed product examples, load the `products.md` reference file.**

## Categories, Collections, Types, and Tags

When the user wants to organize their products you have different options:

- **Categories** are used for broad categorization of products. This is frequently the base for navigation.
- **Collections** are typically used for products that launch as part of the same campaign or season - e.g., Autumn/Winter, Spring/Summer.
- **Tags** are helpful for general purpose feature implementations - e.g., featured products → add a "featured" tag. Can be used for filtering and differentiated merchandizing.
- **Types** are good to classify products that share the same properties - this can be good for determining the layout of a product page, or to determine if an admin customization should be shown or not. E.g., digital product → show digital asset upload customization in admin dashboard, clothes → show "size and fit" metadata input. Types are also typically used for determining tax rates where applicable. Types should be objective.

**For detailed examples, load the `categories-collections.md` reference file.**

## Regions

Regions are Medusa's structure for controlling where customers can shop from. A region can consist of one or more countries that will shop in the same currency and have shared properties.

- A country can only be part of a single Region.
- When updating a Region's countries you need to pass the entire list of countries that should be part of the region. If you don't it will remove any countries from the region that are not in the list. This is often not what you want to do.

**For detailed region examples, load the `regions.md` reference file.**

## Promotions

Promotions allow you to create discounts that apply to items, shipping methods, or entire orders.

**Important notes:**
- Fixed amounts use full currency units (5 = $5.00, NOT cents)
- `currency_code` is REQUIRED for `fixed` type promotions
- For more advanced promotions (buy X get Y, customer group restrictions, product/collection targeting, budgets, campaigns, etc.), ask MedusaDocs for examples

**For detailed promotion examples, load the `promotions.md` reference file.**

## Pickup Options

When implementing pickup/local fulfillment options:

1. Create a fulfillment set with type "pickup" (NOT "pickup-local" or any custom type):
   ```typescript
   // Via workflow or admin API:
   // POST /admin/stock-locations/{id}/fulfillment-sets
   // { "name": "Pick-up", "type": "pickup" }
   ```
2. Create a service zone within that fulfillment set for the applicable geo area.
3. Create a shipping option in that service zone.

IMPORTANT: The type MUST be "pickup" for the option to show up correctly in the admin dashboard's Pickup section. Custom types will not be recognized.

Before creating fulfillment sets, query existing ones first - the stock location may already have one configured.