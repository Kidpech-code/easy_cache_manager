/// Cache statistics for monitoring and analytics
class CacheStats {
  final int totalEntries;
  final int totalSizeInBytes;
  final int hitCount;
  final int missCount;
  final int evictionCount;
  final double hitRate;
  final DateTime lastCleanup;
  final Duration averageLoadTime;

  const CacheStats({
    required this.totalEntries,
    required this.totalSizeInBytes,
    required this.hitCount,
    required this.missCount,
    required this.evictionCount,
    required this.hitRate,
    required this.lastCleanup,
    required this.averageLoadTime,
  });

  /// Create empty stats
  factory CacheStats.empty() {
    return CacheStats(
      totalEntries: 0,
      totalSizeInBytes: 0,
      hitCount: 0,
      missCount: 0,
      evictionCount: 0,
      hitRate: 0.0,
      lastCleanup: DateTime.now(),
      averageLoadTime: Duration.zero,
    );
  }

  /// Total cache size in MB
  double get totalSizeInMB => totalSizeInBytes / (1024 * 1024);

  /// Total requests (hits + misses)
  int get totalRequests => hitCount + missCount;

  /// Miss rate
  double get missRate => 1.0 - hitRate;

  /// Create a copy with updated values
  CacheStats copyWith({
    int? totalEntries,
    int? totalSizeInBytes,
    int? hitCount,
    int? missCount,
    int? evictionCount,
    double? hitRate,
    DateTime? lastCleanup,
    Duration? averageLoadTime,
  }) {
    return CacheStats(
      totalEntries: totalEntries ?? this.totalEntries,
      totalSizeInBytes: totalSizeInBytes ?? this.totalSizeInBytes,
      hitCount: hitCount ?? this.hitCount,
      missCount: missCount ?? this.missCount,
      evictionCount: evictionCount ?? this.evictionCount,
      hitRate: hitRate ?? this.hitRate,
      lastCleanup: lastCleanup ?? this.lastCleanup,
      averageLoadTime: averageLoadTime ?? this.averageLoadTime,
    );
  }

  @override
  String toString() {
    return 'CacheStats('
        'entries: $totalEntries, '
        'size: ${totalSizeInMB.toStringAsFixed(2)}MB, '
        'hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, '
        'hits: $hitCount, '
        'misses: $missCount, '
        'evictions: $evictionCount, '
        'avgLoadTime: ${averageLoadTime.inMilliseconds}ms)';
  }
}
