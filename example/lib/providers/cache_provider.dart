import 'package:flutter/foundation.dart';
import 'package:easy_cache_manager/easy_cache_manager.dart';

/// 🚀 Cache Provider for Centralized Cache Management
///
/// Manages multiple cache configurations and provides reactive state
/// management for cache operations throughout the application.
///
/// ## Features:
/// - Multiple cache configurations (Minimal, Standard, Advanced)
/// - Reactive cache statistics
/// - Error handling and logging
/// - Performance monitoring
/// - Configuration switching
class CacheProvider extends ChangeNotifier {
  // Cache managers for different configurations
  CacheManager? _minimalCache;
  CacheManager? _standardCache;
  CacheManager? _advancedCache;

  // Current configuration
  CacheConfigurationType _currentConfiguration =
      CacheConfigurationType.standard;

  // Statistics and state
  bool _isInitialized = false;
  String? _lastError;
  CacheStats _statistics = CacheStats.empty();

  // Getters
  CacheConfigurationType get currentConfiguration => _currentConfiguration;
  bool get isInitialized => _isInitialized;
  String? get lastError => _lastError;
  CacheStats get statistics => _statistics;

  /// Current active cache manager
  CacheManager get currentCache {
    switch (_currentConfiguration) {
      case CacheConfigurationType.minimal:
        return _minimalCache!;
      case CacheConfigurationType.standard:
        return _standardCache!;
      case CacheConfigurationType.advanced:
        return _advancedCache!;
    }
  }

  /// Initialize all cache configurations
  Future<void> initialize() async {
    try {
      // Initialize Minimal Configuration (5-25MB)
      _minimalCache = CacheManager(
        config: const CacheConfig(
          maxCacheSize: 25 * 1024 * 1024, // 25MB
          stalePeriod: Duration(hours: 2),
          enableLogging: true,
        ),
      );

      // Initialize Standard Configuration (50-200MB)
      _standardCache = CacheManager(
        config: const CacheConfig(
          maxCacheSize: 200 * 1024 * 1024, // 200MB
          stalePeriod: Duration(days: 1),
          maxAge: Duration(hours: 24),
          enableOfflineMode: true,
          autoCleanup: true,
          cleanupThreshold: 0.8,
          enableLogging: true,
        ),
      );

      // Initialize Advanced Configuration (500MB+)
      _advancedCache = CacheManager(
        config: const CacheConfig(
          maxCacheSize: 500 * 1024 * 1024, // 500MB
          stalePeriod: Duration(days: 7),
          maxAge: Duration(days: 30),
          enableOfflineMode: true,
          autoCleanup: true,
          cleanupThreshold: 0.9,
          enableLogging: true,
        ),
      );

      _isInitialized = true;
      _lastError = null;

      // Start periodic statistics update
      _startStatisticsUpdater();

      notifyListeners();
    } catch (e) {
      _lastError = 'Failed to initialize cache: $e';
      _isInitialized = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Switch to a different cache configuration
  Future<void> switchConfiguration(CacheConfigurationType type) async {
    if (_currentConfiguration == type || !_isInitialized) return;

    _currentConfiguration = type;
    await _updateStatistics();
    notifyListeners();
  }

  /// Clear all caches
  Future<void> clearAllCaches() async {
    try {
      await Future.wait([
        if (_minimalCache != null) _minimalCache!.clearCache(),
        if (_standardCache != null) _standardCache!.clearCache(),
        if (_advancedCache != null) _advancedCache!.clearCache(),
      ]);

      await _updateStatistics();
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _lastError = 'Failed to clear caches: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Clear current cache
  Future<void> clearCurrentCache() async {
    try {
      await currentCache.clearCache();
      await _updateStatistics();
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _lastError = 'Failed to clear cache: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Get cache statistics for all configurations
  Future<Map<String, CacheStats>> getAllStatistics() async {
    final stats = <String, CacheStats>{};

    if (_minimalCache != null) {
      stats['minimal'] = await _minimalCache!.getStats();
    }

    if (_standardCache != null) {
      stats['standard'] = await _standardCache!.getStats();
    }

    if (_advancedCache != null) {
      stats['advanced'] = await _advancedCache!.getStats();
    }

    return stats;
  }

  /// Update statistics for current cache
  Future<void> _updateStatistics() async {
    if (!_isInitialized) return;

    try {
      _statistics = await currentCache.getStats();
    } catch (e) {
      _lastError = 'Failed to update statistics: $e';
    }
  }

  /// Start periodic statistics updater
  void _startStatisticsUpdater() {
    // Update statistics every 5 seconds
    Future.delayed(const Duration(seconds: 5), () async {
      if (_isInitialized) {
        await _updateStatistics();
        notifyListeners();
        _startStatisticsUpdater();
      }
    });
  }

  /// Get cache manager by type
  CacheManager? getCacheByType(CacheConfigurationType type) {
    switch (type) {
      case CacheConfigurationType.minimal:
        return _minimalCache;
      case CacheConfigurationType.standard:
        return _standardCache;
      case CacheConfigurationType.advanced:
        return _advancedCache;
    }
  }

  /// Dispose all resources
  @override
  void dispose() {
    _minimalCache?.dispose();
    _standardCache?.dispose();
    _advancedCache?.dispose();
    super.dispose();
  }
}

/// Cache configuration types
enum CacheConfigurationType {
  minimal('Minimal (5-25MB)', 'Perfect for small apps'),
  standard('Standard (50-200MB)', 'Balanced for most apps'),
  advanced('Advanced (500MB+)', 'Enterprise features');

  const CacheConfigurationType(this.displayName, this.description);

  final String displayName;
  final String description;
}
