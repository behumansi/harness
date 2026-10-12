---
name: react-portal-modals
description: Use when building modals, drawers, tooltips or any overlay in React/Next.js apps that use a complex layout (sidebar, AppShell, dashboard). Prevents fixed positioning from being clipped by parent stacking contexts.
layer: bh
---

# React Portal Modals

## Overview

`position: fixed` is relative to the **viewport** · unless a parent element creates a new stacking context (via `transform`, `filter`, `will-change`, `overflow: hidden`, or `perspective`). In apps with layouts (sidebar + content area), modals placed inside the component tree get clipped. Fix: render via `createPortal` at `document.body`.

## Symptom

- Modal has `fixed inset-0` but sidebar/header still visible around it
- Backdrop doesn't cover full screen · you see the page behind
- `z-index: 9999` doesn't help
- `backdrop-filter` shows wrong content (reference images bleeding through)

## Pattern

```tsx
import { createPortal } from 'react-dom';

// ✅ Always use portal for overlays
{isOpen && createPortal(
  <div className="fixed inset-0 z-[9999] bg-black/80 overflow-y-auto"
       onClick={onClose}>
    <div className="..." onClick={e => e.stopPropagation()}>
      {/* modal content */}
    </div>
  </div>,
  document.body
)}

// ❌ Never do this in apps with layouts
{isOpen && (
  <div className="fixed inset-0 z-50 bg-black/80">...</div>
)}
```

## Rules

- **Always** `createPortal(..., document.body)` for modals in dashboard/layout apps
- **Always** `stopPropagation` on the inner content div (so clicking inside doesn't close)
- Use `z-[9999]` not `z-50` to guarantee it's above everything
- **No `backdrop-blur-sm`** on the overlay · blur samples pixels behind and can show parent content. Use high-opacity solid bg instead (`bg-black/80`)
- Handle SSR: `document` only exists in browser · `createPortal` is safe inside JSX since it only runs client-side with `'use client'`

## Close on outside click

```tsx
<div className="fixed inset-0 z-[9999] bg-black/80" onClick={onClose}>
  <div onClick={e => e.stopPropagation()}>
    {/* content */}
  </div>
</div>
```

## When this stacking context issue occurs

Parent has any of these → child `fixed` gets clipped:
- `transform: translate(...)`
- `filter: drop-shadow(...)`
- `will-change: transform`
- `overflow: hidden` (common in scrollable sidebars)
- `perspective` or `contain: layout`
