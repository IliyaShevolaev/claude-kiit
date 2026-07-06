---
name: frontend-crud-flow-knowledge
description: "Knowledge base: the canonical frontend CRUD vertical slice - API factory -> IndexPage with filters/data-table -> Form -> router/menu/i18n/permissions. Load this BEFORE implementing a new frontend entity, CRUD page, datatable, form, or admin list so the wiring follows project patterns. Project-agnostic conventions only; for the project's golden code examples and concrete base services/components it points to frontend-utilities-knowledge."
---

# Frontend CRUD flow (knowledge)

The canonical shape of a frontend CRUD vertical slice for a Vue 3 entity page. Use it as the wiring template for a new entity. For base conventions see `frontend-conventions-knowledge` — this skill shows how they combine into one slice.

This skill is **project-agnostic** — it carries between projects 1:1. It describes the flow in prose and contains **no code examples** and **no project-specific base services/components**. For the project's full golden code examples, concrete base services, global components and pitfalls, read **`frontend-utilities-knowledge` → `references/crud-examples.md`**.

Canonical flow: `useXxxApi -> IndexPage(filters + table) -> Form -> router module -> menu -> i18n -> permissions`.

## Optional layers - don't over-build

Not every entity needs every layer:
- **Filters** — only when the backend exposes filter data or the table needs non-search filtering.
- **Table settings** — only when users must hide/reorder columns; otherwise a static header list is enough.
- **Dialog form** — good for small CRUD. Use a full-page form for large multi-section forms or file uploads.
- **Repository/composable for headers** — only when headers are reused, role-aware, or too large for the index page.
- **Custom API methods** — only for endpoints beyond base CRUD.

## 1. API — factory extending the base CRUD client

- Every entity API is a factory function `useXxxApi()` returning an instance that extends the shared **base CRUD API client** (base CRUD verbs + URL building from app config).
- Custom endpoint URLs belong in one place — the base client's custom-URL registrar — and are accessed via the client's URL accessor.
- Add an explicit wrapper method only when a component calls that endpoint directly.
- The concrete base client, its verbs and the reference-CRUD variant → `frontend-utilities-knowledge`.

## 2. Index page — filters shell + server-driven table

- The default admin list is a **filters/actions shell** wrapping a **server-driven data table**: the shell owns actions, search, filters, table settings and the table slot.
- The table is fed the datatable URL, headers, filters, search and sort; it reloads via its exposed debounce-reload method after create/update/delete.
- Wire filters only when needed; the table defaults to no filters otherwise. Initialize every filter key used in the template.
- Row actions (edit/delete) and the "add" action are gated by UI permissions.
- The concrete components (the filters shell, the data table, icon buttons, the dialog) and their props/slots → `frontend-utilities-knowledge`.

## 3. Headers & table settings

- Header objects carry `title`, `value`, `sortable`, a permission gate and a default-visible flag.
- Column settings are stored **per table name**, so each table needs a unique name.
- Prefer the shared headers composable over hand-written clone/watch logic; move headers into a repository only when reused or role-heavy.

## 4. Form — create/update via the upload-form wrapper

- All create/update forms use the project's **upload-form wrapper** (reactive form object with `fill`, `errors.get`, `post`, `put`) — not raw axios and not a plain form lib. `put` is converted to multipart FormData with `_method`.
- Load edit payloads with `fill`, surface backend validation via `errors.get('field')`, submit with `post` (create) / `put` (update), handle failures with the shared response handler.
- Dialog forms need a changing `:key` to reset local state between opens.
- The concrete wrapper and response handler → `frontend-utilities-knowledge`.

## 5. Dialog form vs full-page form

- **Dialog CRUD** — small forms that return to the same table.
- **Page CRUD** — large, multi-section, file-heavy, or route-level detail pages (`index` / `create` / `edit` / optional `detail`); success navigates back to the index route.

## 6. Router, menu, permissions, i18n

- A router module (index/create/edit + optional detail) wired into the app's router modules aggregator.
- A menu item translated via `menu.*` and gated by the entity's read permission.
- UI permissions via the store's `can` getter; permission naming `*_create` / `*_read` / `*_update` / `*_destroy`.
- i18n: per-entity language modules imported into the root language files; all static text translated into every supported language.
- The concrete store getter, router aggregator path and i18n file layout → `frontend-utilities-knowledge`.

## Golden code examples, pitfalls & checklist

When implementing or refactoring a CRUD feature, read **`frontend-utilities-knowledge` → `references/crud-examples.md`** — kept out of this portable skill on purpose. It has:
- full API-factory / IndexPage / Form / router / menu / i18n examples,
- the common-pitfalls block (a plain form lib vs the upload-form wrapper, uninitialized filter keys, missing custom-URL entries, dialog `:key`, non-unique table names),
- the implementation checklist.
