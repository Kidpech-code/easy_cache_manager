import 'package:flutter_test/flutter_test.dart';
import 'package:easy_cache_manager/src/core/policies/arc_eviction_policy.dart';
import 'package:easy_cache_manager/src/core/policies/lfu_eviction_policy.dart';
import 'package:easy_cache_manager/src/core/policies/hybrid_eviction_policy.dart';

void main() {
  group('ARC Eviction Policy', () {
    test('evicts from t1/t2 and manages ghost lists', () {
      final policy = ARCEvictionPolicy(3);
      policy.onAccess('a');
      policy.onAccess('b');
      policy.onAccess('c');
      // Should fill t1
      expect(policy.t1, containsAll(['a', 'b', 'c']));
      // Access 'a' again, should move to t2
      policy.onAccess('a');
      expect(policy.t2, contains('a'));
      // Add new key to trigger eviction
      policy.onAccess('d');
      expect(policy.t1.length + policy.t2.length <= 3, true);
      // Ghost lists should update
      expect(policy.b1.length + policy.b2.length <= 3, true);
    });
  });

  group('LFU Eviction Policy', () {
    test('evicts least frequently used', () {
      final policy = LFUEvictionPolicy(2);
      policy.recordAccess('x');
      policy.recordAccess('y');
      policy.recordAccess('x'); // x freq = 2, y freq = 1
      final evict = policy.selectKeysToEvict({}, 1);
      expect(evict, ['y']);
    });
  });

  group('Hybrid Eviction Policy', () {
    test('switches between LRU and LFU', () {
      final policy = HybridEvictionPolicy(2);
      policy.recordAccess('m');
      policy.recordAccess('n');
      policy.recordAccess('m'); // m freq = 2, n freq = 1
      final accessMap = {
        'm': DateTime.now().subtract(const Duration(minutes: 2)),
        'n': DateTime.now().subtract(const Duration(minutes: 1)),
      };
      // Debug print frequency and accessMap
      // hitRate < 0.5 (stub), should use LFU
      final evictLFU = policy.selectKeysToEvict(accessMap, 1);
      expect(evictLFU, ['n']);
    });
  });
}
