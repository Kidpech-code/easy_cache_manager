import '../../domain/entities/cache_entry.dart';

/// Base interface for cache eviction policies
abstract class EvictionPolicy {
  /// Policy name for identification
  String get name;

  /// Determines which entries should be evicted to free up space
  /// Returns a list of cache keys to remove
  List<String> selectForEviction(
      List<CacheEntry> entries, int targetSizeReduction);

  /// Updates policy state when an entry is accessed
  void onAccess(String key, CacheEntry entry) {}

  /// Updates policy state when an entry is stored
  void onStore(String key, CacheEntry entry) {}

  /// Updates policy state when an entry is removed
  void onRemove(String key) {}

  /// Resets policy state
  void reset() {}
}

/// Least Recently Used (LRU) eviction policy
class LRUEvictionPolicy implements EvictionPolicy {
  final Map<String, DateTime> _accessTimes = {};

  @override
  String get name => 'LRU';

  @override
  List<String> selectForEviction(
      List<CacheEntry> entries, int targetSizeReduction) {
    final sortedEntries = List<CacheEntry>.from(entries);

    // Sort by last access time (oldest first)
    sortedEntries.sort((a, b) {
      final aTime = _accessTimes[a.key] ?? a.createdAt;
      final bTime = _accessTimes[b.key] ?? b.createdAt;
      return aTime.compareTo(bTime);
    });

    final toEvict = <String>[];
    var currentReduction = 0;

    for (final entry in sortedEntries) {
      if (currentReduction >= targetSizeReduction) break;

      toEvict.add(entry.key);
      currentReduction += entry.sizeInBytes;
    }

    return toEvict;
  }

  @override
  void onAccess(String key, CacheEntry entry) {
    _accessTimes[key] = DateTime.now();
  }

  @override
  void onStore(String key, CacheEntry entry) {
    _accessTimes[key] = DateTime.now();
  }

  @override
  void onRemove(String key) {
    _accessTimes.remove(key);
  }

  @override
  void reset() {
    _accessTimes.clear();
  }
}

/// Least Frequently Used (LFU) eviction policy
class LFUEvictionPolicy implements EvictionPolicy {
  final Map<String, int> _accessCounts = {};

  @override
  String get name => 'LFU';

  @override
  List<String> selectForEviction(
      List<CacheEntry> entries, int targetSizeReduction) {
    final sortedEntries = List<CacheEntry>.from(entries);

    // Sort by access count (least frequently used first)
    sortedEntries.sort((a, b) {
      final aCount = _accessCounts[a.key] ?? 0;
      final bCount = _accessCounts[b.key] ?? 0;

      // If same count, use creation time (older first)
      if (aCount == bCount) {
        return a.createdAt.compareTo(b.createdAt);
      }

      return aCount.compareTo(bCount);
    });

    final toEvict = <String>[];
    var currentReduction = 0;

    for (final entry in sortedEntries) {
      if (currentReduction >= targetSizeReduction) break;

      toEvict.add(entry.key);
      currentReduction += entry.sizeInBytes;
    }

    return toEvict;
  }

  @override
  void onAccess(String key, CacheEntry entry) {
    _accessCounts[key] = (_accessCounts[key] ?? 0) + 1;
  }

  @override
  void onStore(String key, CacheEntry entry) {
    _accessCounts[key] = (_accessCounts[key] ?? 0) + 1;
  }

  @override
  void onRemove(String key) {
    _accessCounts.remove(key);
  }

  @override
  void reset() {
    _accessCounts.clear();
  }
}

/// First In, First Out (FIFO) eviction policy
class FIFOEvictionPolicy implements EvictionPolicy {
  @override
  String get name => 'FIFO';

  @override
  List<String> selectForEviction(
      List<CacheEntry> entries, int targetSizeReduction) {
    final sortedEntries = List<CacheEntry>.from(entries);

    // Sort by creation time (oldest first)
    sortedEntries.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final toEvict = <String>[];
    var currentReduction = 0;

    for (final entry in sortedEntries) {
      if (currentReduction >= targetSizeReduction) break;

      toEvict.add(entry.key);
      currentReduction += entry.sizeInBytes;
    }

    return toEvict;
  }

  @override
  void onAccess(String key, CacheEntry entry) {}

  @override
  void onStore(String key, CacheEntry entry) {}

  @override
  void onRemove(String key) {}

  @override
  void reset() {}
}

/// Size-based eviction policy (largest files first)
class SizeBasedEvictionPolicy implements EvictionPolicy {
  @override
  String get name => 'Size-based';

  @override
  List<String> selectForEviction(
      List<CacheEntry> entries, int targetSizeReduction) {
    final sortedEntries = List<CacheEntry>.from(entries);

    // Sort by size (largest first)
    sortedEntries.sort((a, b) => b.sizeInBytes.compareTo(a.sizeInBytes));

    final toEvict = <String>[];
    var currentReduction = 0;

    for (final entry in sortedEntries) {
      if (currentReduction >= targetSizeReduction) break;

      toEvict.add(entry.key);
      currentReduction += entry.sizeInBytes;
    }

    return toEvict;
  }

  @override
  void onAccess(String key, CacheEntry entry) {}

  @override
  void onStore(String key, CacheEntry entry) {}

  @override
  void onRemove(String key) {}

  @override
  void reset() {}
}

/// Time-to-Live (TTL) based eviction policy
class TTLEvictionPolicy implements EvictionPolicy {
  @override
  String get name => 'TTL';

  @override
  List<String> selectForEviction(
      List<CacheEntry> entries, int targetSizeReduction) {
    final now = DateTime.now();
    final expiredEntries = <CacheEntry>[];
    final nonExpiredEntries = <CacheEntry>[];

    // Separate expired and non-expired entries
    for (final entry in entries) {
      if (entry.expiresAt != null && entry.expiresAt!.isBefore(now)) {
        expiredEntries.add(entry);
      } else {
        nonExpiredEntries.add(entry);
      }
    }

    final toEvict = <String>[];
    var currentReduction = 0;

    // First, evict expired entries
    for (final entry in expiredEntries) {
      if (currentReduction >= targetSizeReduction) break;

      toEvict.add(entry.key);
      currentReduction += entry.sizeInBytes;
    }

    // If still need more space, evict by expiration time (closest to expiry first)
    if (currentReduction < targetSizeReduction) {
      final sortedNonExpired = List<CacheEntry>.from(nonExpiredEntries);

      sortedNonExpired.sort((a, b) {
        // No expiry time = lowest priority
        if (a.expiresAt == null && b.expiresAt == null) {
          return a.createdAt.compareTo(b.createdAt);
        } else if (a.expiresAt == null) {
          return -1;
        } else if (b.expiresAt == null) {
          return 1;
        }

        return a.expiresAt!.compareTo(b.expiresAt!);
      });

      for (final entry in sortedNonExpired) {
        if (currentReduction >= targetSizeReduction) break;

        toEvict.add(entry.key);
        currentReduction += entry.sizeInBytes;
      }
    }

    return toEvict;
  }

  @override
  void onAccess(String key, CacheEntry entry) {}

  @override
  void onStore(String key, CacheEntry entry) {}

  @override
  void onRemove(String key) {}

  @override
  void reset() {}
}

/// Random eviction policy
class RandomEvictionPolicy implements EvictionPolicy {
  @override
  String get name => 'Random';

  @override
  List<String> selectForEviction(
      List<CacheEntry> entries, int targetSizeReduction) {
    final shuffledEntries = List<CacheEntry>.from(entries);
    shuffledEntries.shuffle();

    final toEvict = <String>[];
    var currentReduction = 0;

    for (final entry in shuffledEntries) {
      if (currentReduction >= targetSizeReduction) break;

      toEvict.add(entry.key);
      currentReduction += entry.sizeInBytes;
    }

    return toEvict;
  }

  @override
  void onAccess(String key, CacheEntry entry) {}

  @override
  void onStore(String key, CacheEntry entry) {}

  @override
  void onRemove(String key) {}

  @override
  void reset() {}
}

/// Composite eviction policy that combines multiple strategies
class CompositeEvictionPolicy implements EvictionPolicy {
  final List<EvictionPolicy> policies;
  final String compositeName;

  CompositeEvictionPolicy(
      {required this.policies, this.compositeName = 'Composite'});

  @override
  String get name => compositeName;

  @override
  List<String> selectForEviction(
      List<CacheEntry> entries, int targetSizeReduction) {
    final allCandidates = <String>{};
    var remainingReduction = targetSizeReduction;

    // Apply each policy in order
    for (final policy in policies) {
      if (remainingReduction <= 0) break;

      final candidates = policy.selectForEviction(entries, remainingReduction);
      allCandidates.addAll(candidates);

      // Calculate actual reduction from these candidates
      var reduction = 0;
      for (final key in candidates) {
        final entry = entries.firstWhere((e) => e.key == key);
        reduction += entry.sizeInBytes;
      }

      remainingReduction -= reduction;
    }

    return allCandidates.toList();
  }

  @override
  void onAccess(String key, CacheEntry entry) {
    for (final policy in policies) {
      policy.onAccess(key, entry);
    }
  }

  @override
  void onStore(String key, CacheEntry entry) {
    for (final policy in policies) {
      policy.onStore(key, entry);
    }
  }

  @override
  void onRemove(String key) {
    for (final policy in policies) {
      policy.onRemove(key);
    }
  }

  @override
  void reset() {
    for (final policy in policies) {
      policy.reset();
    }
  }
}

/// Factory for creating eviction policies
class EvictionPolicyFactory {
  static EvictionPolicy create(String type) {
    switch (type.toLowerCase()) {
      case 'lru':
        return LRUEvictionPolicy();
      case 'lfu':
        return LFUEvictionPolicy();
      case 'fifo':
        return FIFOEvictionPolicy();
      case 'size':
      case 'size-based':
        return SizeBasedEvictionPolicy();
      case 'ttl':
        return TTLEvictionPolicy();
      case 'random':
        return RandomEvictionPolicy();
      default:
        return LRUEvictionPolicy(); // Default to LRU
    }
  }

  /// Creates a composite policy combining TTL + LRU (recommended)
  static EvictionPolicy createRecommended() {
    return CompositeEvictionPolicy(
        policies: [TTLEvictionPolicy(), LRUEvictionPolicy()],
        compositeName: 'TTL+LRU');
  }

  /// Creates a performance-focused composite policy
  static EvictionPolicy createPerformanceFocused() {
    return CompositeEvictionPolicy(policies: [
      TTLEvictionPolicy(),
      SizeBasedEvictionPolicy(),
      LRUEvictionPolicy()
    ], compositeName: 'Performance');
  }

  /// Creates a memory-focused composite policy
  static EvictionPolicy createMemoryFocused() {
    return CompositeEvictionPolicy(
        policies: [SizeBasedEvictionPolicy(), LFUEvictionPolicy()],
        compositeName: 'Memory-focused');
  }

  /// Lists all available eviction policy types
  static List<String> getAvailableTypes() {
    return ['lru', 'lfu', 'fifo', 'size-based', 'ttl', 'random'];
  }
}
