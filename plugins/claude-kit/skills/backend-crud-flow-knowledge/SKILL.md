---
name: backend-crud-flow-knowledge
description: "Knowledge base: the canonical backend CRUD vertical slice — Controller → custom Request → DTO (optional) → Service (+ base datatable service). Load this BEFORE implementing a new entity, endpoint, or CRUD feature so the typical wiring is done right. Project-agnostic conventions only; for the project's golden code examples and concrete base classes it points to backend-utilities-knowledge."
---

# Backend CRUD flow (knowledge)

The canonical shape of a backend CRUD vertical slice. Use it as the wiring template for a new entity / endpoint / typical CRUD task. For the underlying rules see the `backend-conventions-knowledge` canon — this skill shows how those rules combine into one slice.

This skill is **project-agnostic** — it carries between projects 1:1. It describes the flow in prose and contains **no code examples** and **no project-specific classes/helpers**. For the project's full golden code examples, concrete base classes and pitfalls, read **`backend-utilities-knowledge` → `references/crud-examples.md`**.

Data flow: `Request → FormRequest (validation) → DTO (optional) → Service → Model → Resource → Response`.

## Optional layers — don't over-build

Not every entity needs every layer (KISS / YAGNI):
- **DTO** — only if the project uses a DTO layer (→ `backend-utilities-knowledge`); otherwise the validated request feeds the service directly.
- **Resource** — only when the task requires returning data. `store` / `update` are usually `void`.
- **Filter / Query classes** — only for list endpoints backed by the base datatable service.
- **Custom Rule object** — only for validation too complex for inline rules.
- **DTO "optional fields" trait** — only when the DTO has optional fields used on `update` (so `update` doesn't overwrite fields absent from the request).

## 1. Controller — exactly 3 actions, zero business logic

A controller method does only three things, in order:

1. **Authorization** — a permission name, or a policy check (`$this->authorize(...)`).
2. **Call the service** — nothing else. No fetching the current user, no `if/else`, no business logic at all.
3. **Return a Resource** — only if the task strictly requires returned data. Otherwise `void`.

- The controller accepts a **custom Request class — never the base `Request`**.
- The exact `authorize()` signature (whether the second policy argument is wrapped in an array) is a project base-controller detail → `backend-utilities-knowledge`.
- With a DTO layer, wrap the validated request in a DTO at the controller (`SomeData::from($request)`); without one, pass `$request->validated()`.

## 2. Request — custom FormRequest, validation only

- `extends FormRequest`.
- **Never write `authorize(): bool`.** If omitted it defaults to `true`. Authorization lives in the controller.
- `bail` is **mandatory** on every field — stop on the first failure.
- Rules are **always an array** (`['bail', 'required', 'string']`), never a pipe string.
- Incoming ids → always validate existence; when the project uses soft deletes, exclude soft-deleted rows in the `exists` rule.
- Enums → `Rule::enum(SomeEnum::class)`.
- Numbers → bound with `min` / `max` / `decimal`.
- Uniqueness → scope out soft-deleted rows and ignore self on update.
- Complex validation → a custom Rule object.
- Need extra data not in the request to validate against → `withValidator()`.
- Translate user-facing attribute names in `attributes()`.

## 3. DTO — the boundary; the Request never travels further (if the project uses a DTO layer)

- The Request class **stays in the controller only**. Everything is wrapped into a DTO and travels the system in that wrapper. Never pass a Request into a service.
- Use the project's DTO package base class. Validated input → **strict types**.
- Optional, must-not-be-null fields → type them so `update` can skip fields absent from the request. The project trait/method that drops absent optionals on `update` → `backend-utilities-knowledge`.
- DTO → Model on `create` via `$dto->toArray()`; on `update` via the "optional fields" method when the DTO has optional fields.
- Need to pass a non-obvious array between services → wrap it in a DTO too, don't pass loose arrays.

> If the project has no DTO layer, skip this section and pass `$request->validated()` to the service.

## 4. Service — where all the logic lives

- **Plain service**: all business logic happens here — fetching the current user, branching, side effects, transactions, events.
- **List endpoints**: use the project's **base datatable/list service** — it wraps the query in the project's datatable package. You provide a query class, a filter class and the resource class; you override hooks for server-side (non-user-driven) constraints such as role-based visibility, and for extra payload passed alongside the table data. The concrete base class, its interfaces and hook names → `backend-utilities-knowledge`.

## Golden code examples, pitfalls & checklist

When implementing or refactoring a CRUD feature, read **`backend-utilities-knowledge` → `references/crud-examples.md`** — kept out of this portable skill on purpose. It has:
- full Controller / Request / DTO / Service / datatable-service examples,
- the common-pitfalls block (wrong Request type, useless `authorize()` in FormRequest, business logic in the controller, pipe-string rules, `toArray()` vs the update method, returning a Resource from a service, …),
- the implementation checklist.
