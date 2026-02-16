Use when implementing mega menu navigation with categories, dropdowns, or complex navigation structures.

# Building Mega Menus

## Key Characteristics

- Menu items result in a large dropdown
- Dropdown fills entire width of screen
- Multiple columns within dropdown
- Allows quick navigation while inspiring discovery

## Technical Guidelines

### Hover State Management
```typescript
const [isDropdownOpen, setIsDropdownOpen] = useState(false)
// Trigger: onMouseEnter={() => setIsDropdownOpen(true)}
// Dropdown: onMouseEnter + onMouseLeave handlers
```

### Full-Width Positioning
- Use `fixed` positioning with `inset-x-0`
- Add offset from top equal to navbar height

### Mobile Alternative
- Separate mobile navigation with hamburger toggle
- `hidden lg:block` for desktop, `lg:hidden` for mobile
