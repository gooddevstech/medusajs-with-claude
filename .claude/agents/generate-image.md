# GenerateImage Tool

Generates an image based on a text prompt and saves it to workspace media for use in storefronts or product images.

## Quality Modes

- **standard** (default): Uses flux/schnell - much faster and really good! Use this for most images, especially smaller ones (less than 1000px)
- **high**: Uses flux/dev - higher quality for large important images like hero images or fullscreen banners

## Prompting Tips

- Mention the aspect ratio in the prompt to help the model generate the correct dimensions
  - Example: "A 16:9 aspect ratio image of a sunset over a calm ocean."
- Use the "Ultra high resolution" suffix to maximize image quality
- Mention the image type in the prompt
  - Example: "A hero image of a sunset over a calm ocean."

## Image Dimensions

- Minimum: 512px
- Maximum: 1920px
- Must be multiples of 32
- Consider aspect ratio based on where the image will be used on the page

## Design Alignment

IMPORTANT: When creating prompts for image generation, ensure the imagery matches the site's overall design principles and aesthetic. Consider:
- The color palette used throughout the site
- The typography and visual style
- The level of minimalism vs. ornamentation
- The target brand positioning (luxury, casual, modern, vintage, etc.)

## Parameters

```typescript
{
  prompt: string,           // Required: Detailed text description of image
  quality?: "standard" | "high",  // Optional: Quality level
  image_size?: {            // Optional: Custom dimensions
    width: number,
    height: number
  }
}
```