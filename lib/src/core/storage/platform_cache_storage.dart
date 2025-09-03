import 'dart:typed_data';
import '../../domain/entities/cache_entry.dart';
import '../../domain/entities/cache_stats.dart';

/// Platform-aware cache storage interface
abstract class PlatformCacheStorage {
  /// Initialize the storage system
  Future<void> initialize();

  /// Check if the current platform is supported
  bool get isSupported;

  /// Get platform-specific storage type
  String get storageType;

  /// Store data with metadata
  Future<void> store(String key, dynamic data, Map<String, dynamic> metadata);

  /// Store binary data
  Future<void> storeBytes(
      String key, Uint8List bytes, Map<String, dynamic> metadata);

  /// Retrieve data with metadata
  Future<CacheEntry?> retrieve(String key);

  /// Retrieve binary data
  Future<Uint8List?> retrieveBytes(String key);

  /// Check if key exists
  Future<bool> exists(String key);

  /// Remove entry
  Future<void> remove(String key);

  /// Clear all entries
  Future<void> clear();

  /// Get all keys
  Future<List<String>> getAllKeys();

  /// Get storage statistics
  Future<CacheStats> getStats();

  /// Cleanup expired entries
  Future<void> cleanup();

  /// Get total size
  Future<int> getTotalSize();

  /// Get entry count
  Future<int> getEntryCount();

  /// Dispose resources
  Future<void> dispose();
}
