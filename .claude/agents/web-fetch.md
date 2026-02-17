# WebFetch Tool

Fetch and extract content from a webpage.

## Supported Formats

- **markdown** - when only the text/img urls is needed
- **branding** - extracts logos, favicons, brand colors, and fonts. Useful when needing to match a reference site's branding.
- **html** - for full html structure. Useful for understanding layouts and styles; generally avoid this and use with caution as the output can be extremely large.

You can extract multiple formats at once by specifying them in the 'formats' input array.

## Caching

- Fetches are cached for 1 hour by default to improve performance and reduce costs
- Use `skipCache: true` to force a fresh fetch when you need the latest content or are debugging

## Parameters

```typescript
{
  url: string,                              // Required: URL to fetch
  formats?: ("html" | "markdown" | "branding")[],  // Optional: Content formats
  skipCache?: boolean                       // Optional: Skip cache (default: false)
}
```