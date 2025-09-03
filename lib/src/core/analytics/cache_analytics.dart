/// CacheAnalytics interface for collecting cache metrics
/// Supports latency, per-key stats, histogram, export
library;

abstract class CacheAnalytics {
  /// Called on every cache operation
  void recordEvent(CacheAnalyticsEvent event);

  /// Export metrics as Map (for JSON/CSV)
  Map<String, dynamic> exportMetrics();
}

class CacheAnalyticsEvent {
  final String type; // e.g. 'hit', 'miss', 'evict', 'store', 'retrieve'
  final String key;
  final int? sizeBytes;
  final Duration? latency;
  final DateTime timestamp;

  CacheAnalyticsEvent({
    required this.type,
    required this.key,
    this.sizeBytes,
    this.latency,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Example: Simple in-memory analytics
class SimpleCacheAnalytics implements CacheAnalytics {
  int hitCount = 0;
  int missCount = 0;
  int evictCount = 0;
  final Map<String, List<Duration>> keyLatencies = {};

  @override
  void recordEvent(CacheAnalyticsEvent event) {
    switch (event.type) {
      case 'hit':
        hitCount++;
        break;
      case 'miss':
        missCount++;
        break;
      case 'evict':
        evictCount++;
        break;
    }
    if (event.latency != null) {
      keyLatencies.putIfAbsent(event.key, () => []).add(event.latency!);
    }
  }

  @override
  Map<String, dynamic> exportMetrics() {
    return {
      'hitCount': hitCount,
      'missCount': missCount,
      'evictCount': evictCount,
      'keyLatencies': keyLatencies
          .map((k, v) => MapEntry(k, v.map((d) => d.inMilliseconds).toList())),
    };
  }
}
