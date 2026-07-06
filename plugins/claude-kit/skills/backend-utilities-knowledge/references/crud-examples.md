# Backend CRUD flow — golden code examples

The canonical worked example of a backend CRUD vertical slice. Concrete, project-specific companion to the project-agnostic `backend-crud-flow-knowledge` skill: it shows those conventions applied with the real project classes, helpers and base classes.

<!-- ==========================================================================
TEMPLATE — `/claude-kit:setup` rewrites this with the project's real classes,
namespaces, base datatable service, DTO base/trait and helpers discovered from
the codebase. Until then the examples below are NEUTRAL placeholders
(`Entity` / `Example`, `Spatie\LaravelData`, `BaseDatatableService`, `auth_model()`):
replace them with what the project actually uses. If the project has NO DTO
layer, drop the DTO section and pass `$request->validated()` to the service.
=========================================================================== -->

> **This is a template of the wiring, not an entity to copy.** Take the structure and the project-specific patterns, not the `Entity` fields.

Data flow: `Request → FormRequest (validation) → DTO (optional) → Service → Model → Resource → Response`.

---

## 1. Controller — exactly 3 actions, zero business logic

**Project specifics:**
- The controller accepts a **custom Request class — never the base `Request`**.
- If the base controller overrides `authorize()` so the **second argument is always an array**:
  ```php
  /** @param array<mixed> $arguments */
  public function authorize(mixed $ability, array $arguments = []): mixed
  ```
  then a policy check is `$this->authorize('create', [Entity::class])` — model class wrapped in `[]`, plus any extra policy arguments inside the same array.

```php
<?php

declare(strict_types=1);

namespace App\Http\Controllers\Examples;

use App\Http\Controllers\Controller;
use App\Http\Requests\Examples\StoreEntityRequest;
use App\Http\Requests\Examples\UpdateEntityRequest;
use App\Http\Resources\Examples\EntityResource;
use App\Models\Examples\Entity;
use App\Services\Examples\EntityService;

class EntityController extends Controller
{
    public function __construct(private readonly EntityService $service)
    {
    }

    public function store(StoreEntityRequest $request): void
    {
        $this->authorize('create', [Entity::class]);

        $this->service->create(StoreEntityData::from($request));
    }

    public function update(UpdateEntityRequest $request, Entity $entity): void
    {
        $this->authorize('update', [Entity::class, $entity]);

        $this->service->update($entity, UpdateEntityData::from($request));
    }

    public function show(Entity $entity): EntityResource
    {
        $this->authorize('view', [Entity::class, $entity]);

        return EntityResource::make($entity);
    }
}
```

> If the project has no DTO layer, pass the validated data instead, e.g. `$this->service->create($request->validated())`.

Permission-name form (when there is no policy, just a permission gate):

```php
$this->authorize('examples_export');
```

Role-restricted response fields → pick the Resource class via a role-aware resolver that inspects the current user, used in the controller as `SomeResource::resolveClass()::make($model)`:

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

---

## 2. Request — custom FormRequest, validation only

- `bail` is **mandatory** on every field.
- Rules are **always an array**, never a pipe string.
- Incoming ids → exclude soft-deleted when the project uses soft deletes: `exists:...,id,deleted_at,NULL`.
- Uniqueness → `Rule::unique('examples', 'email')->whereNull('deleted_at')->ignore($this->id)`.
- Translate user-facing attribute names in `attributes()`.

```php
<?php

declare(strict_types=1);

namespace App\Http\Requests\Examples;

use App\Enums\Examples\EntityStatusEnum;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Validator;

class UpdateEntityRequest extends FormRequest
{
    /** @return array<string, array<int, mixed>> */
    public function rules(): array
    {
        return [
            'name' => ['bail', 'required', 'string', 'max:255'],
            'email' => [
                'bail',
                'required',
                'email',
                Rule::unique('examples', 'email')->whereNull('deleted_at')->ignore($this->id),
            ],
            'status' => ['bail', 'required', Rule::enum(EntityStatusEnum::class)],
            'manager_id' => ['bail', 'nullable', 'exists:users,id,deleted_at,NULL'],
            'rating' => ['bail', 'nullable', 'numeric', 'min:0', 'max:5', 'decimal:0,2'],
            'contacts' => ['bail', 'sometimes', 'array'],
            'contacts.*.phone' => ['bail', 'required', 'string', 'max:32'],
        ];
    }

    public function withValidator(Validator $validator): void
    {
        $validator->after(function (Validator $validator): void {
            if ($this->status === EntityStatusEnum::Blocked->value && $this->hasOpenChildren()) {
                $validator->errors()->add('status', __('examples.cannot_block_with_open_children'));
            }
        });
    }

    /** @return array<string, string> */
    public function attributes(): array
    {
        return [
            'name' => __('examples.attributes.name'),
            'email' => __('examples.attributes.email'),
        ];
    }
}
```

---

## 3. DTO — the boundary; the Request never travels further (if the project uses a DTO layer)

- The Request class **stays in the controller only**. Everything is wrapped into a DTO and travels the system in that wrapper. Never pass a Request into a service.
- Use the project's DTO package base class. Validated input → **strict types**.
- Optional, must-not-be-null fields → type them `Optional` (not nullable). Use the project's optional-fields trait → `toFillable()` so `update` does not overwrite model fields that were absent from the request.
- DTO → Model on `create` via `$dto->toArray()`; on `update` via `$dto->toFillable()` (when there are `Optional` fields).

> If the project has no DTO layer, skip this section entirely and pass `$request->validated()` to the service.

```php
<?php

declare(strict_types=1);

namespace App\Data\Examples;

use App\Enums\Examples\EntityStatusEnum;
use App\Traits\HasOptionalFields;
use Spatie\LaravelData\Data;
use Spatie\LaravelData\Optional;

class UpdateEntityData extends Data
{
    use HasOptionalFields;

    public function __construct(
        public string $name,
        public string $email,
        public EntityStatusEnum $status,
        public ?int $manager_id,
        public float|Optional $rating,
    ) {
    }
}
```

`from()` maps the validated request automatically; `toFillable()` drops `Optional` fields that were not provided, so an `update` only touches what actually came in.

---

## 4. Service — where all the logic lives

### Plain service

```php
<?php

declare(strict_types=1);

namespace App\Services\Examples;

use App\Data\Examples\StoreEntityData;
use App\Data\Examples\UpdateEntityData;
use App\Models\Examples\Entity;

class EntityService
{
    public function create(StoreEntityData $data): Entity
    {
        return Entity::create($data->toArray());
    }

    public function update(Entity $entity, UpdateEntityData $data): Entity
    {
        $entity->update($data->toFillable());

        return $entity;
    }
}
```

### Datatable service (list endpoints)

The project's base datatable/list service — the common approach when a service backs a table. It wraps the query in the project's datatable package itself. You only provide:
- the query class implementing the query interface,
- the filter class implementing the filter interface,
- the resource class:
  ```php
  /** @return class-string<JsonResource> */
  abstract protected function resourceClass(): string;
  ```

Hooks you can override:
- **`scopeQuery`** — server-side constraints **not driven by the user**, e.g. role-based visibility filters.
- **`additionalData`** — extra payload passed through as `datatable->with(...)`.

```php
<?php

declare(strict_types=1);

namespace App\Services\Examples;

use App\Http\Resources\Examples\EntityResource;
use App\Services\BaseDatatableService;
use Illuminate\Database\Eloquent\Builder;

class EntityDatatableService extends BaseDatatableService
{
    protected function resourceClass(): string
    {
        return EntityResource::class;
    }

    protected function scopeQuery(Builder $query): Builder
    {
        return $query->byRoles(auth_model());
    }

    /** @return array<string, mixed> */
    protected function additionalData(): array
    {
        return ['statuses' => EntityStatusEnum::cases()];
    }
}
```

---

## Common pitfalls

```php
// ❌ Base Request instead of a custom one
public function store(Request $request) {}
// ✅ Custom Request class
public function store(StoreEntityRequest $request): void {}

// ❌ authorize() written in the FormRequest (useless — auth is in the controller)
public function authorize(): bool { return true; }
// ✅ Omit it entirely

// ❌ Business logic / current user in the controller
public function store(StoreEntityRequest $request) {
    $user = auth_model();
    if ($user->isManager()) { /* ... */ }
}
// ✅ Controller only authorizes + delegates; logic lives in the service

// ❌ authorize without the array second argument (when the base method expects an array)
$this->authorize('create', Entity::class);
// ✅ Second argument is always an array
$this->authorize('create', [Entity::class]);

// ❌ Pipe-string rules, no bail
'email' => 'required|email|unique:examples',
// ✅ Array rules with bail, soft-delete-aware uniqueness
'email' => ['bail', 'required', 'email', Rule::unique('examples', 'email')->whereNull('deleted_at')->ignore($this->id)],

// ❌ exists without excluding soft-deleted
'manager_id' => ['exists:users,id'],
// ✅ Exclude soft-deleted
'manager_id' => ['exists:users,id,deleted_at,NULL'],

// ❌ Passing the Request deeper into the system
$this->service->create($request);
// ✅ Wrap into a DTO at the controller boundary (or pass $request->validated() if there is no DTO layer)
$this->service->create(StoreEntityData::from($request));

// ❌ toArray() on update wipes fields absent from the request
$entity->update($data->toArray());
// ✅ toFillable() keeps untouched fields intact when DTO has Optional fields
$entity->update($data->toFillable());

// ❌ Returning a Resource from the service
return EntityResource::make($entity); // inside the service
// ✅ Service returns the model/data; the controller wraps it in a Resource
```

## Checklist

- [ ] Controller method = authorize → service call → (Resource only if required, else `void`)
- [ ] No business logic, no current-user fetching, no `if/else` in the controller
- [ ] Custom Request class injected — never the base `Request`
- [ ] `$this->authorize()` second argument matches the project's base controller signature (array when required)
- [ ] FormRequest has no `authorize()` method
- [ ] Every rule starts with `bail`; rules are arrays, not pipe strings
- [ ] Incoming ids use `exists:...,id,deleted_at,NULL` when the project uses soft deletes
- [ ] Enums via `Rule::enum()`; numbers bounded with `min`/`max`/`decimal`
- [ ] Uniqueness uses `->whereNull('deleted_at')->ignore($this->id)` where needed
- [ ] Extra cross-field checks in `withValidator()`; complex rules as custom Rule objects
- [ ] Request wrapped into a DTO at the controller (if the project uses a DTO layer); never passed deeper
- [ ] Non-required, non-null DTO fields typed `Optional`; `update` uses `toFillable()`
- [ ] All logic in the service; datatable lists extend the project's base datatable/list service
- [ ] `scopeQuery` for role/visibility constraints; `additionalData` for `with()` payload
