---
name: frontend-utilities-knowledge
description: "Knowledge base: project-specific frontend truth — tech stack, base services (CRUD API client, upload-form wrapper), global components (filters shell, data table, dialogs), composables, store getters, routing/menu/i18n layout, and the project-specific conventions the portable skills deliberately omit. Always-loaded source of truth other agents reference for project concretes."
disable-model-invocation: true
---

# Frontend — project-specific truth

The single source of truth for everything **specific to this project's frontend**. The portable skills `frontend-conventions-knowledge` (general Vue 3 canon) and `frontend-crud-flow-knowledge` (general CRUD flow) are intentionally project-agnostic and point here for concretes: base services, global components, composables, config and the golden code examples.

<!-- ==========================================================================
TEMPLATE — this file (and references/crud-examples.md) is filled by
`/claude-kit:setup`, which explores the real frontend and writes the concrete
project truth here. Until then it describes WHAT to discover in each section.
Every `> FILL:` note is an instruction to the writer; replace it and the
neutral placeholders with the real base services / components / composables /
paths found in the project. Delete sections that genuinely do not apply. Keep
this file lean — the heavy golden code goes into references/crud-examples.md.
=========================================================================== -->

## Tech stack

> FILL: the real frontend stack discovered from `package.json`.

- **Vue 3**: Composition API, `<script setup>` everywhere
- **State store**: `<Vuex or Pinia>`
- **UI framework**: `<Vuetify / PrimeVue / Element / … + version>`
- **Styling**: `<Bootstrap+SCSS / Tailwind / … >`
- **HTTP**: `<axios / … >`
- **i18n**: `<library + supported locales>`
- **Other**: `<toasts, date lib, VueUse, … >`

## Folder structure

> FILL: the real `resources/js` layout if it differs from the default below.

```
resources/js/
  api/          # factory functions useXxxApi() extending the base CRUD client
  composables/  # logic orchestrators
  components/   # reusable UI components
  pages/        # route-level components
  plugins/      # UI framework, store, i18n, axios; form wrapper; router modules
  utils/        # helpers and utility functions
  lang/         # i18n modules per entity + root locale files
```

## Base services & plugins

> FILL: the concrete base building blocks. Discover them by scanning `api/`,
> `plugins/`, `utils/`. Give each its import path and the methods components use.

- **Base CRUD API client** `<path, e.g. @/api/crudApi>` — extended via a `useXxxApi()` factory. Builds URLs from `<app config source>`; provides `<index, show, create, store, edit, update, delete, getFilters, getDataTable — the actual verbs>`. Custom endpoint URLs go **only** in `<the custom-URL registrar, e.g. addUrls()>`; accessed via `<the URL accessor>`.
- **Upload-form wrapper** `<path, e.g. @/plugins/uploadForm.js>` — the create/update form wrapper (use instead of raw axios or a plain form lib). `<how to instantiate; fill(), errors.get(), post(), put() (FormData + _method) — the real API>`.
- **Reference/other API variants** `<if any, e.g. a separate reference-CRUD client — and the rule "don't mix with the base client">`.

## Global components

> FILL: the shared components the index/form pages compose, with their key
> props/slots/emits.

- **Filters shell** `<component name>` — index-page shell; slots `<#actions, #settings, #filters, #table>`; models `<filters, search>`.
- **Data table** `<component name>` — server-driven table; props `<url, headers, filters, search, sort, table-name>`; exposes `<reload method, e.g. debounceGetData()>`; default filters when unwired.
- **Table settings** `<component name>` — column show/hide/reorder; props/emits.
- **Dialog** `<component name>` — dialog/drawer host for dialog-CRUD forms.
- **Shared form/table controls** `<card header, submit/cancel buttons, edit/delete icon buttons — names and key props>`.

## Composables & utils

> FILL: the reusable composables/utils to prefer over hand-rolled logic.

- **Table headers composable** `<name + signature + what it returns>`.
- **Response/error handler** `<name + what it returns; used on form submit .catch()>`.
- **Header repository location** `<where reusable/role-heavy headers live>`.
- `<pagination, sessionStorage persistence, infinite scroll, validators, date formatting, confirm dialogs, … — each with a one-liner>`

## Store & permissions

> FILL: how UI permissions/roles are resolved.

- UI permissions via `<the store getter, e.g. store.getters['auth/can']>` → `can('<perm>')`.
- Permission naming: `<*_create / *_read / *_update / *_destroy, or the project's scheme>`.
- Role helpers `<any role-flag getters/helpers to reuse>`.

## Headers & table settings

- Header shape: `<{ title, value, sortable, can, display } or the project's shape>` — `can` gates visibility per user, `display` is the default visible state.
- Column settings are stored **per table name**, so each table needs a unique name.

## Routing, menu, i18n

> FILL: the concrete wiring points.

- Router module (index/create/edit + optional detail) wired into `<the router modules aggregator path>`.
- Menu item shape: `<{ title: 'menu.xxx', icon, to, visible: 'xxx_read' } or the project's shape>`.
- i18n: per-entity modules `<lang file layout>`, imported into `<root locale files>`; `menu.*` keys location; all static text translated into every supported locale.
