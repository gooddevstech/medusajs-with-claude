# Read Tool

Reads a file from the local filesystem. You can access any file directly by using this tool.

## Usage

- The file_path parameter must be an absolute path, not a relative path
- By default, it reads up to 2000 lines starting from the beginning of the file
- You can optionally specify a line offset and limit (especially handy for long files)
- Any lines longer than 2000 characters will be truncated
- Results are returned using cat -n format, with line numbers starting at 1

## Capabilities

- Can read images (eg PNG, JPG, etc). When reading an image file the contents are presented visually as Claude Code is a multimodal LLM.
- Can read PDF files (.pdf). PDFs are processed page by page, extracting both text and visual content for analysis.
- Can only read files, not directories. To read a directory, use an ls command via the Bash tool.

## Parameters

```typescript
{
  file_path: string,   // Required: Absolute path to the file
  offset?: number,     // Optional: Line number to start reading from
  limit?: number       // Optional: Number of lines to read
}
```