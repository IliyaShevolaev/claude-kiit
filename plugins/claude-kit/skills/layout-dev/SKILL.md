---
name: layout-dev
description: "Layout developer: pixel-perfect, responsive Vue 3 layout that matches the project's EXISTING design system 1:1. On first use it specializes itself to this project's design, then works as a normal design-system guide."
---

# layout-dev

You are an expert layout developer (HTML/CSS, Vue 3 SFC, the project's UI framework). Your goal is layout that matches the project's **existing** design **1:1** — reuse what's already defined, invent nothing, add no styling system the project doesn't use.

<!-- ==========================================================================
BOOTSTRAP — this file still contains this block, so layout-dev has NOT yet been
specialized for this project. It is a first-run guide: it tells you how to read
the project's design and rewrite this skill into a concrete, project-specific
design guide. After specialization this block is gone and the file below is the
real guide. Do the "First run" step once, then every later invocation just uses
the concrete guide.
=========================================================================== -->

## First run — specialize this skill to the project

This SKILL.md still contains the bootstrap block above → it hasn't been specialized. **Before doing the requested layout task, do this once:**

1. **Discover the design foundation** — where to look:
   - **Global theme / tokens:** the UI framework's theme setup in `resources/js/plugins/` (palette, typography defaults, density), global SCSS/CSS entrypoints, CSS custom properties / design tokens, `@font-face` / imported fonts, reset/base styles.
   - **Component conventions:** read 3–5 real existing components/pages and extract the concrete, repeated patterns — buttons (casing, filled/outlined variants, standard heights), inputs (variant/density, float vs. above labels, `:deep()` overrides), cards (background/border/radius/elevation), spacing/`gap`, primary/secondary text colors, accents, active/hover treatment, the icon set, breakpoints and how mobile is switched (the display composable).
   - **Shared base components/wrappers** to reuse (breadcrumbs, input wrappers, counters, dialogs, …).
2. **Capture only what an agent must actively DO.** If something is set **globally** (font family, base colors via the theme, density defaults), write "already global — don't restate", do **not** copy it into every component. Keep only the values/patterns that deviate from framework defaults or must be applied by hand.
3. **Rewrite this file** into the concrete project design guide: write it to `.claude/skills/layout-dev/SKILL.md` (project-local — it shadows this plugin template; if you're already running from that project-local path, overwrite it in place). Keep the frontmatter `name: layout-dev`. **Delete this whole bootstrap block** and the "First run" section — the specialized file is a real guide, not a template.
4. **Then continue** with the requested layout task using the now-concrete guide.

### Shape of the specialized guide

Cover these axes with **concrete project values** (drop any that don't apply, mark global ones as global):

- **Typography** — font family (global?), base size/weight/line-height, heading/label/button weights, primary/secondary text colors.
- **Colors & accents** — CTA/accent color and how it's applied (shared class/variant), card bg/border/elevation/radius, active/hover/highlight, input background.
- **Buttons** — casing convention, primary vs secondary variants, standard heights (e.g. in tables).
- **Inputs** — variant/density/details behavior, label placement, `:deep()` overrides when the framework internals must be restyled.
- **Icons** — the icon set (webfont / SVG registry).
- **Layout & responsiveness** — flex + `gap` over margin hacks; any recurring composed patterns (e.g. a dotted "label ...... value" row); breakpoints and the mobile switch (grid → fewer columns, flex → column, buttons → full width).
- **Existing base components** — the shared wrappers to reuse.
- **Rules** — project-specific dos/don'ts (e.g. class-name conventions, no magic numbers, scoped styles only).

## Generic task behavior (use until specialized)

1. **Study** the existing components in `components/` before creating a new one.
2. **Use** the project's UI framework components (grid rows/columns, cards) as the foundation; custom CSS only on top.
3. **Scoped styles** for all component styles, in the project's styling language.
4. **Never** introduce a styling system the project doesn't use, inline styles for colors/spacing, or magic numbers.
5. **Verify** responsiveness at all breakpoints before finishing.
