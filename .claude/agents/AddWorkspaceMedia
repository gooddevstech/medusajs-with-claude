# AddWorkspaceMedia Tool

Saves images or videos to permanent workspace storage.

## Sources

1. **Temporary storage**: When users upload media in the chat, it goes to /tmp/ first
2. **External URLs**: Any publicly accessible image or video URL

## Use Cases

- Used in code or content (hero images, product photos, videos, icons, logos)
- Referenced multiple times across the site
- Part of the permanent site assets

## What It Does

1. Download media from the URL (or copy from temp storage if applicable)
2. Upload to permanent workspace storage
3. Create a workspace_image database record
4. Return the permanent URL

## Limitations

- Max file size: 10MB for images, 50MB for videos
- Supported images: jpeg, png, gif, webp, svg
- Supported videos: mp4, webm, mov
- Don't save temporary reference images (screenshots saying "copy this", "fix this", etc.)

## Parameters

```typescript
{
  media_url: string   // Required: URL of media to save (temp or external)
}
```