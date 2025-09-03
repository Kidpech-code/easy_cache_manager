import '../entities/cache_stats.dart';
import '../repositories/cache_repository.dart';
import '../../core/error/failures.dart';

/// Use case for cache management operations
class CacheManagementUseCase {
  final CacheRepository cacheRepository;

  CacheManagementUseCase({required this.cacheRepository});

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      await cacheRepository.clear();
    } catch (e) {
      throw StorageFailure(
          message: 'Failed to clear cache: $e', originalError: e);
    }
  }

  /// Remove specific cached item
  Future<void> removeItem(String key) async {
    try {
      await cacheRepository.remove(key);
    } catch (e) {
      throw StorageFailure(
          message: 'Failed to remove cache item: $e', originalError: e);
    }
  }

  /// Get cache statistics
  Future<CacheStats> getStats() async {
    try {
      return await cacheRepository.getStats();
    } catch (e) {
      throw StorageFailure(
          message: 'Failed to get cache stats: $e', originalError: e);
    }
  }

  /// Clean up expired cache entries
  Future<void> cleanup() async {
    try {
      await cacheRepository.cleanup();
    } catch (e) {
      throw StorageFailure(
          message: 'Failed to cleanup cache: $e', originalError: e);
    }
  }

  /// Check if cache contains specific key
  Future<bool> contains(String key) async {
    try {
      return await cacheRepository.exists(key);
    } catch (e) {
      return false;
    }
  }

  /// Get all cache keys
  Future<List<String>> getAllKeys() async {
    try {
      return await cacheRepository.getAllKeys();
    } catch (e) {
      throw StorageFailure(
          message: 'Failed to get cache keys: $e', originalError: e);
    }
  }

  /// Get total cache size in bytes
  Future<int> getTotalSize() async {
    try {
      return await cacheRepository.getTotalSize();
    } catch (e) {
      throw StorageFailure(
          message: 'Failed to get cache size: $e', originalError: e);
    }
  }
}
