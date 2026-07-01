# Template: Request

General rules — see `_conventions.md`.

```md
# RequestName

Использует трейты: [**TraitName**](path.md)   (if any)

## Правила валидации

```php
rules() array
```
```

## Пример

````md
# EntityUpdateRequest

## Правила валидации

```php
public function rules(): array
{
    return [
        'name' => 'bail|required|string|min:3|max:255',
        'code' => 'bail|required|string|max:255',
        'external_id' => 'bail|required|string|max:255',
        'reference' => 'bail|nullable|string|max:255',
        'status' => ['bail', 'required', Rule::enum(EntityStatusEnum::class)],
        'attached_files' => 'bail|nullable|array',
        'attached_files.*' => 'bail|nullable',
    ];
}
```
````
