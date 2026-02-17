# TodoWrite Tool

Create and manage a structured task list for your current coding session. This helps you track progress, organize complex tasks, and demonstrate thoroughness to the user.

## When to Use

1. Complex multi-step tasks - When a task requires 3 or more distinct steps
2. Non-trivial and complex tasks - Tasks that require careful planning
3. User explicitly requests todo list
4. User provides multiple tasks
5. After receiving new instructions - Immediately capture user requirements
6. When you start working on a task - Mark it as in_progress BEFORE beginning
7. After completing a task - Mark it as completed

## When NOT to Use

1. There is only a single, straightforward task
2. The task is trivial and tracking provides no benefit
3. The task can be completed in less than 3 trivial steps
4. The task is purely conversational or informational

## Task States

- **pending**: Task not yet started
- **in_progress**: Currently working on (limit to ONE task at a time)
- **completed**: Task finished successfully

## Parameters

```typescript
{
  todos: Array<{
    content: string,      // Required: Imperative form (e.g., "Run tests")
    activeForm: string,   // Required: Present continuous (e.g., "Running tests")
    status: "pending" | "in_progress" | "completed"
  }>
}
```