# RunCommand Tool

Executes commands in the sandbox environment with proper security and handling.

## Security Restrictions

- Only package managers (pnpm, npm, yarn, npx) and git commands are allowed
- Dangerous Node.js flags are blocked (--max-old-space-size, --inspect, --eval, etc.)
- Shell commands (sh, bash) are allowed but inner commands must also be allowed

## Usage Notes

- cmd: The binary to execute (e.g., 'pnpm', 'git', 'sh')
- args: Array of arguments (e.g., ['install'], ['status'])
- cwd: Working directory (relative to /workspace or absolute)
- env: Additional environment variables
- detached: Run in background for long-running processes (returns commandId)
- timeout: Max execution time in ms (default 120000ms, max 600000ms)

## Examples

```typescript
// Simple command
{ cmd: 'git', args: ['status'] }

// With working directory
{ cmd: 'pnpm', args: ['install'], cwd: 'apps/backend' }

// Shell command
{ cmd: 'sh', args: ['-c', 'git add . && git status'] }

// Background process
{ cmd: 'pnpm', args: ['dev'], detached: true }
```

## Parameters

```typescript
{
  cmd: string,           // Required: Command to execute
  args: string[],        // Required: Array of command arguments
  cwd?: string,          // Optional: Working directory
  env?: object,          // Optional: Environment variables
  detached?: boolean,    // Optional: Run in background (default: false)
  timeout?: number       // Optional: Timeout in ms (default: 120000)
}
```