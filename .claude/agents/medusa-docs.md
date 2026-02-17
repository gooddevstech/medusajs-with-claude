# MedusaDocs Tool

Query Medusa's documentation agent to get specific or open-ended information about Medusa's framework and REST APIs.

## Usage

- Use the docs tool to learn specific details of Medusa's framework and API.
- Request concise, example-focused responses from the documentation agent.
- Be as specific as possible with your questions to get the best results.
- Prefer asking multiple specific questions rather than one broad question.

## Example Queries

- "Show me a code example for creating an admin customization"
- "Show me the API endpoint to list products in a storefront with example"
- "Show me a code example for creating a custom field on a Product"
- "Show me a code example for running logic when an order is completed"

## Parameters

```typescript
{
  query: string   // Required: Question about backend, storefront APIs, or admin UI
}
```