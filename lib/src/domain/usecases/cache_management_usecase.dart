import 'dart:typed_data';

import 'package:easy_cache_manager/easy_cache_manager.dart';
import 'package:easy_cache_manager/src/domain/repositories/cache_repository.dart';

/// Use case for cache management operations
class CacheManagementUseCase {
  final CacheRepository cacheRepository;

  CacheManagementUseCase({required this.cacheRepository});

  /// Save JSON data to cache
  Future<void> saveJson(String key, Map<String, dynamic> value,
      {Duration? maxAge}) async {
    try {
      await cacheRepository.store(key, value,
          maxAge: maxAge, contentType: 'application/json');
    } catch (e) {
      throw StorageFailure(
          message: 'Failed to save JSON: $e', originalError: e);
    }
  }

  /// Save binary data to cache
  Future<void> saveBytes(String key, Uint8List value,
      {Duration? maxAge}) async {
    try {
      await cacheRepository.storeBytes(key, value,
          maxAge: maxAge, contentType: 'application/octet-stream');
    } catch (e) {
      throw StorageFailure(
          message: 'Failed to save bytes: $e', originalError: e);
    }
  }

  /// Save string data to cache
  Future<void> saveString(String key, String value, {Duration? maxAge}) async {
    try {
      await cacheRepository.store(key, value,
          maxAge: maxAge, contentType: 'text/plain');
    } catch (e) {
      throw StorageFailure(
          message: 'Failed to save string: $e', originalError: e);
    }
  }

  /// Save int data to cache
  Future<void> saveInt(String key, int value, {Duration? maxAge}) async {
    try {
      await cacheRepository.store(key, value,
          maxAge: maxAge, contentType: 'application/x-int');
    } catch (e) {
      throw StorageFailure(message: 'Failed to save int: $e', originalError: e);
    }
  }

  /// Save double data to cache
  Future<void> saveDouble(String key, double value, {Duration? maxAge}) async {
    try {
      await cacheRepository.store(key, value,
          maxAge: maxAge, contentType: 'application/x-double');
    } catch (e) {
      throw StorageFailure(
          message: 'Failed to save double: $e', originalError: e);
    }
  }

  /// Save bool data to cache
  Future<void> saveBool(String key, bool value, {Duration? maxAge}) async {
    try {
      await cacheRepository.store(key, value,
          maxAge: maxAge, contentType: 'application/x-bool');
    } catch (e) {
      throw StorageFailure(
          message: 'Failed to save bool: $e', originalError: e);
    }
  }

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
