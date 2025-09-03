/// EvictionPolicy interface for cache storage
/// Supports LRU, TTL, MaxEntries, and custom strategies
library;

abstract class EvictionPolicy {
  /// Called before storing a new entry
  /// Should return true if eviction is needed
  bool shouldEvict(
      String key, int currentSize, int maxSize, int entryCount, int maxEntries);

  /// Called to select keys to evict
  /// Returns a list of keys to remove
  List<String> selectKeysToEvict(Map<String, DateTime> keyAccessMap, int count);
}

/// Example: TTL-based eviction policy
class TTLEvictionPolicy implements EvictionPolicy {
  final Duration ttl;
  TTLEvictionPolicy(this.ttl);

  @override
  bool shouldEvict(String key, int currentSize, int maxSize, int entryCount,
      int maxEntries) {
    return false; // TTL eviction is handled by checking expiration
  }

  @override
  List<String> selectKeysToEvict(
      Map<String, DateTime> keyAccessMap, int count) {
    // No-op for TTL
    return [];
  }
}

/// Example: LRU-based eviction policy
class LRUEvictionPolicy implements EvictionPolicy {
  final int maxEntries;
  LRUEvictionPolicy(this.maxEntries);

  @override
  bool shouldEvict(String key, int currentSize, int maxSize, int entryCount,
      int maxEntries) {
    return entryCount >= maxEntries;
  }

  @override
  List<String> selectKeysToEvict(
      Map<String, DateTime> keyAccessMap, int count) {
    // Evict least recently used keys
    final sorted = keyAccessMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return sorted.take(count).map((e) => e.key).toList();
  }
}
