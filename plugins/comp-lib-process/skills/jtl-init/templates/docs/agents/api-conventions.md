# API Conventions

Naming and prop conventions for JTL items. These sit on top of the shadcn coding
rules — for styling, forms, composition, icons, and base-vs-radix, follow the
bundled `shadcn` skill. This file covers the JTL-specific decisions that skill
does not.

## Principles

- **Guidance over enforcement.** Components provide capability, not design
  guardrails. If a consumer passes a prop value, the component renders it.
- **Prop independence.** One prop never suppresses another prop's output. Variants
  affect styling, never whether sibling props appear.
- **Orthogonal axes.** Each prop controls one dimension. If you cannot name the
  axis without describing a use case, it is a Recipe, not a primitive.
- **No design recipes in the API.** Props describe what the component does, not how
  one composition arranged it. One-off adjustments belong in tokens or app code.
- **Use the system.** Compose from existing shadcn / JTL pieces. No raw HTML when a
  system equivalent exists. Do not reimplement behavior that already exists.
- **Fix at the right layer.** Before patching a component, check whether the issue
  belongs in tokens, theme config, or build tooling.

## Naming

- **Components** are unprefixed: `Button`, `TextInput`, `ComboBox` — not
  `JtlButton`. The `@jtl` namespace lives in the registry name, not the export.
- **Hooks** use the `use` prefix, unprefixed name: `usePopover`.
- **Types** take the component name: `ButtonProps`, `ButtonVariant`,
  `TextInputStatus`, `<Component>Context`.
- **Files** match export names. No re-export indirection.

## Props

- **Booleans** prefix with `is` or `has`: `isDisabled`, `isLoading`, `hasClear`.
- **Callbacks** use `on{Verb}`, adding a scope only when a verb is ambiguous:
  `onClick`, `onChange`, `onSidebarCollapsedChange`. Async variants use
  `on{Verb}Action`.
- **Visibility** uses one unified callback on layered components (Dialog, Popover,
  DropdownMenu, Tooltip): `onOpenChange?: (isOpen: boolean) => void`. Components
  without layers never take `isOpen` / `onOpenChange`.
- **Primary change** is `onChange`. Do not scope it (`onValueChange`) unless the
  component has multiple independent values.
- **Enums** use `camelCase` values aligned with token names where applicable:
  `size?: 'sm' | 'md' | 'lg'`.
- **Directional** props use `start` / `end`, not `left` / `right`, for RTL:
  `startIcon`, `paddingEnd`.
- **HTML attribute collisions** are prefixed with `html`: `htmlFor`, `htmlName`.
- **Uncontrolled defaults** prefix with `default`, keeping the boolean prefix:
  `defaultValue`, `defaultIsOpen`.

### Required vs optional

Make behavioral and structural props required (`value` + `onChange`, `label` on
interactive elements, `children` when there is no meaningful output without it).
Make presentation props optional with sensible defaults (`variant`, `size`,
boolean flags default to `false`).

## Composition vs config

| Use composition when                    | Use config when                           |
| --------------------------------------- | ----------------------------------------- |
| Content is arbitrary / user-defined     | Options are finite and well-known         |
| Children need parent context            | A prop controls a single visual attribute |
| Flexibility is needed for unknown cases | Consistency matters more than flexibility |

- **Slots are passthrough.** The parent renders slot content directly and never
  wraps it. Do not hoist child props onto the parent.
- **Behaviors: hooks over wrappers.** When composing a behavior (resize, collapse,
  scroll-lock), prefer a hook or a `boolean | config` prop over a wrapper
  component that adds a DOM node.
- **Escape hatches need a demonstrated use case.** Do not add flexibility
  speculatively.

### Boolean-or-config props

When a feature needs both a simple toggle and advanced configuration, use one prop
that accepts `boolean | object`: `true` enables with defaults, an object
configures, `false` or omitted disables.

## Accessibility

- `label` on interactive components (maps to `<label htmlFor>` or `aria-label`).
- `aria-required`, `aria-invalid`, `aria-busy` mapped from `isRequired`, error
  status, and busy state.
- **Disabled vs busy:** disabled uses the native attribute (focus lost); busy is
  visual-only (`aria-busy`, reduced opacity) so focus is kept during async work.
- **Never remove focusable elements from the DOM on state change.** Hide visually
  but keep them available; restore focus to the trigger after a layer closes.

## Code smells

- `useEffect` for state sync (causes flicker) — push state handling into the hook.
- Wrapper components with no branch — inline the remaining path.
- `addEventListener` in React — use React's event system.
- Raw values (colors, shadows, spacing) — use tokens. See
  [authoring/tokens.md](authoring/tokens.md).

## Related

- The bundled `shadcn` skill — styling, forms, composition, icons, base-vs-radix.
- [architecture.md](architecture.md) — where each API shape applies.
