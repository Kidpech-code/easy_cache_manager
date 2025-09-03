import 'dart:typed_data';
import '../../domain/entities/cache_entry.dart';
import '../../domain/entities/cache_stats.dart';
import '../../domain/repositories/cache_repository.dart';
import '../../core/storage/hive_cache_storage.dart';
import '../../core/error/exceptions.dart';

/// High-performance cache repository implementation using Hive NoSQL
class CacheRepositoryImpl implements CacheRepository {
  final HiveCacheStorage hiveCacheStorage;

  CacheRepositoryImpl({required this.hiveCacheStorage});

  @override
  Future<void> store(
    String key,
    dynamic data, {
    Duration? maxAge,
    Map<String, String>? headers,
    String? etag,
    int? statusCode,
    String contentType = 'application/json',
  }) async {
    try {
      await hiveCacheStorage.store(
        key,
        data,
        {
          'maxAge': maxAge?.inMilliseconds,
          'headers': headers,
          'etag': etag,
          'statusCode': statusCode,
          'contentType': contentType,
        },
      );
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
          message: 'Failed to store cache entry: $e', originalError: e);
    }
  }

  @override
  Future<void> storeBytes(
    String key,
    Uint8List bytes, {
    Duration? maxAge,
    Map<String, String>? headers,
    String? etag,
    int? statusCode,
    String contentType = 'application/octet-stream',
  }) async {
    try {
      await hiveCacheStorage.storeBytes(key, bytes, {
        'maxAge': maxAge?.inMilliseconds,
        'headers': headers,
        'etag': etag,
        'statusCode': statusCode,
        'contentType': contentType,
      });
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
          message: 'Failed to store binary cache entry: $e', originalError: e);
    }
  }

  @override
  Future<CacheEntry?> retrieve(String key) async {
    try {
      return await hiveCacheStorage.retrieve(key);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
          message: 'Failed to retrieve cache entry: $e', originalError: e);
    }
  }

  @override
  Future<Uint8List?> retrieveBytes(String key) async {
    try {
      return await hiveCacheStorage.retrieveBytes(key);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
          message: 'Failed to retrieve binary cache entry: $e',
          originalError: e);
    }
  }

  @override
  Future<bool> exists(String key) async {
    try {
      return await hiveCacheStorage.exists(key);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> isValid(String key) async {
    try {
      final entry = await retrieve(key);
      return entry?.isValid ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      await hiveCacheStorage.remove(key);
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
          message: 'Failed to remove cache entry: $e', originalError: e);
    }
  }

  @override
  Future<void> clear() async {
    try {
      await hiveCacheStorage.clear();
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
          message: 'Failed to clear cache: $e', originalError: e);
    }
  }

  @override
  Future<List<String>> getAllKeys() async {
    try {
      return await hiveCacheStorage.getAllKeys();
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
          message: 'Failed to get cache keys: $e', originalError: e);
    }
  }

  @override
  Future<CacheStats> getStats() async {
    try {
      return await hiveCacheStorage.getStats();
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
          message: 'Failed to get cache stats: $e', originalError: e);
    }
  }

  @override
  Future<void> cleanup() async {
    try {
      await hiveCacheStorage.cleanup();
    } catch (e) {
      if (e is StorageException) rethrow;
      throw StorageException(
          message: 'Failed to cleanup cache: $e', originalError: e);
    }
  }

  @override
  Future<int> getTotalSize() async {
    try {
      return await hiveCacheStorage.getTotalSize();
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<int> getEntryCount() async {
    try {
      return await hiveCacheStorage.getEntryCount();
    } catch (e) {
      return 0;
    }
  }
}
