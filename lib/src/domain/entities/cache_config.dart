/// Configuration class for cache behavior and performance optimization.
///
/// [CacheConfig] defines how the cache manager operates, including size limits,
/// expiration policies, cleanup behavior, and performance settings. This class
/// provides sensible defaults optimized for most use cases while allowing
/// fine-grained control for advanced scenarios.
///
/// ## Default Configuration:
/// - **Maximum cache size**: 100MB
/// - **Stale period**: 7 days (when data is considered stale)
/// - **Maximum age**: 24 hours (when data expires completely)
/// - **Offline mode**: Enabled (fallback to cached data when offline)
/// - **Auto cleanup**: Enabled (automatic cleanup when cache is 80% full)
/// - **Maximum entries**: 1000 items
///
/// ## Usage Examples:
///
/// ### Basic Configuration:
/// ```dart
/// final config = CacheConfig(
///   maxCacheSize: 50 * 1024 * 1024, // 50MB
///   stalePeriod: Duration(days: 3),
///   maxAge: Duration(hours: 12),
/// );
/// ```
///
/// ### Performance-Optimized Configuration:
/// ```dart
/// final config = CacheConfig(
///   maxCacheSize: 200 * 1024 * 1024, // 200MB for better performance
///   stalePeriod: Duration(days: 14),   // Longer stale period
///   cleanupThreshold: 0.9,             // Clean less frequently
///   maxCacheEntries: 5000,             // More items in cache
/// );
/// ```
///
/// ### Memory-Constrained Configuration:
/// ```dart
/// final config = CacheConfig(
///   maxCacheSize: 10 * 1024 * 1024,   // 10MB for low-memory devices
///   stalePeriod: Duration(days: 1),    // Aggressive cleanup
///   cleanupThreshold: 0.6,             // Clean more frequently
///   maxCacheEntries: 100,              // Fewer items
/// );
/// ```
class CacheConfig {
  /// Maximum size of the cache in bytes (default: 100MB)
  ///
  /// When the cache exceeds this size, automatic cleanup will be triggered
  /// based on the configured eviction policy. Larger sizes improve hit rates
  /// but use more storage space.
  final int maxCacheSize;

  /// Duration after which cached data is considered stale but still usable
  ///
  /// Stale data can still be returned to users while being refreshed in the
  /// background. This provides a balance between freshness and performance.
  final Duration stalePeriod;

  /// Maximum age before cached data expires and must be refetched
  ///
  /// After this duration, cached data is completely invalid and fresh data
  /// must be fetched from the source. Should be longer than [stalePeriod].
  final Duration maxAge;

  /// Whether to enable offline mode with cached data fallback
  ///
  /// When enabled, the cache manager will return cached data even if it's
  /// expired when no network connection is available.
  final bool enableOfflineMode;

  /// Whether to automatically clean up expired and excess cache entries
  ///
  /// Automatic cleanup helps maintain cache performance and prevents
  /// unlimited growth. Disable only if you need manual cleanup control.
  final bool autoCleanup;

  /// Threshold (0.0-1.0) at which automatic cleanup is triggered
  ///
  /// When cache size reaches this percentage of [maxCacheSize], cleanup
  /// will be performed. Lower values clean more aggressively.
  final double cleanupThreshold;

  /// Name identifier for the cache storage
  ///
  /// Used to separate different cache instances. Change this if you need
  /// multiple independent caches in the same application.
  final String cacheName;

  /// Whether to enable detailed logging for debugging
  ///
  /// Enables comprehensive logging of cache operations, hits, misses, and
  /// performance metrics. Useful for debugging but impacts performance.
  final bool enableLogging;

  /// Maximum number of entries allowed in the cache
  ///
  /// Prevents memory issues with very small files that could accumulate
  /// infinitely. Oldest entries are evicted when this limit is reached.
  final int maxCacheEntries;

  const CacheConfig({
    this.maxCacheSize = 100 * 1024 * 1024, // 100MB
    this.stalePeriod = const Duration(days: 7),
    this.maxAge = const Duration(hours: 24),
    this.enableOfflineMode = true,
    this.autoCleanup = true,
    this.cleanupThreshold = 0.8, // Clean when 80% full
    this.cacheName = 'easy_cache',
    this.enableLogging = false,
    this.maxCacheEntries = 1000,
  });

  /// Create a copy of this config with updated values
  CacheConfig copyWith({
    int? maxCacheSize,
    Duration? stalePeriod,
    Duration? maxAge,
    bool? enableOfflineMode,
    bool? autoCleanup,
    double? cleanupThreshold,
    String? cacheName,
    bool? enableLogging,
    int? maxCacheEntries,
  }) {
    return CacheConfig(
      maxCacheSize: maxCacheSize ?? this.maxCacheSize,
      stalePeriod: stalePeriod ?? this.stalePeriod,
      maxAge: maxAge ?? this.maxAge,
      enableOfflineMode: enableOfflineMode ?? this.enableOfflineMode,
      autoCleanup: autoCleanup ?? this.autoCleanup,
      cleanupThreshold: cleanupThreshold ?? this.cleanupThreshold,
      cacheName: cacheName ?? this.cacheName,
      enableLogging: enableLogging ?? this.enableLogging,
      maxCacheEntries: maxCacheEntries ?? this.maxCacheEntries,
    );
  }

  @override
  String toString() {
    return 'CacheConfig('
        'maxCacheSize: ${maxCacheSize ~/ (1024 * 1024)}MB, '
        'stalePeriod: $stalePeriod, '
        'maxAge: $maxAge, '
        'enableOfflineMode: $enableOfflineMode, '
        'autoCleanup: $autoCleanup, '
        'cleanupThreshold: $cleanupThreshold, '
        'cacheName: $cacheName, '
        'enableLogging: $enableLogging, '
        'maxCacheEntries: $maxCacheEntries)';
  }
}
