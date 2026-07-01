---
name: i18n-translations
description: "Adding translations: frontend (Vue + vue-i18n) and backend (Laravel). Use whenever adding any static text to a page, a component, or an API response — every string is translated into all of the project's configured locales."
---

You add translations to the project. Always add the key for **every configured locale at once** (see CLAUDE.md for the project's locale list).

---

## Frontend — Vue.js + vue-i18n

### File structure

```
resources/js/lang/
├── <locale>.js                  ← aggregates all modules (import + export), one per locale
├── examples/examples_<locale>.js ← standard module structure, one file per locale
├── posts/posts_<locale>.js
├── ...
└── references/                  ← optional special module: an extra level
    ├── references_<locale>.js   ← aggregates <locale>/*.js
    ├── <locale>/
    │   ├── someReference.js
    │   ├── categories.js
    │   └── ...
    └── ...
```

Each existing module has one language file per configured locale in `lang/`. Check the aggregating `lang/<locale>.js` files for the current module list.

### How to add a key

**Step 1. Find the right language file of the module.**

- An entity page → `examples/examples_<locale>.js` for each locale
- A reference/lookup module → `references/<locale>/someReference.js` for each locale

**Step 2. Add the key for every configured locale.**

```js
// examples/examples_<locale-A>.js
export default {
  // ...existing keys...
  density: 'Density',
  density_price: 'Price per density',
}
```

```js
// examples/examples_<locale-B>.js
export default {
  // ...existing keys...
  density: 'Плотность',
  density_price: 'Цена за плотность',
}
```

Repeat for every remaining configured locale, keeping the same keys.

**Step 3. If you're creating a new module** — add the import to the aggregating files (one per locale):

```js
// resources/js/lang/<locale>.js
import myModule from '@/lang/my_module/my_module_<locale>.js';

export default {
  // ...existing...
  my_module: myModule,
}
// Same in every other <locale>.js
```

### Usage in a component

```vue
<script setup>
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
</script>

<template>
  <span>{{ t('references.someReference.density') }}</span>
  <v-btn>{{ t('examples.statuses.new') }}</v-btn>
</template>
```

The key is built from: `module.nested.key`. For references: `references.{fileName}.{key}`.

---

## Backend — Laravel

### File structure

```
lang/
├── <locale>/
│   ├── auth.php          ← authentication errors
│   ├── validation.php    ← validation messages
│   ├── enums.php         ← translations of enum values (statuses, types)
│   ├── message.php       ← arbitrary API messages
│   ├── notifications.php ← notification texts
│   ├── exports.php       ← export texts
│   └── roles.php         ← role names
├── ...                   ← one directory per configured locale
```

**File selection rule:**
- An enum value (status, type) → `enums.php`
- An arbitrary message in an API response / exception → `message.php`
- A notification text → `notifications.php`
- An authentication error → `auth.php`

### How to add a key

Add it for every configured locale at once:

```php
// lang/<locale-A>/message.php
return [
    // ...existing...
    'density_not_found' => 'Density rate not found',
];
```

```php
// lang/<locale-B>/message.php
return [
    // ...existing...
    'density_not_found' => 'Тариф плотности не найден',
];
```

Repeat for every remaining configured locale.

For enum values — a nested array:

```php
// lang/<locale>/enums.php
return [
    // ...existing...
    'cargo_density_types' => [
        'light'  => 'Light',
        'medium' => 'Medium',
        'heavy'  => 'Heavy',
    ],
];
```

### Usage in Laravel code

```php
// Simple message
return response()->json(['message' => __('message.density_not_found')], 404);

// With a parameter
__('message.additional_error', ['count' => $count])

// Enum value in a Resource
'type' => __('enums.cargo_density_types.' . $this->type->value)

// In an exception / service
throw new \Exception(__('message.density_not_found'));
```

The locale is set automatically via a `SetLocale` middleware from the `locale` cookie or the `Accept-Language` header (see CLAUDE.md).

---

## Checklist

- [ ] The key is added for every configured locale
- [ ] Frontend: the key in `{module}_<locale>.js` for each locale
- [ ] Backend: the key in `lang/<locale>/` for each locale
- [ ] In the component: `t('...')` instead of a hardcoded string
- [ ] In Laravel: `__('...')` instead of a hardcoded string
- [ ] A new module is registered in every `lang/<locale>.js`
