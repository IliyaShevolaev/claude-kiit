---
name: phpunit-complex-testing
description: "Advanced PHPUnit/Laravel testing playbook for complex cases: service mocks/stubs, fake storage, external API fakes, and stable boundary-focused tests. Use when writing or reviewing non-trivial backend tests."
---

# PHPUnit Complex Testing

Use this skill when tests involve external boundaries, side effects, or layered services.

## Stack assumptions

- PHPUnit 11+ semantics (`createStub()` vs `createMock()`)
- Laravel TestCase helpers (`mock`, `partialMock`, `spy`)
- Laravel fakes for boundaries (`Http::fake`, `Storage::fake`, `Queue::fake`, `Event::fake`, `Notification::fake`)

## Core rules

1. Mock boundaries, not internals.
2. Prefer `createStub()` for return-value control.
3. Use `createMock()` only when interaction assertions matter.
4. Keep one behavior per test.
5. Do not over-mock domain/value objects.
6. Keep tests deterministic: no real network, no real cloud storage.
7. Do not run tests yourself if the project forbids it (see CLAUDE.md); ask the user to run them.

## Quick decision matrix

- Need only a dependency return value -> `createStub()` or Laravel `mock()` with `andReturn`.
- Need to assert method call count/arguments -> `createMock()` or Laravel `mock()` expectations.
- Need to record calls after execution -> Laravel `spy()`.
- Need filesystem isolation -> `Storage::fake('disk')`.
- Need external API isolation -> `Http::preventStrayRequests()` + `Http::fake([...])`.
- Need asynchronous side-effect checks -> `Queue::fake()`, `Event::fake()`, `Notification::fake()`.

## Patterns

### 1) Service dependency in unit test (stub-first)

```php
$rateProvider = $this->createStub(RateProvider::class);
$rateProvider->method('getRate')->willReturn(1.23);

$service = new PriceService($rateProvider);
$result = $service->calculate(100);

$this->assertSame(123.0, $result);
```

Use this when collaboration details are irrelevant.

### 2) Interaction-sensitive dependency (mock)

```php
$bus = $this->createMock(EventBus::class);
$bus->expects($this->once())
    ->method('dispatch')
    ->with($this->callback(fn (EntityCreated $e) => $e->entityId === $entityId));

$service = new EntityService($bus);
$service->create($dto);
```

Use this when behavior is the assertion target.

### 3) Laravel container mock/partialMock/spy

```php
$this->mock(ExternalSyncService::class, function ($mock) {
    $mock->shouldReceive('sync')->once()->andReturnTrue();
});

$this->partialMock(FeeCalculator::class, function ($mock) {
    $mock->shouldReceive('resolveRate')->andReturn(2.5);
});

$spy = $this->spy(ActivityLogger::class);
```

### 4) External API fake with strict boundary guard

```php
use Illuminate\Support\Facades\Http;

Http::preventStrayRequests();

Http::fake([
    'https://api.partner.com/*' => Http::response([
        'ok' => true,
        'items' => [['id' => 10]],
    ], 200),
]);

$response = $this->postJson('/api/examples/sync');
$response->assertOk();

Http::assertSent(fn ($request) =>
    str_contains($request->url(), 'api.partner.com') &&
    $request->method() === 'POST'
);
```

Always fake success and failure variants (4xx, 5xx, timeout-like behavior).

### 5) File upload/storage with fake disk

```php
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

Storage::fake('examples');

$file = UploadedFile::fake()->image('invoice.jpg', 1200, 800)->size(300);

$response = $this->postJson('/api/examples/1/invoice', [
    'invoice' => $file,
]);

$response->assertOk();
Storage::disk('examples')->assertExists($file->hashName());
```

If the application renames files, assert the actual stored path/name, not the original filename.

## Anti-patterns

- Mocking repositories/entities inside domain logic tests when in-memory fake or real object is enough.
- Asserting many unrelated behaviors in one test.
- Relying on real external APIs in regular CI test suite.
- Missing `Http::preventStrayRequests()` while using `Http::fake()`.
- Testing implementation details instead of observable outcomes/contracts.

## Recommended suite split

- `tests/Feature/*`: main contract and behavior tests with faked boundaries.
- `tests/Unit/*`: isolated logic with stubs/mocks.
- `tests/External/*`: optional live API contract tests, excluded from default run.

## Test author checklist

- [ ] One scenario per test.
- [ ] Boundary dependencies isolated/faked.
- [ ] Correct choice: stub vs mock vs spy.
- [ ] Assertions check outcome and required side effects.
- [ ] Failure-path case exists for external API/filesystem interaction.
- [ ] No hidden real network/storage usage.

