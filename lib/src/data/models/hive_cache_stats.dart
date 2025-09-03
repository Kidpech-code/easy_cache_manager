import 'package:hive/hive.dart';
import '../../domain/entities/cache_stats.dart';

part 'hive_cache_stats.g.dart';

@HiveType(typeId: 1)
class HiveCacheStats extends HiveObject {
  @HiveField(0)
  int totalEntries;

  @HiveField(1)
  int totalSizeInBytes;

  @HiveField(2)
  int hitCount;

  @HiveField(3)
  int missCount;

  @HiveField(4)
  int evictionCount;

  @HiveField(5)
  DateTime lastCleanup;

  @HiveField(6)
  int averageLoadTimeMs;

  @HiveField(7)
  int requestCount;

  @HiveField(8)
  int totalLoadTimeMs;

  HiveCacheStats({
    this.totalEntries = 0,
    this.totalSizeInBytes = 0,
    this.hitCount = 0,
    this.missCount = 0,
    this.evictionCount = 0,
    DateTime? lastCleanup,
    Duration averageLoadTime = Duration.zero,
    this.requestCount = 0,
    this.totalLoadTimeMs = 0,
  })  : lastCleanup = lastCleanup ?? DateTime.now(),
        averageLoadTimeMs = averageLoadTime.inMilliseconds;

  /// Calculate hit rate percentage
  double get hitRate {
    final totalRequests = hitCount + missCount;
    return totalRequests > 0 ? (hitCount / totalRequests) * 100 : 0.0;
  }

  /// Increment hit count
  void incrementHit() {
    hitCount++;
  }

  /// Increment miss count
  void incrementMiss() {
    missCount++;
  }

  /// Increment eviction count
  void incrementEviction([int count = 1]) {
    evictionCount += count;
  }

  /// Update load time
  void addLoadTime(Duration duration) {
    totalLoadTimeMs += duration.inMilliseconds;
    requestCount++;
    averageLoadTimeMs = (totalLoadTimeMs / requestCount).round();
  }

  /// Reset all counters
  void reset() {
    totalEntries = 0;
    totalSizeInBytes = 0;
    hitCount = 0;
    missCount = 0;
    evictionCount = 0;
    lastCleanup = DateTime.now();
    averageLoadTimeMs = 0;
    requestCount = 0;
    totalLoadTimeMs = 0;
  }

  /// Convert to domain entity
  CacheStats toEntity() {
    return CacheStats(
      totalEntries: totalEntries,
      totalSizeInBytes: totalSizeInBytes,
      hitCount: hitCount,
      missCount: missCount,
      evictionCount: evictionCount,
      hitRate: hitRate,
      lastCleanup: lastCleanup,
      averageLoadTime: Duration(milliseconds: averageLoadTimeMs),
    );
  }

  /// Create from domain entity
  static HiveCacheStats fromEntity(CacheStats entity) {
    return HiveCacheStats(
      totalEntries: entity.totalEntries,
      totalSizeInBytes: entity.totalSizeInBytes,
      hitCount: entity.hitCount,
      missCount: entity.missCount,
      evictionCount: entity.evictionCount,
      lastCleanup: entity.lastCleanup,
      averageLoadTime: entity.averageLoadTime,
    );
  }

  @override
  String toString() {
    return 'HiveCacheStats(entries: $totalEntries, size: ${(totalSizeInBytes / 1024 / 1024).toStringAsFixed(1)}MB, hitRate: ${hitRate.toStringAsFixed(1)}%)';
  }
}
