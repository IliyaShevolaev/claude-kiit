# Frontend CRUD flow — golden code examples

The canonical worked example of a frontend CRUD vertical slice. Concrete, project-specific companion to the project-agnostic `frontend-crud-flow-knowledge` skill: it shows those conventions applied with the real project base services, composables and global components.

<!-- ==========================================================================
TEMPLATE — `/claude-kit:setup` rewrites this with the project's real base CRUD
client, upload-form wrapper, global components (filters shell, data table,
dialog, icon buttons), composables and store getters discovered from the
codebase. Until then the examples below use NEUTRAL placeholder names
(`crudApi`, `uploadForm`, `top-filters`, `data-table`, `useTableHeaders`,
`store.getters['auth/can']`): replace them with what the project actually uses.
=========================================================================== -->

> **This is a template of the wiring, not an entity to copy.** Take the structure and project-specific utilities, not the `examples` fields.

Canonical flow: `useXxxApi -> IndexPage(filters + table) -> Form(upload-form wrapper) -> router module -> menu -> i18n -> permissions`.

---

## 1. API - factory + base CRUD client

All entity APIs are factory functions returning an anonymous class that extends the base CRUD client.

```javascript
import crudApi from '@/api/crudApi';
import axios from 'axios';

export default function useExampleApi() {
  return new (class extends crudApi {
    constructor() {
      super({ name: 'examples' });

      this.addUrls({
        customAction: (id) => `${this.name}/${id}/custom-action`,
      });
    }

    getDataTable(data) {
      return axios.post(this.url.getDataTable(), data);
    }

    customAction(id, data) {
      return axios.patch(this.url.customAction(id), data);
    }
  })();
}
```

Project specifics:
- The base client builds URLs from app config and provides `index`, `show`, `create`, `store`, `edit`, `update`, `delete`, `getFilters`, `getDataTable`.
- The custom-URL registrar (`addUrls()`) is the only place for custom endpoint URLs.
- Add a `getDataTable(data)` wrapper only when the page calls it directly.
- Reference CRUD (if the project has one) uses a separate client; do not mix it with the base one.

---

## 2. Index page

The default CRUD list is a filters shell + data table. The shell owns actions, search, filters, table settings, and the table slot.

```vue
<script setup>
import useExampleApi from '@/api/examples/useExampleApi.js';
import ExampleForm from '@/pages/components/examples/ExampleForm.vue';
import { useTableHeaders } from '@/composables/useTableHeaders';
import { ref, computed, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStore } from 'vuex';

const exampleApi = useExampleApi();
const { t, locale } = useI18n();
const store = useStore();
const can = store.getters['auth/can'];

const tableName = 'examples_index';
const tableRef = ref(null);
const search = ref('');
const filters = ref({ status: null });
const headerDisplaySettings = ref([]);

const defaultHeaders = computed(() => [
  { title: t('examples.table.name'), value: 'name', sortable: true, can: true, display: true },
  { title: t('actions'), value: 'actions', sortable: false, can: can('examples_update') || can('examples_destroy'), display: true },
]);

const { displayHeaders, updateHeaders } = useTableHeaders(defaultHeaders, headerDisplaySettings, locale);

const visibleDialog = ref(false);
const clickedId = ref(null);
const keyDialog = ref(1);

const showDialog = (id = null) => {
  clickedId.value = id;
  keyDialog.value++;
  visibleDialog.value = true;
};

const submitDialog = () => {
  visibleDialog.value = false;
  tableRef.value?.debounceGetData();
};

watch(() => locale.value, () => tableRef.value?.debounceGetData());
</script>

<template>
  <v-card>
    <v-container fluid>
      <top-filters v-model:filters="filters" v-model:search="search" :hidden-filters="true">
        <template #actions>
          <v-col cols="auto">
            <v-btn v-if="can('examples_create')" color="primary" rounded="lg" @click="showDialog()">
              {{ $t('examples.actions.add') }}
            </v-btn>
          </v-col>
        </template>

        <template #settings>
          <table-setting-button
            :table-name="tableName"
            :default-headers="defaultHeaders"
            @visibleHeaders="(headers) => updateHeaders(headers, () => tableRef?.debounceGetData())"
          />
        </template>

        <template #filters>
          <v-row>
            <v-col cols="12" md="3">
              <v-select v-model="filters.status" :items="statuses" clearable :label="$t('examples.filters.status')" />
            </v-col>
          </v-row>
        </template>

        <template #table>
          <data-table
            ref="tableRef"
            :url="exampleApi.url.getDataTable()"
            :headers="displayHeaders"
            :filters="filters"
            :search="search"
            :sort="{ key: 'id', order: 'asc' }"
            :table-name="tableName"
          >
            <template #item.actions="{ item }">
              <edit-icon-button v-if="can('examples_update')" @click="showDialog(item.id)" />
              <delete-icon-button
                v-if="can('examples_destroy')"
                :url="exampleApi.url.delete(item.id)"
                :message="$t('examples.actions.delete', { name: item.name })"
                @submit="tableRef.debounceGetData()"
              />
            </template>
          </data-table>
        </template>
      </top-filters>
    </v-container>

    <dialog-right-side v-model="visibleDialog" width="650">
      <template #content>
        <example-form
          :key="'example-form-' + keyDialog"
          :clicked-id="clickedId"
          @close="visibleDialog = false"
          @submit="submitDialog"
        />
      </template>
    </dialog-right-side>
  </v-card>
</template>
```

For a table **without filters**, omit `v-model:filters`, `:filters`, and the `#filters` slot. The data table defaults filters to `{}`.

---

## 3. Headers and table settings

Header object shape:

```javascript
{ title: t('examples.table.name'), value: 'name', sortable: true, can: true, display: true }
```

Rules:
- `can` controls whether a column is visible for the current user.
- `display` is the default user-visible state.
- `tableName` must be unique (`examples_index`) because column settings are stored by table name.
- Prefer the shared headers composable over hand-written clone/watch logic.
- Move headers into a repository only when they are reused or role-heavy.

---

## 4. Form - create/update via the upload-form wrapper

All create/update forms use the project's upload-form wrapper, not raw axios and not a plain form lib.

```vue
<script setup>
import Form from '@/plugins/uploadForm.js';
import useExampleApi from '@/api/examples/useExampleApi.js';
import useResponseHandler from '@/utils/uses/useResponseHandler.js';
import { reactive, ref, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useToast } from 'vue-toastification';

const exampleApi = useExampleApi();
const { t } = useI18n();
const toast = useToast();
const { errorHandler } = useResponseHandler();

const emit = defineEmits(['close', 'submit']);
const props = defineProps({
  clickedId: {
    type: [Number, null],
    default: null,
  },
});

const form = reactive(new Form({ name: null }));
const loading = ref(false);

const submit = async () => {
  loading.value = true;
  const request = props.clickedId
    ? form.put(exampleApi.url.update(props.clickedId))
    : form.post(exampleApi.url.store());

  await request
    .then(() => {
      toast.success(t('saved'));
      emit('submit');
    })
    .catch(errorHandler);

  loading.value = false;
};

onMounted(async () => {
  if (props.clickedId) {
    await exampleApi.edit(props.clickedId).then(({ data }) => form.fill(data.example)).catch(() => {});
  } else {
    await exampleApi.create().then(({ data }) => data).catch(() => {});
  }
});
</script>

<template>
  <v-form @submit.prevent="submit">
    <v-card min-height="90vh">
      <card-header :title="clickedId ? $t('examples.title.edit') : $t('examples.title.create')" @close="emit('close')" />
      <v-card-text>
        <v-text-field
          v-model="form.name"
          :label="$t('examples.fields.name')"
          :error-messages="form.errors.get('name')"
        />
      </v-card-text>
      <v-card-actions>
        <submit-button :loading="loading" />
        <cancel-button @click="emit('close')" />
      </v-card-actions>
    </v-card>
  </v-form>
</template>
```

Rules:
- `form.fill(data.entity)` for edit payloads.
- `form.errors.get('field')` for backend validation errors.
- `form.post(api.url.store())` for create.
- `form.put(api.url.update(id))` for update; the wrapper converts it to FormData with `_method`.
- For edit-time attachment uploads, use a separate `new Form({ attached_files: files }).put(api.url.attachFiles(id))`.

---

## 5. Full page form vs dialog form

Use **dialog CRUD** when the form is small and returns to the same table.

Use **page CRUD** when the form is large, multi-section, has files, preview/sidebar, or route-level detail pages:
- `examples.index`
- `examples.create`
- `examples.edit`
- optional `examples.detail`

The submit still uses the form wrapper; success usually does `router.push({ name: 'examples.index' })`.

---

## 6. Router, menu, permissions, i18n

Router module:

```javascript
import IndexPage from '@/pages/app/examples/IndexPage.vue';
import FormPage from '@/pages/app/examples/FormPage.vue';

export default [
  { path: 'examples', name: 'examples.index', component: IndexPage },
  { path: 'examples/create', name: 'examples.create', component: FormPage },
  { path: 'examples/:id/edit', name: 'examples.edit', component: FormPage, props: true },
];
```

Wire it into the router modules aggregator.

Menu item:

```javascript
{
  title: 'menu.examples',
  icon: 'mdi-format-list-bulleted',
  to: { name: 'examples.index' },
  visible: 'examples_read',
}
```

Permissions in UI:

```javascript
const can = store.getters['auth/can'];
can('examples_create');
can('examples_read');
can('examples_update');
can('examples_destroy');
```

i18n files:
- per-entity language modules `lang/examples/examples_{en,ru,zh}.js`
- imported into the root locale files
- add `menu.examples` in all root language files

Typical module keys:

```javascript
export default {
  index: 'Examples',
  title: { create: 'Create example', edit: 'Edit example' },
  fields: { name: 'Name' },
  table: { name: 'Name' },
  filters: { status: 'Status' },
  actions: { add: 'Add', delete: 'Delete "{name}"?' },
};
```

---

## Common pitfalls

```javascript
import Form from 'vform';
```

Use the project's upload-form wrapper instead.

```javascript
const filters = ref({ role_name: null });
filters.value.is_active;
```

Initialize every filter key used in the template.

```javascript
this.addUrls({
  updatePassword: () => `${this.name}/update-password`,
});
```

Every custom URL used by a component must exist in the custom-URL registrar.

```vue
<example-form :clicked-id="clickedId" />
```

Dialog forms need a changing `:key` to reset local form state between opens.

```vue
<data-table :table-name="'index'" />
```

Use a unique table name, e.g. `examples_index`.

## Checklist

- [ ] `useXxxApi()` extends the base CRUD client; custom URLs live in the registrar.
- [ ] `getDataTable(data)` wrapper exists if the page calls it directly.
- [ ] IndexPage uses the filters shell + data table for admin lists.
- [ ] No filters are wired when not needed; the table default `{}` is enough.
- [ ] Every used filter key is initialized.
- [ ] Headers use `title`, `value`, `sortable`, `can`, `display`.
- [ ] Table settings use a unique `tableName`.
- [ ] Create/update uses the upload-form wrapper.
- [ ] Validation errors use `form.errors.get('field')`.
- [ ] Success reloads the table or navigates back to index.
- [ ] UI permissions use the store's permission getter.
- [ ] Route module is imported into the router modules aggregator.
- [ ] Menu item uses translated `menu.*` and the read permission.
- [ ] All static text is translated in every supported locale.
