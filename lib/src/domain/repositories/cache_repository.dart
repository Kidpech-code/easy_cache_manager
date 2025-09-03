import 'dart:typed_data';
import '../entities/cache_entry.dart';
import '../entities/cache_stats.dart';

/// Repository interface for cache operations
abstract class CacheRepository {
  /// Store data in cache
  Future<void> store(
    String key,
    dynamic data, {
    Duration? maxAge,
    Map<String, String>? headers,
    String? etag,
    int? statusCode,
    String contentType = 'application/json',
  });

  /// Store binary data (images, files) in cache
  Future<void> storeBytes(
    String key,
    Uint8List bytes, {
    Duration? maxAge,
    Map<String, String>? headers,
    String? etag,
    int? statusCode,
    String contentType = 'application/octet-stream',
  });

  /// Retrieve data from cache
  Future<CacheEntry?> retrieve(String key);

  /// Retrieve bytes from cache
  Future<Uint8List?> retrieveBytes(String key);

  /// Check if key exists in cache
  Future<bool> exists(String key);

  /// Check if cached data is still valid
  Future<bool> isValid(String key);

  /// Remove specific entry from cache
  Future<void> remove(String key);

  /// Clear all cached data
  Future<void> clear();

  /// Get all cache keys
  Future<List<String>> getAllKeys();

  /// Get cache statistics
  Future<CacheStats> getStats();

  /// Clean up expired entries
  Future<void> cleanup();

  /// Get total cache size in bytes
  Future<int> getTotalSize();

  /// Get cache entry count
  Future<int> getEntryCount();
}
