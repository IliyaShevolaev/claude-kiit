# Documentation formatting rules (canonical)

These rules are mandatory for **every** template in this folder. A template defines the structure of a specific layer; this file defines the shared conventions that must never be broken. If a layer has no dedicated file, use `generic.md`.

## Section headings — use exactly these names

| Section | Heading (verbatim) | Item heading |
|---|---|---|
| Class properties / DTO fields | `## Список полей класса` | `### $name` (**with** `$`) |
| Methods | `## Список методов` | `### methodName` (**no** `$`, **no** `{#anchor}`) |
| Eloquent relations (models) | `## Связи` | `### relationName` |
| Enum cases | `## Значения` | `### CASE_NAME` (**no** `$`) |
| Request validation | `## Правила валидации` | — |

Forbidden variants: `## Методы`, `## Свойства`, `## Список методов класса`, `## Варианты`, `## Список значений`, `## Интерфейсы`, `## Трейты`. Never add `{#anchor}` suffixes to headings.

## Links — the single rule that kills the inconsistency

- **Class that has a local doc** in the documentation root (`storage/documentation/` by default — see CLAUDE.md) → bold relative `.md` link: `[**ClassName**](relative/path.md)`.
- **Framework / vendor class** (parent, trait, interface, or a param type) with **no** local doc → write it as **inline code with no link**: `` `Spatie\LaravelData\Data` ``, `` `Illuminate\Console\Command` ``. **Never** link to laravel.com / any package docs, and never guess a package version.

## Inheritance / traits / interfaces line

Right under the `# Title` (one blank line before and after), only the lines that apply, in this order:

```md
Расширяет класс [**Parent**](path.md)   (or inline-code `Vendor\Framework\Class`)

Использует трейты: [**TraitA**](path.md), `Vendor\TraitB`

Реализует интерфейсы: [**InterfaceA**](path.md), `Vendor\InterfaceB`
```

## Field / property / param descriptions

- The list of fields/params **must match the code block 1:1**: every property in the code is described, and you describe none that isn't there.
- A parameter must not have an empty description.

## Method description structure

1. One or two sentences: what the method does (in Russian).
2. If there are parameters — a list under `Параметры:` — `* \`Type $name\` — description`. If there are none, omit the block entirely.
3. If it overrides a parent method — state it explicitly with a link.
4. A ```` ```php ```` block with the method body.

## Standard descriptions for common names (recommended starting point)

For the boilerplate names below, start from these wordings — it keeps docs identical across modules. If a method/property does something non-typical, refine the text for the concrete code. Domain fields and non-typical methods are always written from scratch from the source. The descriptions themselves are emitted **in Russian**.

### Controllers — methods

| Method | Description |
|---|---|
| `__construct` | Инициализирует зависимости контроллера. |
| `getFilters` | Проверяет доступ через `$this->authorize()` и возвращает данные для фильтров таблицы из сервиса. |
| `getEnums` | Проверяет доступ через `$this->authorize()` и возвращает енамы и константы, необходимые модулю. |
| `create` | Проверяет доступ через `$this->authorize()` и возвращает данные, необходимые для создания модели. |
| `edit` | Проверяет доступ через `$this->authorize()` и возвращает данные, необходимые для обновления модели. |
| `store` | Проверяет доступ через `$this->authorize()` и создаёт модель по переданным данным. |
| `update` | Проверяет доступ через `$this->authorize()` и обновляет модель по переданным данным. |
| `getDataTable` / `datatable` | Проверяет доступ через `$this->authorize()` и возвращает данные для таблицы. |
| `destroy` | Проверяет доступ через `$this->authorize()` и удаляет переданную модель. |

### Services — methods

| Method | Description |
|---|---|
| `__construct` | Инициализирует зависимости сервиса. |
| `getFilters` | Возвращает данные, необходимые для фильтров таблицы. |
| `getEnums` | Возвращает енамы и константы, необходимые модулю. |
| `create` | Возвращает данные, необходимые для создания. |
| `edit` | Возвращает данные, необходимые для редактирования. |
| `store` | Сохраняет модель по данным из DTO. |
| `update` | Обновляет модель по данным из DTO. |
| `getDataTable` / `datatable` | Возвращает подготовленные данные для таблицы: вызывает `query` для базового запроса и `applyFilters` для фильтрации по данным из DTO. |
| `destroy` | Удаляет модель. |

### Models — properties

| Property | Description |
|---|---|
| `$fillable` | Поля, разрешённые для массового заполнения. |
| `$hidden` | Скрытые поля, не попадающие в сериализацию. |
| `$table` | Имя таблицы модели. |
| `$casts` | Приведение полей к заданным типам. |

### Models — methods

| Method | Description |
|---|---|
| `checkRelations` | Проверяет наличие связанных записей; возвращает `false`, если их нет. |

### Requests — methods

В каноне реквест сводится к `## Правила валидации` (сырой массив `rules()`); `authorize` / `messages` / `attributes` отдельно обычно **не** документируются. Описания — на случай, если их всё же выносят:

| Method | Description |
|---|---|
| `rules` | Правила валидации. |
| `authorize` | Доступно ли действие данному запросу. |
| `messages` | Перевод сообщений об ошибках валидации. |
| `attributes` | Переводы названий атрибутов для ошибок валидации. |

### Resources — methods

| Method | Description |
|---|---|
| `toArray` | Формирует массив данных для отдачи на фронт. |

### Generic layers (`generic.md`) — methods

| Layer | Method | Description |
|---|---|---|
| Observers | `creating` | Вызывается при создании модели. |
| Observers | `updating` | Вызывается при обновлении модели. |
| Exports | `__construct` | Инициализирует и подготавливает данные для выгрузки в Excel. |
| Exports | `columnWidths` | Определяет ширину столбцов файла. |
| Exports | `headings` | Определяет названия столбцов. |
| Exports | `map` | Задаёт построчный вывод данных в Excel. |
| Exports | `array` | Возвращает массив данных для выгрузки в Excel. |
| Mail | `envelope` | Задаёт параметры генерации письма. |
| Mail | `content` | Определяет шаблон письма и передаваемые в него данные. |
| Providers | `register` | Регистрирует привязки в контейнере. |
| Providers | `boot` | Инициализация после регистрации всех провайдеров. |

### Common parameters

| Parameter | Description |
|---|---|
| `$request` | Реквест с данными запроса. |
| `$dto` | DTO с данными. |
| `$query` | Билдер запроса. |
| `$value` | Проверяемое значение (в правилах валидации). |
| `$data` | Данные для выгрузки в Excel. |
| `$service` | Сервис с бизнес-логикой. |
| `$repository` | Репозиторий для получения данных. |

## Framework / vendor base classes

These have **no** local doc — in the inheritance / traits / interfaces line write them as inline-code FQCN (never a laravel.com / package URL, never a guessed version). Project classes (`App\...`, e.g. `App\Http\Controllers\Controller`, a base service) are the opposite — a local `.md` link. The exact set of base classes/packages a project uses is defined in CLAUDE.md; the entries below are common Laravel/vendor examples.

- **Parents:** `Illuminate\Database\Eloquent\Model`, `Illuminate\Foundation\Auth\User`, `Spatie\LaravelData\Data` (only if the project uses a DTO layer — see CLAUDE.md), `Illuminate\Foundation\Http\FormRequest`, `Illuminate\Http\Resources\Json\JsonResource`, `Illuminate\Console\Command`, `Illuminate\Mail\Mailable`, `Illuminate\Support\ServiceProvider`
- **Traits:** `Illuminate\Database\Eloquent\SoftDeletes`, `Illuminate\Database\Eloquent\Factories\HasFactory`, `Spatie\MediaLibrary\InteractsWithMedia`, `Spatie\Permission\Traits\HasRoles`, `Maatwebsite\Excel\Concerns\Exportable`, `Illuminate\Foundation\Events\Dispatchable`, `Illuminate\Queue\InteractsWithQueue`, `Illuminate\Bus\Queueable`, `Illuminate\Queue\SerializesModels`
- **Interfaces:** `Illuminate\Contracts\Queue\ShouldQueue`, laravel-excel concerns (`FromArray`, `WithHeadings`, `WithMapping`, `WithColumnWidths`)
