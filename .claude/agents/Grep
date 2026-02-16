# Grep Tool

A powerful search tool built on ripgrep.

## Usage

- ALWAYS use Grep for search tasks. NEVER invoke `grep` or `rg` as a Bash command.
- Supports full regex syntax (e.g., "log.*Error", "function\s+\w+")
- Filter files with glob parameter (e.g., "*.js", "**/*.tsx") or type parameter (e.g., "js", "py", "rust")
- Output modes: "content" shows matching lines, "files_with_matches" shows only file paths (default), "count" shows match counts

## Pattern Syntax

- Uses ripgrep (not grep) - literal braces need escaping
- Use `interface\{\}` to find `interface{}` in Go code
- For multiline patterns, use `multiline: true`

## Parameters

```typescript
{
  pattern: string,                    // Required: Regex pattern to search
  path?: string,                      // Optional: File or directory to search
  glob?: string,                      // Optional: Glob pattern to filter files
  type?: string,                      // Optional: File type (js, py, rust, etc.)
  output_mode?: "content" | "files_with_matches" | "count",
  multiline?: boolean,                // Optional: Enable multiline mode
  "-i"?: boolean,                     // Optional: Case insensitive
  "-n"?: boolean,                     // Optional: Show line numbers
  "-A"?: number,                      // Optional: Lines after match
  "-B"?: number,                      // Optional: Lines before match
  "-C"?: number,                      // Optional: Lines around match
  head_limit?: number                 // Optional: Limit output lines
}
```