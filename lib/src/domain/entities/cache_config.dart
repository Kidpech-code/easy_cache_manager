/// Configuration for cache behavior
class CacheConfig {
  final int maxCacheSize;
  final Duration stalePeriod;
  final Duration maxAge;
  final bool enableOfflineMode;
  final bool autoCleanup;
  final double cleanupThreshold;
  final String cacheName;
  final bool enableLogging;
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
