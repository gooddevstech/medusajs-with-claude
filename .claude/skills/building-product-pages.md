---
name: building-product-pages
description: Use when implementing or customizing product detail pages. Contains patterns for recommended products, product galleries, variant selection, add-to-cart functionality, and dynamic content display.
---

**IMPORTANT:** When fetching product data for product pages, load the `fetching-medusa-product-data` skill which contains critical information about using the JS SDK correctly.

- Product pages are where customers see details, images, and prices for a product before adding it to cart.
- If you are asked by the user to add dynamic, inspirational, curated sections to the product details page you should do it with the following approach:
  - Create components in a directory dedicated to curated product page content.
  - Add a dedicated file for the product that will hold the curated content for a specific product. For example, t-shirt-inspiration.tsx, pure-bedding-green-inspiration.tsx, etc.
  - Create a CuratedContent component which holds a switch case over a product handle and which will return the correct curated content component. If there's no curated content for the handle just return null.
- When a user asks to add things to a product page you should ask them if this should be added to all product pages or only for a specific product.
- A common pattern on product pages is to have "Other products" listed alongside the product the customer is viewing. This is an opportunity to upsell the customer and get them to continue browsing. How products are selected can differ:
  - A simple approach is to keep track of the last 3-5 products that the customer viewed. This information can be kept in localstorage. Other products would then just be whatever products the customer last saw under a title like "Last viewed".
  - A more advanced approach is to add curation functionality to the product details page in the admin dashboard. This would include:
    - A widget on the product page to select "Related Products" from the admin dashboard.
    - A Product To Product Medusa Link to associate related products (ask MedusaDocs for details on how to do this)
    - A set of admin API endpoints to manage the related product links e.g., POST /admin/v1/products/:id/related { product_id }.
    - Customizations to the storefront to fetch the related products by querying for the extra field and displaying them in the product details page.
  - An even more advanced approach is to calculate the best recommended products statistically. This is beyond the scope of what you should do so DON'T attempt that. If the user insists and gives strong technical guidance on how they want it done you can try but it's overkill for most stores. In stores with huge product catalogs (+5000 SKUs) it makes more sense.
  - Note: Users may use different terminology to refer to a section like this "Pair it with", "Others also bought", "Frequently bought with", etc. but the functionality is mostly the same. Default to suggesting that you will create a way for them to curate the related products from the admin dashboard, but confirm that this is what they want.