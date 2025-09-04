import 'eviction_policy.dart';

/// Hybrid Eviction Policy (LRU + LFU)
class HybridEvictionPolicy implements EvictionPolicy {
  final int maxEntries;
  final Map<String, int> _frequency = {};

  HybridEvictionPolicy(this.maxEntries);

  @override
  bool shouldEvict(String key, int entryCount, int ttl, int currentEntries, int maxEntries) {
    return currentEntries >= maxEntries;
  }

  @override
  List<String> selectKeysToEvict(Map<String, DateTime> accessMap, int count) {
    // LFU: filter keys in accessMap, find minFreq, sort by time if tie
    final candidates = accessMap.keys.where((k) => _frequency.containsKey(k)).toList();
    if (candidates.isEmpty) return [];
    final minFreq = candidates.map((k) => _frequency[k] ?? 0).reduce((a, b) => a < b ? a : b);
    final minFreqKeys = candidates.where((k) => (_frequency[k] ?? 0) == minFreq).toList();
    minFreqKeys.sort((a, b) {
      final timeA = accessMap[a] ?? DateTime.fromMillisecondsSinceEpoch(0);
      final timeB = accessMap[b] ?? DateTime.fromMillisecondsSinceEpoch(0);
      return timeA.compareTo(timeB);
    });
    return minFreqKeys.take(count).toList();
    // Hybrid: use LFU if hit rate < 0.5, else LRU (stub logic)
  }

  void recordAccess(String key) {
    _frequency[key] = (_frequency[key] ?? 0) + 1;
  }

  void onAccess(String key) => recordAccess(key);
}
