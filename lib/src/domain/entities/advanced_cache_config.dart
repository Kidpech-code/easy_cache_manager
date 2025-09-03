import 'cache_config.dart';

/// Extended cache configuration with advanced features
class AdvancedCacheConfig extends CacheConfig {
  final String evictionPolicy;
  final bool enableCompression;
  final String compressionType;
  final int compressionLevel;
  final bool enableEncryption;
  final String? encryptionKey;
  final int maxFileSize;
  final bool enableMetrics;
  final bool backgroundSync;
  final Duration syncInterval;
  final int compressionThreshold;
  final bool enableCaching;

  const AdvancedCacheConfig({
    super.maxCacheSize,
    super.stalePeriod,
    super.maxAge,
    super.enableOfflineMode,
    super.autoCleanup,
    super.cleanupThreshold,
    super.cacheName,
    super.enableLogging,
    super.maxCacheEntries,
    this.evictionPolicy = 'lru',
    this.enableCompression = false,
    this.compressionType = 'gzip',
    this.compressionLevel = 6,
    this.enableEncryption = false,
    this.encryptionKey,
    this.maxFileSize = 50 * 1024 * 1024, // 50MB
    this.enableMetrics = true,
    this.backgroundSync = false,
    this.syncInterval = const Duration(hours: 1),
    this.compressionThreshold = 1024,
    this.enableCaching = true,
  });

  @override
  AdvancedCacheConfig copyWith({
    String? evictionPolicy,
    bool? enableCompression,
    String? compressionType,
    int? compressionLevel,
    bool? enableEncryption,
    String? encryptionKey,
    int? maxFileSize,
    bool? enableMetrics,
    bool? backgroundSync,
    Duration? syncInterval,
    int? compressionThreshold,
    bool? enableCaching,
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
    return AdvancedCacheConfig(
      evictionPolicy: evictionPolicy ?? this.evictionPolicy,
      enableCompression: enableCompression ?? this.enableCompression,
      compressionType: compressionType ?? this.compressionType,
      compressionLevel: compressionLevel ?? this.compressionLevel,
      enableEncryption: enableEncryption ?? this.enableEncryption,
      encryptionKey: encryptionKey ?? this.encryptionKey,
      maxFileSize: maxFileSize ?? this.maxFileSize,
      enableMetrics: enableMetrics ?? this.enableMetrics,
      backgroundSync: backgroundSync ?? this.backgroundSync,
      syncInterval: syncInterval ?? this.syncInterval,
      compressionThreshold: compressionThreshold ?? this.compressionThreshold,
      enableCaching: enableCaching ?? this.enableCaching,
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

  /// Factory constructor for production use (recommended settings)
  factory AdvancedCacheConfig.production({
    int maxCacheSize = 100 * 1024 * 1024, // 100MB
    String? cacheName,
  }) {
    return AdvancedCacheConfig(
      evictionPolicy: 'ttl+lru',
      maxCacheSize: maxCacheSize,
      cacheName: cacheName ?? 'EasyCacheAdvanced',
      enableCompression: true,
      compressionThreshold: 1024, // 1KB
      enableEncryption: false, // User should provide key if needed
      enableMetrics: true,
      backgroundSync: true,
      autoCleanup: true,
      cleanupThreshold: 0.8, // Clean when 80% full
      enableLogging: false, // Disable in production
    );
  }

  /// Factory constructor for development use
  factory AdvancedCacheConfig.development({String? cacheName}) {
    return AdvancedCacheConfig(
      evictionPolicy: 'lru',
      maxCacheSize: 10 * 1024 * 1024, // 10MB
      cacheName: cacheName ?? 'EasyCacheDev',
      enableCompression: false, // Faster development
      enableEncryption: false,
      enableMetrics: true,
      backgroundSync: false,
      autoCleanup: true,
      cleanupThreshold: 0.9, // More lenient
      enableLogging: true, // Enable for debugging
    );
  }

  /// Factory constructor for performance-focused use
  factory AdvancedCacheConfig.performanceFocused({
    int maxCacheSize = 200 * 1024 * 1024, // 200MB
    String? cacheName,
  }) {
    return AdvancedCacheConfig(
      evictionPolicy: 'size-based',
      maxCacheSize: maxCacheSize,
      cacheName: cacheName ?? 'EasyCachePerf',
      enableCompression: true,
      compressionLevel: 3, // Faster compression
      enableEncryption: false,
      enableMetrics: true,
      backgroundSync: true,
      autoCleanup: true,
      cleanupThreshold: 0.7, // Aggressive cleanup
      enableLogging: false,
    );
  }
}
