import 'eviction_policy.dart';

/// LFU (Least Frequently Used) Eviction Policy
class LFUEvictionPolicy implements EvictionPolicy {
  final int maxEntries;
  final Map<String, int> _frequency = {};

  LFUEvictionPolicy(this.maxEntries);

  @override
  bool shouldEvict(
      String key, int entryCount, int ttl, int currentEntries, int maxEntries) {
    return currentEntries >= maxEntries;
  }

  @override
  List<String> selectKeysToEvict(Map<String, DateTime> accessMap, int count) {
    // Sort by frequency ascending
    final sorted = _frequency.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return sorted.take(count).map((e) => e.key).toList();
  }

  void recordAccess(String key) {
    _frequency[key] = (_frequency[key] ?? 0) + 1;
  }
}
