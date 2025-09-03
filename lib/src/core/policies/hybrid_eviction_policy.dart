import 'eviction_policy.dart';

/// Hybrid Eviction Policy (LRU + LFU)
class HybridEvictionPolicy implements EvictionPolicy {
  final int maxEntries;
  final Map<String, int> _frequency = {};

  HybridEvictionPolicy(this.maxEntries);

  @override
  bool shouldEvict(
      String key, int entryCount, int ttl, int currentEntries, int maxEntries) {
    return currentEntries >= maxEntries;
  }

  @override
  List<String> selectKeysToEvict(Map<String, DateTime> accessMap, int count) {
    // Hybrid: use LFU if hit rate < 0.5, else LRU (stub logic)
    const hitRate = 0.5; // TD: inject real hit rate
    if (hitRate < 0.5) {
      final sorted = _frequency.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      return sorted.take(count).map((e) => e.key).toList();
    } else {
      final sorted = accessMap.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      return sorted.take(count).map((e) => e.key).toList();
    }
  }

  void recordAccess(String key) {
    _frequency[key] = (_frequency[key] ?? 0) + 1;
  }

  void onAccess(String key) => recordAccess(key);
}
