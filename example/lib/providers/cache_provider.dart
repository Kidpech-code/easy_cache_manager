import 'package:flutter/foundation.dart';
import 'package:easy_cache_manager/easy_cache_manager.dart';

/// 🚀 [CacheProvider] - Centralized, Reactive Cache Management for Flutter Apps
///
/// This provider manages multiple cache configurations (Minimal, Standard, Advanced)
/// and exposes a unified, reactive API for cache operations, statistics, and error handling.
///
/// ### Key Features
/// - **Multiple Configurations:** Instantiates and manages minimal, standard, and advanced cache managers for different app needs.
/// - **Reactive State:** Notifies listeners on cache/statistics changes for seamless UI updates.
/// - **Performance Monitoring:** Periodically updates cache statistics for dashboards and analytics.
/// - **Error Handling:** Captures and exposes last error for diagnostics and UI feedback.
/// - **Configuration Switching:** Allows runtime switching between cache strategies.
/// - **Resource Management:** Disposes all cache managers and resources cleanly.
///
/// ### Usage Example
/// ```dart
/// final provider = Provider.of<CacheProvider>(context);
/// await provider.initialize();
/// provider.switchConfiguration(CacheConfigurationType.advanced);
/// await provider.currentCache.save('key', value);
/// final stats = provider.statistics;
/// ```
///
/// ### Best Practices
/// - Use [switchConfiguration] to adapt cache strategy to user/device/app state.
/// - Use [statistics] for real-time monitoring and UI feedback.
/// - Always call [dispose] to release resources.
///
/// ### See Also
/// - [CacheManager], [CacheStats], [CacheConfigurationType]
class CacheProvider extends ChangeNotifier {
  /// Internal cache managers for each configuration type
  CacheManager? _minimalCache;
  CacheManager? _standardCache;
  CacheManager? _advancedCache;

  /// Currently active cache configuration type
  CacheConfigurationType _currentConfiguration =
      CacheConfigurationType.standard;

  /// Initialization state
  bool _isInitialized = false;

  /// Last error message (if any)
  String? _lastError;

  /// Latest cache statistics for current configuration
  CacheStats _statistics = CacheStats.empty();

  /// Returns the currently selected cache configuration type
  CacheConfigurationType get currentConfiguration => _currentConfiguration;

  /// Returns true if all cache managers are initialized
  bool get isInitialized => _isInitialized;

  /// Returns the last error message, if any
  String? get lastError => _lastError;

  /// Returns the latest cache statistics for the current configuration
  CacheStats get statistics => _statistics;

  /// Returns the current active [CacheManager] based on selected configuration
  /// Throws if not initialized or configuration is missing
  CacheManager get currentCache {
    switch (_currentConfiguration) {
      case CacheConfigurationType.minimal:
        if (_minimalCache == null) {
          throw Exception('Minimal cache not initialized');
        }
        return _minimalCache!;
      case CacheConfigurationType.standard:
        if (_standardCache == null) {
          throw Exception('Standard cache not initialized');
        }
        return _standardCache!;
      case CacheConfigurationType.advanced:
        if (_advancedCache == null) {
          throw Exception('Advanced cache not initialized');
        }
        return _advancedCache!;
    }
  }

  /// Initializes all cache managers for each configuration type.
  ///
  /// - Minimal: 25MB, fast, for small apps
  /// - Standard: 200MB, balanced, for most apps
  /// - Advanced: 500MB, enterprise, for large/complex apps
  ///
  /// Notifies listeners on completion or error.
  Future<void> initialize() async {
    try {
      _minimalCache = CacheManager(
        config: const AdvancedCacheConfig(
          maxCacheSize: 25 * 1024 * 1024, // 25MB
          stalePeriod: Duration(hours: 2),
          enableLogging: true,
        ),
      );
      _standardCache = CacheManager(
        config: const AdvancedCacheConfig(
          maxCacheSize: 200 * 1024 * 1024, // 200MB
          stalePeriod: Duration(days: 1),
          maxAge: Duration(hours: 24),
          enableOfflineMode: true,
          autoCleanup: true,
          cleanupThreshold: 0.8,
          enableLogging: true,
        ),
      );
      _advancedCache = CacheManager(
        config: const AdvancedCacheConfig(
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
      _startStatisticsUpdater();
      notifyListeners();
    } catch (e) {
      _lastError = 'Failed to initialize cache: $e';
      _isInitialized = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Switches the active cache configuration at runtime.
  ///
  /// [type] - The configuration type to switch to.
  /// Notifies listeners and updates statistics.
  Future<void> switchConfiguration(CacheConfigurationType type) async {
    if (_currentConfiguration == type || !_isInitialized) return;
    _currentConfiguration = type;
    await _updateStatistics();
    notifyListeners();
  }

  /// Clears all caches for every configuration type.
  /// Notifies listeners and updates statistics.
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

  /// Clears the currently active cache only.
  /// Notifies listeners and updates statistics.
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

  /// Returns cache statistics for all configuration types.
  /// Useful for dashboards and analytics.
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

  /// Updates statistics for the current cache configuration.
  /// Internal use only.
  Future<void> _updateStatistics() async {
    if (!_isInitialized) return;
    try {
      _statistics = await currentCache.getStats();
    } catch (e) {
      _lastError = 'Failed to update statistics: $e';
    }
  }

  /// Starts a periodic statistics updater (every 5 seconds).
  /// Keeps [statistics] up-to-date for real-time monitoring.
  void _startStatisticsUpdater() {
    Future.delayed(const Duration(seconds: 5), () async {
      if (_isInitialized) {
        await _updateStatistics();
        notifyListeners();
        _startStatisticsUpdater();
      }
    });
  }

  /// Returns the [CacheManager] for a given configuration type.
  /// Returns null if not initialized.
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

  /// Disposes all cache managers and resources.
  /// Always call this to prevent memory leaks.
  @override
  void dispose() {
    _minimalCache?.dispose();
    _standardCache?.dispose();
    _advancedCache?.dispose();
    super.dispose();
  }
}

/// Cache configuration types for [CacheProvider]
///
/// - [minimal]: 5-25MB, for small apps and prototypes
/// - [standard]: 50-200MB, for most production apps
/// - [advanced]: 500MB+, for enterprise and data-heavy apps
enum CacheConfigurationType {
  minimal('Minimal (5-25MB)', 'Perfect for small apps'),
  standard('Standard (50-200MB)', 'Balanced for most apps'),
  advanced('Advanced (500MB+)', 'Enterprise features');

  /// Display name for UI
  final String displayName;

  /// Description for documentation/UI
  final String description;

  const CacheConfigurationType(this.displayName, this.description);
}
