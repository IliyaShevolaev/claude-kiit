# Template: Service

General rules — see `_conventions.md`.

```md
# ServiceName

Расширяет класс [**ParentName**](path.md)   (if any)

Использует трейты: [**TraitName**](path.md)   (if any)

## Список полей класса   (if any)

### $fieldName

<Field meaning.>

```php
field code
```

## Список методов

### methodName

<Method description.>

Параметры:
* `Type $param` — description

```php
method code
```
```

## Пример

The example below extends the project's base datatable/list service (see CLAUDE.md) and takes a DTO param — applicable only if the project uses a DTO layer (see CLAUDE.md); otherwise pass the request/validated data directly.

````md
# EntityService

Расширяет класс [**BaseDatatableService**](../BaseDatatableService.md)

## Список методов

### query

Возвращает базовый запрос сущностей с выборкой нужных полей и сортировкой по дате обновления.

```php
private function query(): Builder
{
    return Entity::query()
        ->select(['id', 'code', 'name', 'email'])
        ->orderBy('updated_at', 'desc');
}
```

### store

Создаёт модель сущности по данным из DTO.

Параметры:
* `App\Dto\Entities\EntityRequestDto $dto` — DTO с данными сущности

```php
public function store(EntityRequestDto $dto): void
{
    Entity::create($dto->toArray());
}
```

### destroy

Удаляет переданную модель сущности.

Параметры:
* `App\Models\Entity $entity` — модель сущности

```php
public function destroy(Entity $entity): void
{
    $entity->delete();
}
```
````
