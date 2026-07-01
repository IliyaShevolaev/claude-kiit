---
name: backend-conventions-knowledge
description: "Knowledge base: the backend architecture canon (Laravel 11 / PHP 8.3+) — data flow, layer rules, code rules, API standards. Shared source of truth for backend authoring and review. Not a task — injected as context."
disable-model-invocation: true
---

# Backend conventions (knowledge)

The canonical architecture and code standard for the project's backend. This is the single source of truth used both when authoring backend code and when reviewing it.

## Tech stack
- **Framework:** Laravel 11.x
- **PHP:** 8.3+ with strict typing (`declare(strict_types=1)` in every file)
- **Database:** the project's configured database (see CLAUDE.md)
- **Auth:** the project's auth package (see CLAUDE.md)
- **Key packages** (see CLAUDE.md for what the project actually uses):
  - a DTO package for typed data between layers, if the project uses a DTO layer
  - an RBAC / permissions package
  - a media / file-handling package
  - the project's datatable package, if any, for server-side pagination and filtering

## Architecture patterns (strictly mandatory)

### Data flow
`Request → FormRequest (validation) → DTO → Service → Model → Resource → Response`

> The DTO step applies only if the project uses a DTO layer (see CLAUDE.md); otherwise the validated request feeds the service directly.

> Implementing a new entity / endpoint / typical CRUD task — load the `crud-flow-knowledge` skill first: it is the canonical vertical-slice template with golden examples for each layer.

### Controllers
- Thin, 3 actions: authorization (`$this->authorize()`), calling the service, returning a Resource (if needed)
- No business logic in controllers. Keep methods as simple and short as possible

### Resources (`app/Http/Resources`)
- Returned data is **always wrapped in a Resource in the controller** when the endpoint returns data — never return raw models/arrays, and never return a Resource from a service (the service returns the model/data, the controller wraps it).
- When variants share fields → a base Resource + child Resources that extend it; don't duplicate field maps.
- When a role must not see certain fields → expose role-specific child Resources and pick the class via a static `resolveClass()` that inspects the authenticated user (role / user type). Use it in the controller (`SomeResource::resolveClass()::make($model)`):
  ```php
  public static function resolveClass(): string
  {
      $authModel = auth_model();

      if (
          $authModel?->model?->hasRole(RoleNamesEnum::ADMIN->value) ||
          $authModel?->user_type === SomeModel::class
      ) {
          return ExampleAdminResource::class;
      }

      return ExampleClientResource::class;
  }
  ```
- Expose relations only via `whenLoaded`; never dump the whole model when a role-restricted subset is required.

### Request (App\Http\Requests)
- A custom FormRequest, never the base `Request`. Do not write `authorize()` — it defaults to `true`; authorization lives in the controller
- `bail` is mandatory on every field; rules are arrays `['bail', 'required', ...]`, never pipe strings
- Incoming ids validate as `exists:...,id,deleted_at,NULL`; enums via `Rule::enum()`; uniqueness via `->whereNull('deleted_at')->ignore($this->id)`
- Translations of all attributes in `public function attributes(): array` are mandatory
- Never pass this class into a service — always wrap it in a DTO (if the project uses a DTO layer, see CLAUDE.md)

### DTO (`app/Data`) — if the project uses a DTO layer (see CLAUDE.md)
- Use the project's DTO package base class
- Strict typing of all fields
- Validation via attributes

### Enums (`app/Enums`)
- All statuses and constants
- Translation support via a `label()` method or similar
- Backed enums (`string` or `int`)

### Models
- Explicit `$fillable`
- Explicit `casts` for types where needed
- Relationships via methods with return type hints
- Scopes for frequent queries or explicit visibility constraints

### Migrations
- Detailed, with explicit column types where needed
- Indexes for FKs and frequently filtered fields
- The `down()` method correctly rolls back the changes

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
11. Satisfy the static analyzer at the project's configured level (see CLAUDE.md)

## API standards

- RESTful routes in `routes/api.php`
- Authorization via the project's auth middleware (see CLAUDE.md)
- Policies for action authorization
- Errors via standard Laravel exception handlers
