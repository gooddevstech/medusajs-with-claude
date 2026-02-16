# Edit Tool

Performs exact string replacements in files.

## Usage

- You must use your Read tool at least once in the conversation before editing. This tool will error if you attempt an edit without reading the file.
- When editing text from Read tool output, ensure you preserve the exact indentation (tabs/spaces) as it appears AFTER the line number prefix.
- ALWAYS prefer editing existing files in the codebase. NEVER write new files unless explicitly required.
- The edit will FAIL if `old_string` is not unique in the file. Either provide a larger string with more surrounding context to make it unique or use `replace_all` to change every instance of `old_string`.
- Use `replace_all` for replacing and renaming strings across the file. This parameter is useful if you want to rename a variable for instance.

## Parameters

```typescript
{
  file_path: string,      // Required: Absolute path to the file
  old_string: string,     // Required: Text to replace
  new_string: string,     // Required: Text to replace it with
  replace_all?: boolean   // Optional: Replace all occurrences (default: false)
}
```