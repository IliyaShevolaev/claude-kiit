# Template: Controller

General rules — see `_conventions.md`.

```md
# ControllerName

Расширяет класс [**Controller**](path/to/Controller.md)

## Список методов

### methodName

<One or two sentences on what the method does. If it has params, mention them, e.g.: Принимает [**ClassName**](path.md) $param — what the param does.>

```php
method code
```
```

## Пример

````md
# EntityController

Расширяет класс [**Controller**](../Controller.md)

## Список методов

### __construct

Инициализирует зависимости контроллера. Принимает [**EntityService**](../../../Services/Entities/EntityService.md) $service — сервис с бизнес-логикой сущности.

```php
public function __construct(protected EntityService $service)
{
    //
}
```

### getFilters

Проверяет доступ через `$this->authorize()` и возвращает данные для фильтров из `$this->service->getFilters()`.

```php
public function getFilters(): JsonResponse
{
    $this->authorize('entities_read');
    return response()->json($this->service->getFilters());
}
```

### getDataTable

Возвращает данные для дататейбла сущностей. Принимает [**DataTableRequest**](../../Requests/DataTableRequest.md) $request — реквест с параметрами выборки.

```php
public function getDataTable(DataTableRequest $request): JsonResponse
{
    $this->authorize('entities_read');
    return $this->service->getDataTable(DataTableDto::fromRequest($request))->toJson();
}
```

### update

Обновляет сущность по переданным данным. Принимает [**Entity**](../../../Models/Entities/Entity.md) $entity — модель сущности и [**EntityUpdateRequest**](../../Requests/Entities/EntityUpdateRequest.md) $request — реквест с валидированными данными.

```php
public function update(Entity $entity, EntityUpdateRequest $request): void
{
    $this->authorize('entities_update');
    $this->service->update($entity, EntityRequestDto::from($request->validated()));
}
```

### destroy

Удаляет переданную сущность. Принимает [**Entity**](../../../Models/Entities/Entity.md) $entity — модель сущности.

```php
public function destroy(Entity $entity): void
{
    $this->authorize('entities_destroy');
    $this->service->destroy($entity);
}
```
````
