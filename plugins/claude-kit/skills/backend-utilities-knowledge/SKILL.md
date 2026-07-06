---
name: backend-utilities-knowledge
description: "Knowledge base: project-specific backend truth — tech stack, utilities (base classes, traits, helpers), the project-specific conventions the portable skills deliberately omit, and golden CRUD code examples. Always-loaded source of truth other agents reference for project concretes."
disable-model-invocation: true
---

# Backend — project-specific truth

The single source of truth for everything **specific to this project's backend**. The portable skills `backend-conventions-knowledge` (general Laravel canon) and `backend-crud-flow-knowledge` (general CRUD flow) are intentionally project-agnostic and point here for concretes: base classes, helpers, traits, exact rule forms, config and the golden code examples.

<!-- ==========================================================================
TEMPLATE — this file (and references/crud-examples.md) is filled by
`/claude-kit:setup`, which explores the real codebase and writes the concrete
project truth here. Until then it describes WHAT to discover in each section.
Every `> FILL:` note is an instruction to the writer; replace it and the
neutral placeholders with the real classes / helpers / packages / paths found
in the project. Delete sections that genuinely do not apply (say so explicitly
rather than leaving a placeholder). Keep this file lean — the heavy golden code
goes into references/crud-examples.md.
=========================================================================== -->

## Tech stack

> FILL: the real backend stack discovered from `composer.json` / `.env`.

- **Framework:** Laravel `<version>`
- **PHP:** `<version>` with strict typing (`declare(strict_types=1)` in every file)
- **Database:** `<driver + version>`
- **Auth:** `<auth package, e.g. jwt-auth / sanctum / passport>`
- **Key packages:** `<DTO package (if any), RBAC/permissions, media/files, datatable package, …>`

## Project-specific conventions (the portable skills omit these)

> FILL: the concrete team agreements the portable canon defers here. Include only
> what actually holds in this project; drop the rest.

- **Static analyzer level:** `<phpstan/larastan level, or "none">` — satisfy the analyzer's typing.
- **Controller `authorize()` signature:** `<does the base controller wrap the second policy argument in an array? show the exact signature and a call example, or state it uses the default Laravel signature>`.
- **Soft deletes:** `<does the project use soft deletes? if so, the exact rule forms>` — e.g. existence `exists:<table>,id,deleted_at,NULL`, uniqueness `Rule::unique(...)->whereNull('deleted_at')->ignore($this->id)`.
- **Attribute translations:** `<are FormRequest attributes() translations mandatory? into which locales?>`.
- **Role-restricted Resources:** `<the concrete resolver — e.g. a static resolveClass() inspecting the current-user helper — and how the controller uses it>`.
- **DTO update fields:** `<if a DTO layer exists: the optional-fields trait/method used on update instead of toArray(), and the type used for skippable fields>`.
- **Namespacing:** `<how layers are grouped, e.g. per-domain folders App\Http\Controllers\<Domain>, App\Data\<Domain>, App\Services\<Domain>, …>`.

## Utilities — don't reinvent them, just use them

> FILL: enumerate the real reusable building blocks so agents reuse instead of
> reinventing. Give each a one-line "what it does / when to use it". Discover
> them by scanning `app/Helpers`, `app/Traits`, base service/controller classes.

**Helpers** (`app/Helpers/`):
- `<MOST IMPORTANT: the current-user / auth resolver, if any — name + what it returns>`
- `<search-keyword preparation, enum-with-translation builders, number formatting, … — each with a one-liner>`

**Traits for services** (`app/Traits/`):
- `<search + pagination, role scopes, file attachment, domain-specific calculations, balance/transactions, … — each with a one-liner>`

**Trait for DTOs** (`app/Traits/`), if a DTO layer exists:
- `<the trait/method that excludes optional fields on update — use instead of toArray()>`

**Base classes**:
- `<the base datatable/list service (if any): what you implement (resource-class hook), what you override (query scope for role-based filtering), and the query/filter classes/interfaces injected via DI>`
- `<any other base class agents must extend rather than reinvent>`
