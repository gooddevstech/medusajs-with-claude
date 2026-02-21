---
name: designing-storefronts
description: LOAD THIS when building UI or implementing visual changes. Contains design thinking process to create distinctive frontends that avoid generic AI aesthetics.
---

# Designing Storefronts

This skill guides creation of distinctive, production-grade storefronts that avoid generic "AI slop" aesthetics. Implement real working code with exceptional attention to aesthetic details and creative choices.

## Design Thinking

You tend to converge toward generic, "on distribution" outputs. In frontend design, this creates what users call the "AI slop" aesthetic. Avoid this: make creative, distinctive frontends that surprise and delight.

Before coding, understand the context and commit to a BOLD aesthetic direction:

- **Purpose**: What problem does this interface solve? Who is the customer?
- **Tone — PICK AN EXTREME**: Commit to a direction: brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian. Use these for inspiration but design one true to the brand.
- **Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?

**CRITICAL**: Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work—the key is intentionality, not intensity. Timid, middle-ground aesthetics are forgettable.

## Frontend Aesthetics Guidelines

### Typography

Choose fonts that are distinctive and characterful. Pair a bold display font with a refined body font.

Avoid generic fonts like Inter, Roboto, Arial, system fonts. Choose something that elevates the aesthetics; unexpected, and beautiful. Pair a distinctive display font with a refined body font.

### Color

Commit to a cohesive palette. Dominant colors with sharp accents outperform timid, evenly-distributed palettes.
Use CSS variables for consistency and implement them using Tailwind (when available; check for theme.css files or similar).

**Contrast**: Text MUST be readable. Light text on light backgrounds or dark text on dark backgrounds = failure.

When changing a component's background color, check all nested interactive elements (dropdowns, selects, popovers, modals) - they often render their own panels with text colors that won't automatically adapt. A dark footer with a light-text dropdown menu will have unreadable options when the dropdown opens with dark text on its panel.

NEVER default to: purple gradients on white, safe blue-gray palettes.

### Motion

One well-orchestrated page load with staggered reveals creates more delight than scattered micro-interactions.
Focus on high-impact moments: scroll-triggered animations, hover states that surprise.
Use Motion library for React when available or Tailwind Animate.

### Spatial Composition

Unexpected layouts. Asymmetry. Overlap. Grid-breaking elements. Generous negative space OR controlled density—not both half-heartedly.
In luxury ecommerce experiences lots of negative space is common and gives a great aesthetic. Make sure things align nicely between sections, navbar, footer, etc.

### Navigation Styles

**The navbar sets the tone for the entire site.** You MUST customize it—layout, colors, typography, background behavior. If there's a design reference, match its navbar. Don't leave the navbar as default.

Use the existing Navbar component to compose custom variants. Update styling of navbar primitives to match the aesthetics.

#### Layout Variations

| Layout                      | Structure                                    | Best For                   |
| --------------------------- | -------------------------------------------- | -------------------------- |
| **Logo left, links right**  | `[Logo] ———————— [Shop] [About] [Cart]`      | Most stores, clean         |
| **Centered logo**           | `[Shop] [About] — [LOGO] — [Search] [Cart]`  | Fashion, luxury, editorial |
| **Logo left, links center** | `[Logo] — [Shop] [About] [Contact] — [Cart]` | Balanced, professional     |
| **Minimal**                 | `[Logo] ———————————————— [☰]`               | Ultra-clean, mobile-first  |
| **Split with CTA**          | `[Logo] [Links] ————— [Shop Now Button]`     | Conversion-focused         |

#### Background Behaviors

| Behavior                          | Implementation                               | Best For               |
| --------------------------------- | -------------------------------------------- | ---------------------- |
| **Transparent → solid on scroll** | Start transparent, add bg after scrollY > 50 | Full-bleed hero images |
| **Always solid**                  | Consistent background color                  | Standard stores        |
| **Blur/glassmorphism**            | `backdrop-blur-md bg-white/80`               | Modern, premium        |
| **Color matches hero**            | Same bg color as hero section                | Seamless, editorial    |

## Working with Design References

If the user provides a design reference URL or screenshot, use the Task tool with agent type `DesignAnalyzer` to get a detailed specification. This can be used for replication and design adaptation, but MUST not replace the need to still be extremely deliberate and intentional with great design execution.

Get the `DesignAnalyzer` to provide its description first before you settle on a vision for the site.

## Execution

If this is in the beginning of the conversation you should especially go hard on the design to wow the user. If you end up producing simple generic output the user will be bored and think you are not good, so make an effort to surprise and delight.

NEVER use generic AI-generated aesthetics like overused font families (Inter, Roboto, Arial, system fonts), cliched color schemes (particularly purple gradients on white backgrounds), predictable layouts and component patterns, and cookie-cutter design that lacks context-specific character.

Interpret creatively and make unexpected choices that feel genuinely designed for the context. No design should be the same. Vary between light and dark themes, different fonts, different aesthetics. NEVER converge on common choices (Space Grotesk, for example) across generations.

IMPORTANT: Match implementation complexity to the aesthetic vision. Maximalist designs need elaborate code with extensive animations and effects. Minimalist or refined designs need restraint, precision, and careful attention to spacing, typography, and subtle details. Elegance comes from executing the vision well.

Remember: Claude is capable of extraordinary creative work. Don't hold back, show what can truly be created when thinking outside the box and committing fully to a distinctive vision.

Use theme.css for cohesiveness and maintainability.

## Known Issues - Icons

When placing @medusajs/icons inside circular containers, icons may appear off-center because they lack a viewBox attribute in their SVGs. To fix: add the `viewBox="0 0 15 15"` prop directly on the icon component.