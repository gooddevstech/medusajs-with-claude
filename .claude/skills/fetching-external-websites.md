Use when user wants to migrate content from external websites.

# Fetching External Websites

## Approach

1. **Start Small** - front page + 2-3 products first
2. **Fetch HTML** - use WebFetch for content AND layout
3. **Use Existing Images** - copy from source, don't generate
4. **Handle Failures Gracefully** - ask user for help

## Image Handling

```typescript
// Add image from external URL to workspace
const image = await addWorkspaceMediaTool.execute({
  url: "https://example.com/product-image.jpg"
})
// Use workspace URL in product
images: [{ url: image.url }]
```

Only generate images if user asks OR can't access AND user hasn't provided alternatives.