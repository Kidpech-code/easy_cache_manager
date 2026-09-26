# Migrating to 0.2.1

## HTTP cache keys and privacy

`getJson` and `getBytes` now hash the URL and request headers into separate
cache keys for requests that include headers. Header names are normalized to
lowercase. The first request with headers after upgrading will fetch again.
Legacy URL-only entries that contain request headers are removed when their
URL is requested. `CacheUtils.generateCacheKey` also hashes header values, so
applications using it directly will see a cache miss for keyed requests.

The package does not encrypt cached response bodies. Clear the cache on
sign-out or account changes. If an older release cached private responses
without explicit request headers (for example, via browser cookies), clear
those entries on upgrade because the package cannot identify the user from
the stored entry. Avoid secrets in URL query strings.

## Expiration

For HTTP responses, `maxAge` is the fresh period and `stalePeriod` is the
additional retention period for offline or error fallback. An entry is no
longer returned after `maxAge + stalePeriod`. Existing HTTP entries without an
expiration are subject to the same age limit when read.

For manual `CacheManager.save(..., maxAge: ...)` calls, `maxAge` is now stored
as a hard expiration. Earlier releases ignored this value, so existing manual
entries cannot recover their intended expiration; remove or clear them if
that matters to your application. A manual save without `maxAge` remains
non-expiring.

`CacheManager` now waits for storage initialization before fulfilling cache
operations. A storage initialization failure is reported rather than silently
reporting a successful save.

---

# Migrating to 0.2.0

## Storage compatibility

The storage backend now uses `hive_ce: ^2.20.0` and `hive_ce_flutter: ^2.3.4`.
Hive 2.2.3 could compile for WASM but its browser backend threw UnimplementedError
when opening a box. Hive CE provides the browser persistence backend.

The high-level cache API, box names, adapter type IDs and field IDs are unchanged.
If your app imports Hive types or registers adapters used by this package,
replace `package:hive/hive.dart` with `package:hive_ce/hive.dart` and
`package:hive_flutter/hive_flutter.dart` with
`package:hive_ce_flutter/hive_flutter.dart`. The two engines have separate Dart
registries; do not open the same box concurrently through both.

Back up application data before upgrading. Keep the original storage path.
Regression tests read synthetic Hive 2.2.3 cache-entry and statistics records
with Hive CE. Custom adapters and application-specific datasets need their own
migration checks. No application data is migrated or deleted by this patch.

Minimum declared SDK: Dart 3.4 / Flutter 3.27. The example requires Flutter 3.35
for its form API. Validation uses Flutter 3.44.2 / Dart 3.12.2.

## Platform selection

Native DNS and filesystem code is selected only with `dart.library.io`.
JavaScript and WASM select the existing HTTP network implementation and browser
storage adapters. Browser HTTP probes remain subject to CORS and network policy;
WASM support does not imply that every remote endpoint permits browser requests.

JSON writes no longer reinitialize the global Hive directory after storage has
already been initialized. This preserves the application's selected storage path.

## Development

Unused mockito, test and JSON-generator dev dependencies were removed; use
`flutter_test` and `hive_ce_generator`. The missing test-only mock was replaced by
real storage in temporary directories, with only HTTP/path-provider boundaries
substituted. Example dependencies/assets now match the checked-in example.

```sh
flutter pub get
flutter analyze --fatal-infos
flutter test
flutter test --platform chrome test/web_storage_test.dart
flutter test --platform chrome --wasm test/web_storage_test.dart
(cd example && flutter build web --release)
(cd example && flutter build web --wasm --release)
flutter pub publish --dry-run
```

---
