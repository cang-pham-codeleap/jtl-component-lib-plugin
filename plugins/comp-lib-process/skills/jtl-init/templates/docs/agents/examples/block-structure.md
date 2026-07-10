# Example Block structure

A Block is a flat list of a handful of files — a main component plus its sub-parts
and hooks — not a deep folder tree. It declares its shadcn atoms in
`registryDependencies`. See [../authoring/block.md](../authoring/block.md).

## On disk

```
blocks/app-sidebar/
├── app-sidebar.tsx      main component, composes the parts
├── nav-main.tsx         sub-part
├── nav-user.tsx         sub-part
├── team-switcher.tsx    sub-part
└── use-sidebar-state.ts internal hook (if needed)
```

Atoms (`sidebar`, `separator`, `avatar`, ...) are not in this folder. They are
declared in `registryDependencies` and installed by the CLI into
`@/components/ui/`, then imported by the Block.

## In the consumer's project after install

```
components/
├── ui/                  shadcn atoms pulled by registryDependencies
│   ├── sidebar.tsx
│   ├── separator.tsx
│   └── avatar.tsx
└── app-sidebar/         the Block, now owned by the app
    ├── app-sidebar.tsx
    ├── nav-main.tsx
    └── nav-user.tsx
```

## Conventions

- Files match their export names; no re-export indirection.
- Sub-parts are named with clear contracts, so each is independently replaceable.
- The main component composes the sub-parts; it does not inline everything.
- The registry item lists every file with its `type`, and every atom in
  `registryDependencies`. See [registry-item.md](registry-item.md).
