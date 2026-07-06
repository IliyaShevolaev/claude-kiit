---
name: backend-conventions-knowledge
description: "Knowledge base: the backend architecture canon (Laravel 11 / PHP 8.3+) — data flow, layer rules, code rules, API standards. Shared source of truth for backend authoring and review. Not a task — injected as context. Project-agnostic: it holds no project-specific classes, helpers or config — those live in backend-utilities-knowledge."
disable-model-invocation: true
---

# Backend conventions (knowledge)

The canonical architecture and code standard for a Laravel 11 backend. Single source of truth used both when authoring backend code and when reviewing it.

This skill is **project-agnostic** — it carries between projects 1:1. It contains conventions only, **no code examples** and **no project-specific classes, helpers, base classes, packages or config**. For the project's concrete tech stack, utilities, base classes and worked code examples see `backend-utilities-knowledge`.

## Architecture patterns (strictly mandatory)

### Data flow
`Request → FormRequest (validation) → DTO → Service → Model → Resource → Response`

> The DTO step applies only if the project uses a DTO layer (→ `backend-utilities-knowledge`); otherwise the validated request feeds the service directly.

> Implementing a new entity / endpoint / typical CRUD task — load the `backend-crud-flow-knowledge` skill first: it is the canonical vertical-slice template. For the project's concrete golden examples it points you to `backend-utilities-knowledge`.

### Controllers
- Thin, 3 actions: authorization, calling the service, returning a Resource (only if the endpoint returns data).
- No business logic in controllers. Keep methods as simple and short as possible.
- The current user, branching and side effects belong in the service, never in the controller.

### Resources (`app/Http/Resources`)
- Returned data is **always wrapped in a Resource in the controller** when the endpoint returns data — never return raw models/arrays, and never return a Resource from a service (the service returns the model/data, the controller wraps it).
- When variants share fields → a base Resource + child Resources that extend it; don't duplicate field maps.
- When a role must not see certain fields → expose role-specific child Resources and pick the class via a role-aware resolver that inspects the authenticated user (role / user type), then use it in the controller. (Project-specific resolver helper → `backend-utilities-knowledge`.)
- Expose relations only via `whenLoaded`; never dump the whole model when a role-restricted subset is required.

### Request (`App\Http\Requests`)
- A custom FormRequest, never the base `Request`. Do not write `authorize()` — it defaults to `true`; authorization lives in the controller.
- `bail` is mandatory on every field; rules are arrays `['bail', 'required', ...]`, never pipe strings.
- Incoming ids validate existence; when the project uses soft deletes, exclude soft-deleted rows in the `exists` rule. Enums via `Rule::enum()`; uniqueness scoped to non-deleted rows and ignoring self on update.
- Translate user-facing attribute names in `public function attributes(): array`.
- Never pass this class into a service — always wrap it in a DTO (if the project uses a DTO layer → `backend-utilities-knowledge`).

### DTO (`app/Data`) — if the project uses a DTO layer
- Use the project's DTO package base class (→ `backend-utilities-knowledge`).
- Strict typing of all fields.
- Validation via attributes where appropriate.
- The DTO is the boundary: the Request stays in the controller, everything downstream travels as a DTO.

### Enums (`app/Enums`)
- All statuses and constants.
- Translation support via a `label()` method or similar.
- Backed enums (`string` or `int`).

### Models
- Explicit `$fillable`.
- Explicit `casts` for types where needed.
- Relationships via methods with return type hints.
- Scopes for frequent queries or explicit visibility constraints.

### Migrations
- Detailed, with explicit column types where needed.
- Indexes for FKs and frequently filtered fields.
- The `down()` method correctly rolls back the changes.

## Code rules

1. **Always** `declare(strict_types=1);` at the start of every PHP file
2. **Never** write comments in code
3. Follow the SOLID, KISS, DRY, YAGNI principles
4. No abstractions and no speculative "future-proofing" code
5. PSR-12 code style
6. Return type hints are mandatory everywhere
7. Nullable types via `?Type`, not via `Type|null` unless a union is needed
8. Don't list all fields when creating a model from a DTO — use `$dto->toArray()` where possible
9. Don't add indentation when listing fields `'key' => $value` — always do it this way
10. Don't return JSON resources from services — wrap them into a resource in the controller instead
11. Satisfy the static analyzer's typing (the required level is defined per project → `backend-utilities-knowledge`)

## API standards

- RESTful routes in `routes/api.php`
- Authorization via the project's auth middleware (→ `backend-utilities-knowledge`)
- Policies for action authorization
- Errors via standard Laravel exception handlers
