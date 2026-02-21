---
name: using-emails
description: Guidance for implementing email functionality with React Email templates.
---

Guidance for implementing email functionality with React Email templates.

# Using Emails with React Email

## Quick Reference

1. Install @react-email/render and @react-email/components
2. Create template in src/email-templates/
3. Render: `const html = render(YourTemplate({ props }))`
4. Send: `notificationModuleService.createNotifications([{ to, channel: "email", content: { subject, html } }])`

## CRITICAL

- ALWAYS use React Email templates
- NEVER use raw HTML strings
- Assume default Medusa Cloud email provider is configured