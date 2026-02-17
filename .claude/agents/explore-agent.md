# Task Tool - Explore Agent

Launch a sub-agent to handle a specific task autonomously.

## Available Agent Types

- **Explore**: Codebase search specialist (Glob, Grep, Read). Use for finding files by patterns (eg. "routes/**/*.tsx"), searching code for keywords (eg. "cart mutations"), or understanding how parts of the codebase work (eg. "how does checkout work?").
- **DesignAnalyzer**: Design reference URL analyst (WebFetch, Screenshot). Use for extracting colors, typography, spacing, and layout from design URLs.

## Usage Notes

- Launch multiple Task calls in parallel when searches are independent - this maximizes performance
- Sub-agents run in isolation with their own context window
- The result returned by the sub-agent is not visible to the user. You must summarize the result in your response.
- Write detailed, self-contained prompts - sub-agents don't see conversation history. Specify exactly what information you need returned.
- Sub-agent outputs should be trusted

## When to Use

- Your task at hand requires you to find files in the code base -> use Explore and explain what you are looking for
- Finding patterns across multiple files → use Explore and specify the types of patterns you want identified
- Analyzing design references or screenshots → use DesignAnalyzer
- Multiple independent searches → spawn parallel Task calls

## When NOT to Use

- Reading a specific file path you already know (use Read directly)
- Searching for a specific class/function name like "class CartService" (use Grep directly)
- Looking within a specific file or 2-3 known files (use Read directly)
- Tasks requiring sequential context from previous steps

## Parameters

```typescript
{
  agent_type: "Explore" | "DesignAnalyzer",  // Required: Type of specialized agent
  prompt: string,                             // Required: Detailed task description
  description?: string                        // Optional: Short 3-5 word description for tracking
}
```