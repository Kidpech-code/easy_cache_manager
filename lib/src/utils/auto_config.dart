/// Easy Cache Manager v1.2.0 - Hive-backed storage
///
/// Notes:
/// - Often faster than SQL-based approaches depending on workload
/// - Memory footprint can be smaller for common read-heavy patterns
/// - Cross-platform (Web/Mobile/Desktop)
/// - See README for benchmark methodology and limitations

library easy_cache_auto_config;

import '../presentation/cache_manager.dart';
import '../domain/entities/cache_config.dart';
import '../core/storage/simple_cache_storage.dart';
import 'dart:typed_data';
import '../core/storage/hive_cache_storage.dart';
import '../data/datasources/network_remote_data_source.dart';
import '../core/network/network_info.dart';

/// 🚀 EasyCacheManager - Smart Auto-Configuration
///
/// Automatically detects your app needs and chooses the best configuration
class EasyCacheManager {
  /// Auto-detect and configure cache based on your app
  static CacheManager auto({
    int? expectedUsers,
    List<String>? dataTypes,
    String? platform,
    String? importance,
  }) {
    return CacheManager(
      config: _autoDetectConfig(
        expectedUsers: expectedUsers,
        dataTypes: dataTypes,
        platform: platform,
        importance: importance,
      ),
    );
  }

  /// Smart configuration with AI-powered recommendations
  static CacheManager smart({
    required int expectedUsers,
    required List<String> dataTypes,
    required String platform,
    required String importance,
  }) {
    return CacheManager(
      config: _smartConfig(
        expectedUsers: expectedUsers,
        dataTypes: dataTypes,
        platform: platform,
        importance: importance,
      ),
    );
  }

  /// Pre-built template configurations
  static CacheManager template(AppType type) {
    switch (type) {
      case AppType.ecommerce:
        return _ecommerceTemplate();
      case AppType.social:
        return _socialTemplate();
      case AppType.news:
        return _newsTemplate();
      case AppType.game:
        return _gameTemplate();
      case AppType.productivity:
        return _productivityTemplate();
      default:
        return auto();
    }
  }

  static CacheConfig _autoDetectConfig({
    int? expectedUsers,
    List<String>? dataTypes,
    String? platform,
    String? importance,
  }) {
    // Simple auto-detection logic
    final hasImages = dataTypes?.contains('images') ?? false;
    final hasVideos = dataTypes?.contains('videos') ?? false;
    final isHighTraffic = (expectedUsers ?? 100) > 1000;

    int maxSize;
    if (hasVideos) {
      maxSize = 1024 * 1024 * 1024; // 1GB for videos
    } else if (hasImages) {
      maxSize = 500 * 1024 * 1024; // 500MB for images
    } else {
      maxSize = 100 * 1024 * 1024; // 100MB for data
    }

    return CacheConfig(
      maxCacheSize: maxSize,
      stalePeriod: isHighTraffic
          ? const Duration(minutes: 15)
          : const Duration(hours: 1),
      enableOfflineMode: true,
      autoCleanup: true,
      cleanupThreshold: 0.8,
      enableLogging: importance == 'high',
    );
  }

  static CacheConfig _smartConfig({
    required int expectedUsers,
    required List<String> dataTypes,
    required String platform,
    required String importance,
  }) {
    // More sophisticated logic based on all parameters

    int maxSize = 100 * 1024 * 1024; // Base 100MB

    // Adjust based on data types
    if (dataTypes.contains('videos')) {
      maxSize *= 10; // 1GB
    } else if (dataTypes.contains('images')) {
      maxSize *= 5; // 500MB
    } else if (dataTypes.contains('files')) {
      maxSize *= 3; // 300MB
    }

    // Adjust based on users
    if (expectedUsers > 10000) {
      maxSize = (maxSize * 1.5).round();
    } else if (expectedUsers > 1000) {
      maxSize = (maxSize * 1.2).round();
    }

    return CacheConfig(
      maxCacheSize: maxSize,
      stalePeriod: expectedUsers > 1000
          ? const Duration(minutes: 10)
          : const Duration(hours: 2),
      enableOfflineMode: true,
      autoCleanup: true,
      cleanupThreshold: platform == 'mobile' ? 0.8 : 0.9,
      enableLogging: importance == 'high',
    );
  }

  static CacheManager _ecommerceTemplate() {
    return CacheManager(
      config: const CacheConfig(
        maxCacheSize: 500 * 1024 * 1024, // 500MB
        stalePeriod: Duration(hours: 12),
        maxAge: Duration(days: 7),
        enableOfflineMode: true,
        autoCleanup: true,
        cleanupThreshold: 0.85,
        enableLogging: true,
      ),
    );
  }

  static CacheManager _socialTemplate() {
    return CacheManager(
      config: const CacheConfig(
        maxCacheSize: 800 * 1024 * 1024, // 800MB
        stalePeriod: Duration(minutes: 15),
        maxAge: Duration(hours: 2),
        enableOfflineMode: true,
        autoCleanup: true,
        cleanupThreshold: 0.9,
        enableLogging: false,
      ),
    );
  }

  static CacheManager _newsTemplate() {
    return CacheManager(
      config: const CacheConfig(
        maxCacheSize: 200 * 1024 * 1024, // 200MB
        stalePeriod: Duration(minutes: 30),
        maxAge: Duration(hours: 6),
        enableOfflineMode: true,
        autoCleanup: true,
        cleanupThreshold: 0.8,
        enableLogging: true,
      ),
    );
  }

  static CacheManager _gameTemplate() {
    return CacheManager(
      config: const CacheConfig(
        maxCacheSize: 2 * 1024 * 1024 * 1024, // 2GB
        stalePeriod: Duration(days: 30),
        maxAge: Duration(days: 90),
        enableOfflineMode: true,
        autoCleanup: false, // Manual cleanup for games
        cleanupThreshold: 0.95,
        enableLogging: false,
      ),
    );
  }

  static CacheManager _productivityTemplate() {
    return CacheManager(
      config: const CacheConfig(
        maxCacheSize: 300 * 1024 * 1024, // 300MB
        stalePeriod: Duration(days: 7),
        maxAge: Duration(days: 30),
        enableOfflineMode: true,
        autoCleanup: true,
        cleanupThreshold: 0.7,
        enableLogging: true,
      ),
    );
  }
}

/// 👶 SimpleCacheManager - Complete key-value caching for beginners
///
/// This provides a super simple API for common caching scenarios.
/// Perfect for beginners who want zero-config caching in 5 minutes!
///
/// Features:
/// - Direct key-value storage (JSON, String, Int, Bool, Bytes)
/// - URL-based caching for images and API responses
/// - Zero configuration required
/// - High performance Hive storage
/// - Automatic memory management
class SimpleCacheManager {
  static CacheManager? _instance;
  static SimpleCacheStorage? _simpleStorage;
  static bool _initialized = false;

  /// Initialize simple cache (call once at app start)
  ///
  /// ```dart
  /// await SimpleCacheManager.init();
  /// ```
  static Future<void> init({
    HiveCacheStorage? hiveCacheStorage,
    NetworkRemoteDataSource? remoteDataSource,
    NetworkInfo? networkInfo,
  }) async {
    if (_initialized) return;

    try {
      // Initialize simple storage first
      _simpleStorage = SimpleCacheStorage();
      await _simpleStorage!.init();

      // Initialize main cache manager
      _instance = CacheManager(
        config: const CacheConfig(
          maxCacheSize: 50 * 1024 * 1024, // 50MB - perfect for small apps
          stalePeriod: Duration(hours: 24), // Refresh daily
          enableLogging: false, // Quiet by default
          autoCleanup: true, // Self-cleaning
          enableOfflineMode: true, // Works offline
        ),
        hiveCacheStorage: hiveCacheStorage,
        remoteDataSource: remoteDataSource,
        networkInfo: networkInfo,
      );

      _initialized = true;
    } catch (e) {
      throw Exception('Failed to initialize SimpleCacheManager: $e');
    }
  }

  /// Get cache manager instance (throws if not initialized)
  static CacheManager get instance {
    if (_instance == null) {
      throw StateError(
          'SimpleCacheManager not initialized! Call SimpleCacheManager.init() first');
    }
    return _instance!;
  }

  /// Get simple storage instance (throws if not initialized)
  static SimpleCacheStorage get _storage {
    if (_simpleStorage == null) {
      throw StateError(
          'SimpleCacheManager not initialized! Call SimpleCacheManager.init() first');
    }
    return _simpleStorage!;
  }

  // ==================== KEY-VALUE STORAGE ====================

  /// Save JSON data to cache (for API responses, user data, etc.)
  ///
  /// ```dart
  /// await SimpleCacheManager.saveJson('user_profile', userData);
  /// ```
  static Future<void> saveJson(String key, Map<String, dynamic> data) async {
    await _storage.setJson(key, data);
  }

  /// Get JSON data from cache
  ///
  /// ```dart
  /// final userData = await SimpleCacheManager.getJson('user_profile');
  /// ```
  static Future<Map<String, dynamic>?> getJson(String key) async {
    return await _storage.getJson(key);
  }

  /// Save string data to cache
  ///
  /// ```dart
  /// await SimpleCacheManager.saveString('username', 'john_doe');
  /// ```
  static Future<void> saveString(String key, String data) async {
    await _storage.setString(key, data);
  }

  /// Get string data from cache
  ///
  /// ```dart
  /// final username = await SimpleCacheManager.getString('username');
  /// ```
  static Future<String?> getString(String key) async {
    return await _storage.getString(key);
  }

  /// Save integer data to cache
  ///
  /// ```dart
  /// await SimpleCacheManager.saveInt('user_age', 25);
  /// ```
  static Future<void> saveInt(String key, int data) async {
    await _storage.setInt(key, data);
  }

  /// Get integer data from cache
  ///
  /// ```dart
  /// final age = await SimpleCacheManager.getInt('user_age');
  /// ```
  static Future<int?> getInt(String key) async {
    return await _storage.getInt(key);
  }

  /// Save boolean data to cache
  ///
  /// ```dart
  /// await SimpleCacheManager.saveBool('is_premium', true);
  /// ```
  static Future<void> saveBool(String key, bool data) async {
    await _storage.setBool(key, data);
  }

  /// Get boolean data from cache
  ///
  /// ```dart
  /// final isPremium = await SimpleCacheManager.getBool('is_premium');
  /// ```
  static Future<bool?> getBool(String key) async {
    return await _storage.getBool(key);
  }

  /// Save binary data to cache
  ///
  /// ```dart
  /// await SimpleCacheManager.saveBytes('avatar', imageBytes);
  /// ```
  static Future<void> saveBytes(String key, Uint8List data) async {
    await _storage.setBytes(key, data);
  }

  /// Get binary data from cache
  ///
  /// ```dart
  /// final imageBytes = await SimpleCacheManager.getBytes('avatar');
  /// ```
  static Future<Uint8List?> getBytes(String key) async {
    return await _storage.getBytes(key);
  }

  // ==================== URL-BASED CACHING ====================

  /// Cache image from URL
  ///
  /// ```dart
  /// await SimpleCacheManager.cacheImage('https://api.example.com/avatar.jpg');
  /// ```
  static Future<void> cacheImage(String imageUrl) async {
    await instance.getBytes(imageUrl);
  }

  /// Get cached image bytes from URL
  ///
  /// ```dart
  /// final imageBytes = await SimpleCacheManager.getImage('https://api.example.com/avatar.jpg');
  /// ```
  static Future<List<int>?> getImage(String imageUrl) async {
    try {
      final bytes = await instance.getBytes(imageUrl);
      return bytes.toList();
    } catch (e) {
      return null;
    }
  }

  /// Cache JSON from URL
  ///
  /// ```dart
  /// final data = await SimpleCacheManager.cacheJsonFromUrl('https://api.example.com/user/123');
  /// ```
  static Future<Map<String, dynamic>> cacheJsonFromUrl(String url) async {
    return await instance.getJson(url);
  }

  // ==================== UTILITY METHODS ====================

  /// Check if a key exists in key-value storage
  ///
  /// ```dart
  /// final exists = await SimpleCacheManager.contains('user_profile');
  /// ```
  static Future<bool> contains(String key) async {
    return await _storage.contains(key);
  }

  /// Remove data by key from key-value storage
  ///
  /// ```dart
  /// await SimpleCacheManager.remove('user_profile');
  /// ```
  static Future<void> remove(String key) async {
    await _storage.remove(key);
  }

  /// Get all keys from key-value storage
  ///
  /// ```dart
  /// final keys = await SimpleCacheManager.getAllKeys();
  /// ```
  static Future<List<String>> getAllKeys() async {
    return await _storage.getAllKeys();
  }

  /// Get storage statistics
  ///
  /// ```dart
  /// final stats = await SimpleCacheManager.getStats();
  /// print('Total entries: ${stats['totalEntries']}');
  /// ```
  static Future<Map<String, dynamic>> getStats() async {
    return await _storage.getStats();
  }

  /// Clear all key-value storage
  ///
  /// ```dart
  /// await SimpleCacheManager.clearKeyValueStorage();
  /// ```
  static Future<void> clearKeyValueStorage() async {
    await _storage.clear();
  }

  /// Clear all URL-based cache
  ///
  /// ```dart
  /// await SimpleCacheManager.clearUrlCache();
  /// ```
  static Future<void> clearUrlCache() async {
    await instance.clearCache();
  }

  /// Clear everything (both key-value and URL cache)
  ///
  /// ```dart
  /// await SimpleCacheManager.clearAll();
  /// ```
  static Future<void> clearAll() async {
    await clearKeyValueStorage();
    await clearUrlCache();
  }

  /// Close and cleanup all resources
  ///
  /// ```dart
  /// await SimpleCacheManager.close();
  /// ```
  static Future<void> close() async {
    await _storage.close();
    _initialized = false;
    _instance = null;
    _simpleStorage = null;
  }
}

/// App type for template selection
enum AppType {
  ecommerce,
  social,
  news,
  game,
  productivity,
  finance,
  education,
  health,
  travel,
  lifestyle,
  entertainment,
  sports,
  wellness,
  other,
}
