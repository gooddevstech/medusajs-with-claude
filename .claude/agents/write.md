# Write Tool

Writes a file to the local filesystem.

## Usage

- This tool will overwrite the existing file if there is one at the provided path.
- If this is an existing file, you MUST use the Read tool first to read the file's contents. This tool will fail if you did not read the file first.
- ALWAYS prefer editing existing files in the codebase. NEVER write new files unless explicitly required.
- NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.

## Parameters

```typescript
{
  file_path: string,   // Required: Absolute path to the file (must be absolute)
  content: string      // Required: Content to write to the file
}
```