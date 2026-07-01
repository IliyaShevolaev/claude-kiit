# Template: Model

General rules — see `_conventions.md`. The relationship type in the «Связи» section is the only allowed external link (Laravel 11.x).

```md
# ModelName

Расширяет класс `Illuminate\Database\Eloquent\Model`

## Список полей класса

### $fieldName

<Field meaning.>

```php
field code
```

## Список методов

### methodName

<Method description.>

```php
method code
```

## Связи

### relationName

Связь [RelationType](https://laravel.com/docs/11.x/eloquent-relationships#relationship-type) с моделью [**ModelName**](path.md).

```php
relation code
```
```

## Пример

````md
# Entity

Расширяет класс `Illuminate\Database\Eloquent\Model`

Использует трейты: `Illuminate\Database\Eloquent\SoftDeletes`

## Список полей класса

### $fillable

Поля, разрешённые для массового заполнения.

```php
protected $fillable = [
    'parent_id',
    'status',
    'started_at',
    'finished_at',
];
```

## Связи

### parent

Связь [BelongsTo](https://laravel.com/docs/11.x/eloquent-relationships#one-to-many-inverse) с моделью [**ParentModel**](../Parents/ParentModel.md).

```php
public function parent(): BelongsTo
{
    return $this->belongsTo(ParentModel::class, 'parent_id');
}
```
````
