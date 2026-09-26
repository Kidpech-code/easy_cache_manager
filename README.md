# Easy Cache Manager

Flutter caching backed by Hive CE. The package provides HTTP response caching with an offline fallback, plus a separate key-value storage API. It supports Android, iOS, desktop, web, and browser WASM.

**Current package version:** 0.2.1 · **Minimum:** Dart 3.4, Flutter 3.27

## Install

```yaml
dependencies:
  easy_cache_manager: ^0.2.1
```

The 0.2.1 release changes cache keys and expiration behavior. Read [MIGRATION.md](MIGRATION.md) before upgrading from 0.2.0 or earlier.

## Cache HTTP responses

```dart
import 'package:easy_cache_manager/easy_cache_manager.dart';

final cache = CacheManager(
  config: const AdvancedCacheConfig(
    maxAge: Duration(minutes: 15),
    stalePeriod: Duration(days: 1),
  ),
);

final product = await cache.getJson(
  'https://api.example.com/products/42',
);
final image = await cache.getBytes(
  'https://example.com/products/42.png',
);

cache.dispose();
```

`getJson` returns a JSON object; `getBytes` returns binary data. An error is thrown if the request fails and no usable cached response exists. Pass `forceRefresh: true` to request fresh data even while a cached response is still fresh.

### Fresh and stale periods

- `maxAge` is how long an HTTP response is fresh. A per-call `maxAge` overrides the config value.
- After `maxAge`, an online request fetches a new response. When offline or when that request fails, the old response can be used for one additional `stalePeriod`.
- After `maxAge + stalePeriod`, the response is removed. `stalePeriod: Duration.zero` disables stale fallback.
- Older entries written without an expiration are checked against these same limits when read.

The HTTP API uses a best-effort connectivity check. Applications should still handle request errors and decide whether stale data is appropriate for each screen.

### Request headers and accounts

```dart
final product = await cache.getJson(
  'https://api.example.com/products/42',
  headers: {'Accept-Language': 'th'},
);
```

All request headers affect the cache key. Header names are case-insensitive and header values are hashed, so two users requesting the same URL with different `Authorization` values do not share an entry. New HTTP cache entries do not save request headers as metadata.

**Cached response bodies are not encrypted by default.** Do not use this cache as a secure store for secrets. Clear cache data on sign-out or account switches, and review the app's local data protection requirements before caching private responses. URLs without request headers still appear in legacy-compatible cache keys; avoid putting secrets in URL query strings.

## Store simple key-value data

Use `SimpleCacheStorage` for arbitrary keys. This API is separate from HTTP response caching and does not provide per-key expiration.

```dart
import 'package:easy_cache_manager/easy_cache_manager.dart';

final storage = SimpleCacheStorage();
await storage.init();
await storage.setJson('draft', {'title': 'Example'});
final draft = await storage.getJson('draft');
await storage.remove('draft');
await storage.close();
```

For manual `CacheManager.save(key, value, maxAge: ...)` calls, `maxAge` is a hard expiration. A save without `maxAge` does not expire. The `CacheManager` read methods are for URLs; use `SimpleCacheStorage` when you need a matching key-value read API.

## Development

```sh
flutter pub get
flutter analyze --fatal-infos
flutter test
flutter test --platform chrome test/web_storage_test.dart
flutter test --platform chrome --wasm test/web_storage_test.dart
(cd example && flutter build web --release)
(cd example && flutter build web --wasm --release)
dart pub publish --dry-run
```

The package's CI runs these checks. See [CHANGELOG.md](CHANGELOG.md) for changes and [MIGRATION.md](MIGRATION.md) for upgrade notes. Bugs and compatibility reports are welcome in the [issue tracker](https://github.com/Kidpech-code/easy_cache_manager/issues).

Licensed under [MIT](LICENSE).
