import 'package:flutter_test/flutter_test.dart';
import 'package:easy_cache_manager/src/core/analytics/cache_analytics.dart';

void main() {
  test('SimpleCacheAnalytics records events and exports metrics', () {
    final analytics = SimpleCacheAnalytics();
    analytics.recordEvent(CacheAnalyticsEvent(
        type: 'hit', key: 'a', latency: const Duration(milliseconds: 10)));
    analytics.recordEvent(CacheAnalyticsEvent(
        type: 'miss', key: 'b', latency: const Duration(milliseconds: 20)));
    analytics.recordEvent(CacheAnalyticsEvent(type: 'evict', key: 'a'));
    analytics.recordEvent(CacheAnalyticsEvent(
        type: 'hit', key: 'a', latency: const Duration(milliseconds: 15)));

    final metrics = analytics.exportMetrics();
    expect(metrics['hitCount'], 2);
    expect(metrics['missCount'], 1);
    expect(metrics['evictCount'], 1);
    expect(metrics['keyLatencies']['a'], [10, 15]);
    expect(metrics['keyLatencies']['b'], [20]);
  });
}
