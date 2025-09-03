import 'eviction_policy.dart';

/// ARC (Adaptive Replacement Cache) Eviction Policy
class ARCEvictionPolicy implements EvictionPolicy {
  final int maxEntries;
  final List<String> t1 = [];
  final List<String> t2 = [];
  final List<String> b1 = [];
  final List<String> b2 = [];
  int p = 0; // target size for t1

  ARCEvictionPolicy(this.maxEntries);

  @override
  bool shouldEvict(String key, int currentSize, int maxSize, int entryCount,
      int maxEntries) {
    return entryCount >= maxEntries;
  }

  @override
  List<String> selectKeysToEvict(
      Map<String, DateTime> keyAccessMap, int count) {
    // Evict from t1 or t2 based on ARC logic
    final evict = <String>[];
    while (evict.length < count && (t1.isNotEmpty || t2.isNotEmpty)) {
      if (t1.length > p) {
        evict.add(t1.removeAt(0));
      } else if (t2.isNotEmpty) {
        evict.add(t2.removeAt(0));
      }
    }
    return evict;
  }

  void onAccess(String key) {
    // ARC algorithm: move between t1/t2/b1/b2
    if (t1.contains(key)) {
      t1.remove(key);
      t2.add(key);
    } else if (t2.contains(key)) {
      // already frequent, move to MRU
      t2.remove(key);
      t2.add(key);
    } else if (b1.contains(key)) {
      // Increase p, move key to t2
      p = (p + 1).clamp(0, maxEntries);
      b1.remove(key);
      t2.add(key);
    } else if (b2.contains(key)) {
      // Decrease p, move key to t2
      p = (p - 1).clamp(0, maxEntries);
      b2.remove(key);
      t2.add(key);
    } else {
      // New key, add to t1
      t1.add(key);
      if (t1.length + t2.length > maxEntries) {
        if (t1.length > p) {
          final old = t1.removeAt(0);
          b1.add(old);
        } else {
          final old = t2.removeAt(0);
          b2.add(old);
        }
      }
    }
    // Limit ghost lists
    if (b1.length > maxEntries) b1.removeAt(0);
    if (b2.length > maxEntries) b2.removeAt(0);
  }
}
