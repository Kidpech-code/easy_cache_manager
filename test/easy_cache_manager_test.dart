import 'package:flutter_test/flutter_test.dart';
import 'package:easy_cache_manager/easy_cache_manager.dart';

void main() {
  group('Easy Cache Manager Tests', () {
    late CacheManager cacheManager;

    setUp(() {
      cacheManager = CacheManager(
        config: const CacheConfig(
          maxCacheSize: 10 * 1024 * 1024, // 10MB for testing
          stalePeriod: Duration(minutes: 30),
          enableLogging: true,
        ),
      );
    });

    tearDown(() {
      cacheManager.dispose();
    });

    test('Cache manager initialization', () {
      expect(cacheManager, isNotNull);
      expect(cacheManager.config.maxCacheSize, equals(10 * 1024 * 1024));
      expect(
          cacheManager.config.stalePeriod, equals(const Duration(minutes: 30)));
    });

    test('Cache config creation', () {
      const config = CacheConfig(
          maxCacheSize: 50 * 1024 * 1024,
          stalePeriod: Duration(hours: 2),
          enableOfflineMode: true,
          autoCleanup: false);

      expect(config.maxCacheSize, equals(50 * 1024 * 1024));
      expect(config.stalePeriod, equals(const Duration(hours: 2)));
      expect(config.enableOfflineMode, isTrue);
      expect(config.autoCleanup, isFalse);
    });

    test('Cache config with defaults', () {
      const config = CacheConfig();

      expect(config.maxCacheSize, equals(100 * 1024 * 1024));
      expect(config.stalePeriod, equals(const Duration(days: 7)));
      expect(config.enableOfflineMode, isTrue);
      expect(config.autoCleanup, isTrue);
      expect(config.cleanupThreshold, equals(0.8));
      expect(config.cacheName, equals('easy_cache'));
    });

    test('Cache config copyWith', () {
      const original = CacheConfig();
      final modified = original.copyWith(
          maxCacheSize: 200 * 1024 * 1024, enableOfflineMode: false);

      expect(modified.maxCacheSize, equals(200 * 1024 * 1024));
      expect(modified.enableOfflineMode, isFalse);
      // Other values should remain the same
      expect(modified.stalePeriod, equals(original.stalePeriod));
      expect(modified.autoCleanup, equals(original.autoCleanup));
    });

    test('Cache entry creation', () {
      final entry = CacheEntry(
        key: 'test_key',
        data: {'name': 'John', 'age': 30},
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        sizeInBytes: 100,
      );

      expect(entry.key, equals('test_key'));
      expect(entry.data, isA<Map<String, dynamic>>());
      expect(entry.isValid, isTrue);
      expect(entry.sizeInBytes, equals(100));
    });

    test('Cache entry validity check', () {
      final validEntry = CacheEntry(
        key: 'valid_key',
        data: 'test data',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        sizeInBytes: 9,
      );

      final expiredEntry = CacheEntry(
        key: 'expired_key',
        data: 'test data',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        sizeInBytes: 9,
      );

      final neverExpiresEntry = CacheEntry(
          key: 'never_expires_key',
          data: 'test data',
          createdAt: DateTime.now(),
          expiresAt: null,
          sizeInBytes: 9);

      expect(validEntry.isValid, isTrue);
      expect(expiredEntry.isValid, isFalse);
      expect(neverExpiresEntry.isValid, isTrue);
    });

    test('Cache stats creation', () {
      final stats = CacheStats(
        totalEntries: 10,
        totalSizeInBytes: 1024,
        hitCount: 8,
        missCount: 2,
        evictionCount: 1,
        hitRate: 0.8,
        lastCleanup: DateTime.now(),
        averageLoadTime: const Duration(milliseconds: 150),
      );

      expect(stats.totalEntries, equals(10));
      expect(stats.totalSizeInMB, equals(1024 / (1024 * 1024)));
      expect(stats.hitRate, equals(0.8));
      expect(stats.missRate,
          closeTo(0.2, 0.01)); // Use closeTo for floating point comparison
      expect(stats.totalRequests, equals(10));
    });

    test('Cache status creation', () {
      final loadingStatus = CacheStatusInfo.loading(key: 'test_key');
      final cachedStatus = CacheStatusInfo.cached(
          key: 'test_key',
          loadTime: const Duration(milliseconds: 100),
          sizeInBytes: 500);
      final errorStatus =
          CacheStatusInfo.error(message: 'Network error', key: 'test_key');

      expect(loadingStatus.status, equals(CacheStatus.loading));
      expect(loadingStatus.key, equals('test_key'));

      expect(cachedStatus.status, equals(CacheStatus.cached));
      expect(cachedStatus.isFromCache, isTrue);
      expect(cachedStatus.sizeInBytes, equals(500));

      expect(errorStatus.status, equals(CacheStatus.error));
      expect(errorStatus.message, equals('Network error'));
    });

    test('Cache utils key generation', () {
      final key1 =
          CacheUtils.generateCacheKey('https://api.example.com/users/1');
      final key2 = CacheUtils.generateCacheKey(
        'https://api.example.com/users/1',
        headers: {
          'authorization': 'Bearer token'
        }, // Use lowercase header that is tracked
      );
      final key3 = CacheUtils.generateCacheKey('https://api.example.com/users',
          queryParams: {'page': '1', 'limit': '10'});

      expect(key1, isA<String>());
      expect(key1.isNotEmpty, isTrue);
      expect(key2, isNot(equals(key1))); // Should be different with headers
      expect(
          key3, isNot(equals(key1))); // Should be different with query params
    });

    test('Cache utils data size calculation', () {
      expect(CacheUtils.calculateDataSize('hello'), equals(5));
      expect(CacheUtils.calculateDataSize({'key': 'value'}), greaterThan(0));
      expect(CacheUtils.calculateDataSize([1, 2, 3]), greaterThan(0));
      expect(CacheUtils.calculateDataSize(null), equals(0));
    });

    test('Cache utils byte formatting', () {
      expect(CacheUtils.formatBytes(512), equals('512 B'));
      expect(CacheUtils.formatBytes(1024), equals('1.00 KB'));
      expect(CacheUtils.formatBytes(1024 * 1024), equals('1.00 MB'));
      expect(CacheUtils.formatBytes(1024 * 1024 * 1024), equals('1.00 GB'));
    });

    test('Cache utils MIME type inference', () {
      expect(CacheUtils.inferMimeType('image.jpg'), equals('image/jpeg'));
      expect(
          CacheUtils.inferMimeType('document.pdf'), equals('application/pdf'));
      expect(CacheUtils.inferMimeType('data.json'), equals('application/json'));
      expect(CacheUtils.inferMimeType('unknown.xyz'),
          equals('application/octet-stream'));
    });

    test('Cache utils URL validation', () {
      expect(CacheUtils.isValidUrl('https://example.com'), isTrue);
      expect(CacheUtils.isValidUrl('http://example.com'), isTrue);
      expect(CacheUtils.isValidUrl('ftp://example.com'), isFalse);
      expect(CacheUtils.isValidUrl('not-a-url'), isFalse);
    });

    test('Network failure types', () {
      final networkFailure = NetworkFailure.noConnection();
      final timeoutFailure = NetworkFailure.timeout();
      final serverFailure = NetworkFailure.serverError(500);

      expect(networkFailure.message, contains('No internet connection'));
      expect(networkFailure.errorCode, equals(1001));

      expect(timeoutFailure.message, contains('timeout'));
      expect(timeoutFailure.errorCode, equals(1002));

      expect(serverFailure.errorCode, equals(500));
      expect(serverFailure.message, contains('Server error: 500'));
    });

    test('Storage failure types', () {
      final diskFullFailure = StorageFailure.diskFull();
      final accessDeniedFailure = StorageFailure.accessDenied();
      final corruptionFailure = StorageFailure.corruption();

      expect(diskFullFailure.errorCode, equals(2001));
      expect(accessDeniedFailure.errorCode, equals(2002));
      expect(corruptionFailure.errorCode, equals(2003));
    });
  });

  group('Integration Tests', () {
    test('Cache manager streams', () async {
      final cacheManager =
          CacheManager(config: const CacheConfig(enableLogging: true));

      // Test status stream
      expect(cacheManager.statusStream, isA<Stream<CacheStatusInfo>>());
      expect(cacheManager.statsStream, isA<Stream<CacheStats>>());

      // Initial status should be available
      expect(cacheManager.currentStatus, isA<CacheStatusInfo>());
      expect(cacheManager.currentStats, isA<CacheStats>());

      cacheManager.dispose();
    });

    test('Cache operations', () async {
      final cacheManager =
          CacheManager(config: const CacheConfig(enableLogging: true));

      // Test basic operations
      expect(await cacheManager.contains('nonexistent'), isFalse);
      expect(await cacheManager.getAllKeys(), isEmpty);

      // Test stats
      final stats = await cacheManager.getStats();
      expect(stats, isA<CacheStats>());

      cacheManager.dispose();
    });
  });
}
