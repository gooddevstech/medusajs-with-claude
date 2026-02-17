# Screenshot Tool

Takes a screenshot of a webpage and returns the image as multi-modal output.

## Use Cases

- Understanding the visual design and layout of a webpage
- Analyzing UI components, colors, typography, and spacing
- Getting a detailed overview of how content renders visually
- Comparing designs or understanding reference sites
- Viewing the current state of the preview

## Caching

- Screenshots are cached for 1 hour by default to improve performance and reduce costs
- Use `skipCache: true` to force a fresh screenshot when you need to see the latest changes

## Parameters

```typescript
{
  url: string,           // Required: URL of webpage to screenshot
  skipCache?: boolean    // Optional: Force fresh screenshot (default: false)
}
```