# Template: DTO

Applies only if the project uses a DTO layer (see CLAUDE.md); otherwise skip it. General rules — see `_conventions.md`. The parent shown here (`Spatie\LaravelData\Data`) is an example — use whatever base the project's DTO layer defines, and write a vendor base as inline code with no link.

```md
# DtoName

<Short purpose: what it carries and between which layers.> Расширяет `Spatie\LaravelData\Data`.

## Список полей класса

### $fieldName

<Field meaning in domain terms.>

```php
public string $fieldName;
```
```

## Пример

````md
# EntityRequestDto

Переносит валидированные данные сущности из реквеста в сервис. Расширяет `Spatie\LaravelData\Data`.

## Список полей класса

### $name

Название сущности.

```php
public string $name;
```

### $code

Код сущности.

```php
public string $code;
```

### $externalId

Внешний идентификатор.

```php
public string $externalId;
```

### $reference

Дополнительная ссылка/референс.

```php
public ?string $reference;
```

### $status

Статус сущности.

```php
public EntityStatusEnum $status;
```

### $attachedFiles

Прикреплённые к сущности файлы.

```php
public ?array $attachedFiles;
```
````
