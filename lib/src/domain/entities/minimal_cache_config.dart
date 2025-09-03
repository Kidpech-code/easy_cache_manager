import '../entities/cache_config.dart';

/// Cache mode configuration
enum CacheMode {
  /// Full-featured mode with SQLite and file system
  full,

  /// Minimal mode with in-memory and shared preferences
  minimal,

  /// Memory-only mode (no persistence)
  memoryOnly,
}

/// Minimal cache configuration
class MinimalCacheConfig extends CacheConfig {
  final CacheMode mode;
  final bool useSharedPreferences;
  final int maxMemoryEntries;

  const MinimalCacheConfig({
    this.mode = CacheMode.minimal,
    this.useSharedPreferences = true,
    this.maxMemoryEntries = 100,
    super.maxCacheSize = 10 * 1024 * 1024, // 10MB for minimal
    super.stalePeriod = const Duration(hours: 24),
    super.maxAge = const Duration(hours: 1),
    super.enableOfflineMode = true,
    super.autoCleanup = true,
    super.cleanupThreshold = 0.9,
    super.cacheName = 'easy_cache_minimal',
    super.enableLogging = false,
    super.maxCacheEntries = 100,
  });

  @override
  MinimalCacheConfig copyWith({
    CacheMode? mode,
    bool? useSharedPreferences,
    int? maxMemoryEntries,
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
    return MinimalCacheConfig(
      mode: mode ?? this.mode,
      useSharedPreferences: useSharedPreferences ?? this.useSharedPreferences,
      maxMemoryEntries: maxMemoryEntries ?? this.maxMemoryEntries,
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
}
