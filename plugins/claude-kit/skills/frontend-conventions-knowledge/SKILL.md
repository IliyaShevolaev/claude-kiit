---
name: frontend-conventions-knowledge
description: "Knowledge base: the frontend architecture canon (Vue 3 SPA) — folder structure, code rules, data-handling patterns. Shared source of truth for frontend authoring and review. Not a task — injected as context."
disable-model-invocation: true
---

# Frontend conventions (knowledge)

The canonical architecture and code standard for the project's frontend. This is the single source of truth used both when authoring frontend code and when reviewing it.

## Tech stack

- **Vue 3**: Composition API, `<script setup>` everywhere
- **State store**: the project's state store, Vuex or Pinia (see CLAUDE.md) — modular stores, actions and mutations/setters as the store dictates
- **UI framework**: the project's UI framework (see CLAUDE.md)
- **Styling**: the project's styling conventions (see CLAUDE.md)
- **HTTP**: axios via a base service (`crudApi.js`)

## Architecture principles

### Folder structure

```
resources/js/
  api/          # factory functions useExamplesApi() with base CRUD
  composables/  # logic orchestrators useExamplesTable(), useExampleForm()
  components/   # reusable UI components
  pages/        # route-level components
  plugins/      # initialization of the UI framework, store, i18n, axios
  utils/        # helpers and utility functions
```

### Code rules

- Composables are the primary tool for encapsulating logic. They accept the API and Store as arguments
- State variables: descriptive names with auxiliary verbs (`isLoading`, `hasError`, `isDataLoaded`)
- Always `async/await` for API calls, explicit loading states — but write them via Promise Chaining `.then().catch().finally()`
- `defineProps` and `defineEmits` — always explicit
- `toRefs` when destructuring props to preserve reactivity
- JSDoc for complex composables and functions
- Directories — lowercase-with-dashes (`components/auth-wizard`)
- Composable naming: `use[Name]` (useExamplesTable, useAuthForm)
- Write all functions reactively, no plain js functions — only `const funcname = () => {};`

## Data-handling patterns

- Before implementing a new frontend entity, CRUD page, datatable, admin list, or form, load `frontend-crud-flow-knowledge`: it is the canonical `crudApi -> top-filters/data-table -> uploadForm -> router/menu/i18n/permissions` wiring template.
- Server-side pagination, search, filtering — in specialized composables
- Synchronizing local state with the store for shared data (counters, statuses)
- Functions (not arrows) for pure functions — for hoisting and readability
