# Template: Enum

General rules — see `_conventions.md`. Cases go under `## Значения` (not «Список полей класса»).

```md
# EnumName

<Short purpose of the enum.>

## Значения

### CASE_NAME

<Value meaning.>

```php
case CASE_NAME = 'value';
```

## Список методов   (only if the enum has methods)

### methodName

<Method description.>

```php
method code
```
```

## Пример

````md
# EntityStatusEnum

Статусы сущности.

## Значения

### WAITING

Ожидается обработка.

```php
case WAITING = 'waiting';
```

### ACTIVE

Сущность активна.

```php
case ACTIVE = 'active';
```

### RETURN

Оформлен возврат.

```php
case RETURN = 'return';
```

### CANCEL

Обработка отменена.

```php
case CANCEL = 'cancel';
```
````
