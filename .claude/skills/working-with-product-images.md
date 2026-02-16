---
name: working-with-product-images
description: Use when working with product images, associating images with specific variants, setting thumbnails, or building image galleries on the storefront. Contains critical rules for image updates, variant association patterns, and display logic.
---

# Working with Product Images in Medusa

Medusa natively supports associating product images with specific product variants (available since v2.11.2). This allows different variants (e.g., colors) to show different images on the storefront.

## How Variant Images Work

- **Images are stored at the product level** in the `ProductImage` model
- **Variants can be associated with specific product images** via a many-to-many relationship (`ProductVariantProductImage` pivot table)
- **Unassociated images display for all variants** - if a product image is not linked to any specific variant, it appears for every variant
- **Associated images are variant-specific** - once an image is linked to a variant, it only appears for that variant

### Data Model

```
Product (1) -----> (many) ProductImage
Product (1) -----> (many) ProductVariant
ProductVariant (many) <-----> (many) ProductImage
                  (via ProductVariantProductImage pivot)
```

Each `ProductImage` has:
- `id` - Unique identifier
- `url` - The image URL
- `metadata` - Optional key-value data

## Critical Rules

### 1. `updateProductsWorkflow` REPLACES All Images

**DANGER:** When you pass an `images` array to `updateProductsWorkflow`, it **completely replaces** all existing images on the product. This will delete any images not included in the new array.

**WRONG - This deletes existing images:**
```typescript
// DON'T DO THIS - it removes all existing charcoal/olive images!
await updateProductsWorkflow(container).run({
  input: {
    products: [{
      id: product.id,
      images: [
        { url: "https://cdn.example.com/sand-1.jpg" },
        { url: "https://cdn.example.com/sand-2.jpg" },
      ]
    }]
  }
});
```

**CORRECT - Preserve existing images when adding new ones:**
```typescript
// Get existing images first
const { data: [product] } = await query.graph({
  entity: "product",
  fields: ["id", "images.*"],
  filters: { handle: "product-handle" }
});

// Include existing images by ID + add new images by URL
await updateProductsWorkflow(container).run({
  input: {
    products: [{
      id: product.id,
      images: [
        ...product.images.map(img => ({ id: img.id })), // Keep existing
        { url: "https://cdn.example.com/new-image-1.jpg" }, // Add new
        { url: "https://cdn.example.com/new-image-2.jpg" },
      ]
    }]
  }
});
```

### 2. Associate Images with ALL Variants of Same Option Value

When you have multiple variants with the same color (e.g., "Sand" in sizes S/M/L/XL), you must associate images with **all** of them, not just one.

### 3. Product AND Variant Thumbnails Must Be Explicitly Set

The product thumbnail is a separate field and does NOT automatically update when images change. **Additionally, each variant has its own `thumbnail` field** that should be set to show the correct image in carts, order confirmations, etc.

**Product thumbnail** - shown on product listing pages, search results
**Variant thumbnail** - shown when a specific variant is added to cart, in order details

## Displaying Variant Images on the Storefront

### Key Principle: Images Must React to Partial Option Selection

Images should switch as soon as the customer selects any option that changes the images — **before** a full variant is selected (e.g., before choosing size). This gives immediate visual feedback.

### Image Reordering Algorithm

1. User selects an option value (e.g., Color: Sand)
2. Find all variants that match the currently selected options
3. Collect those variants' images into a set
4. Show those images first, then remaining images after

```typescript
const displayImages = useMemo(() => {
  const allImages = product.images || []

  // Get all selected option entries (partial selection is fine)
  const selectedEntries = Object.entries(selectedOptions).filter(([, v]) => v)
  if (selectedEntries.length === 0) return allImages

  // Find all variants matching the selected options
  const matchingVariants = (product.variants || []).filter((variant) =>
    selectedEntries.every(([optId, value]) =>
      variant.options?.some(o => o.option_id === optId && o.value === value)
    )
  )

  // Collect their image IDs
  const matchingImageIds = new Set(
    matchingVariants.flatMap((v) => v.images?.map((img) => img.id) || [])
  )

  if (matchingImageIds.size === 0) return allImages

  // Reorder: matching images first, then the rest
  const matched = allImages.filter((img) => matchingImageIds.has(img.id))
  const rest = allImages.filter((img) => !matchingImageIds.has(img.id))

  return [...matched, ...rest]
}, [product.images, product.variants, selectedOptions])
```