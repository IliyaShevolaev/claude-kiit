# Template: Generic (fallback)

Use this template when the file matches none of the specific templates: Event, Observer, Policy, Notification, Export, Rule, Provider, Cast, Middleware, Mapper, Interface, Console Command, etc. Pick the relevant sections from the canonical set; skip the empty ones.

General rules — see `_conventions.md`.

```md
# ClassName

<Short purpose of the class.> Extends / implements per `_conventions.md` (only if applicable).

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
