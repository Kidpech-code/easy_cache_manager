import '../../domain/entities/cache_stats.dart';

/// Data model for cache statistics
class CacheStatsModel extends CacheStats {
  const CacheStatsModel({
    required super.totalEntries,
    required super.totalSizeInBytes,
    required super.hitCount,
    required super.missCount,
    required super.evictionCount,
    required super.hitRate,
    required super.lastCleanup,
    required super.averageLoadTime,
  });

  /// Create model from domain entity
  factory CacheStatsModel.fromEntity(CacheStats entity) {
    return CacheStatsModel(
      totalEntries: entity.totalEntries,
      totalSizeInBytes: entity.totalSizeInBytes,
      hitCount: entity.hitCount,
      missCount: entity.missCount,
      evictionCount: entity.evictionCount,
      hitRate: entity.hitRate,
      lastCleanup: entity.lastCleanup,
      averageLoadTime: entity.averageLoadTime,
    );
  }

  /// Create model from JSON
  factory CacheStatsModel.fromJson(Map<String, dynamic> json) {
    return CacheStatsModel(
      totalEntries: json['total_entries'] as int,
      totalSizeInBytes: json['total_size_in_bytes'] as int,
      hitCount: json['hit_count'] as int,
      missCount: json['miss_count'] as int,
      evictionCount: json['eviction_count'] as int,
      hitRate: (json['hit_rate'] as num).toDouble(),
      lastCleanup:
          DateTime.fromMillisecondsSinceEpoch(json['last_cleanup'] as int),
      averageLoadTime:
          Duration(milliseconds: json['average_load_time_ms'] as int),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'total_entries': totalEntries,
      'total_size_in_bytes': totalSizeInBytes,
      'hit_count': hitCount,
      'miss_count': missCount,
      'eviction_count': evictionCount,
      'hit_rate': hitRate,
      'last_cleanup': lastCleanup.millisecondsSinceEpoch,
      'average_load_time_ms': averageLoadTime.inMilliseconds,
    };
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
      averageLoadTime: averageLoadTime,
    );
  }

  @override
  CacheStatsModel copyWith({
    int? totalEntries,
    int? totalSizeInBytes,
    int? hitCount,
    int? missCount,
    int? evictionCount,
    double? hitRate,
    DateTime? lastCleanup,
    Duration? averageLoadTime,
  }) {
    return CacheStatsModel(
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
}
