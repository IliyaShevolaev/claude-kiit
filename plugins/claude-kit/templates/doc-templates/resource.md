# Template: Resource

General rules — see `_conventions.md`.

```md
# ResourceName

## Список методов

### toArray

<What data is returned to the frontend, which nested resources are used, patterns.>

```php
toArray code
```
```

## Пример

````md
# EntityResource

## Список методов

### toArray

Формирует массив данных сущности для отдачи на фронт: основные поля, имя связанной сущности из связи и переведённое название статуса.

Параметры:
* `Illuminate\Http\Request $request` — текущий HTTP-запрос

```php
public function toArray(Request $request): array
{
    return [
        'id' => $this->id,
        'entity_id' => $this->entity_id ?? $this->id,
        'name' => $this->name,
        'parent_id' => $this->parent_id ?? null,
        'parent' => $this->parent->name ?? null,
        'code' => $this->code ?? null,
        'status' => $this->status,
        'status_name' => __('enums.entity_status.' . $this->status),
        'count' => $this->count,
    ];
}
```

### getTranslatedName

Возвращает переведённое имя сущности для указанной локали, если загружена связь с переводами.

Параметры:
* `string $locale` — локаль перевода

```php
protected function getTranslatedName(string $locale): ?string
{
    if (!$this->relationLoaded('modelTranslations')) {
        return null;
    }

    return $this->modelTranslations->first()?->{$locale}['name'] ?? null;
}
```
````
