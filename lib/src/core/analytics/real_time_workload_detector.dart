/// RealTimeWorkloadDetector - Detects cache workload patterns in real-time
/// Supports: read-heavy, write-heavy, mixed, burst, idle, etc.
library;

import 'cache_analytics.dart';

enum WorkloadType {
  readHeavy,
  writeHeavy,
  mixed,
  burst,
  idle,
}

class RealTimeWorkloadDetector {
  final CacheAnalytics analytics;
  WorkloadType _currentType = WorkloadType.idle;
  DateTime _lastUpdate = DateTime.now();

  RealTimeWorkloadDetector(this.analytics);

  WorkloadType get currentType => _currentType;

  /// Call this periodically (e.g. every N seconds) or after each event
  void update() {
    final metrics = analytics.exportMetrics();
    final hitCount = metrics['hitCount'] ?? 0;
    final missCount = metrics['missCount'] ?? 0;
    final evictCount = metrics['evictCount'] ?? 0;
    final totalOps = hitCount + missCount + evictCount;
    final now = DateTime.now();
    final opsPerSec = totalOps / (now.difference(_lastUpdate).inSeconds + 1);

    // Simple heuristics
    if (opsPerSec < 1) {
      _currentType = WorkloadType.idle;
    } else if (hitCount > missCount * 2) {
      _currentType = WorkloadType.readHeavy;
    } else if (missCount > hitCount * 2) {
      _currentType = WorkloadType.writeHeavy;
    } else if (evictCount > (hitCount + missCount) * 0.5) {
      _currentType = WorkloadType.burst;
    } else {
      _currentType = WorkloadType.mixed;
    }
    _lastUpdate = now;
  }
}
