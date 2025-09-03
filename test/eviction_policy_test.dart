import 'package:flutter_test/flutter_test.dart';
import 'package:easy_cache_manager/src/core/policies/eviction_policy.dart';

void main() {
  group('LRU Eviction Policy', () {
    test('should evict when max entries reached', () {
      final policy = LRUEvictionPolicy(3);
      expect(policy.shouldEvict('k', 0, 0, 3, 3), true);
      expect(policy.shouldEvict('k', 0, 0, 2, 3), false);
    });

    test('selectKeysToEvict returns least recently used', () {
      final now = DateTime.now();
      // ใช้ const Duration ตาม lint best practices
      final map = {
        'a': now.subtract(const Duration(minutes: 3)),
        'b': now.subtract(const Duration(minutes: 2)),
        'c': now.subtract(const Duration(minutes: 1)),
      };
      final policy = LRUEvictionPolicy(2);
      final evict = policy.selectKeysToEvict(map, 2);
      // ตรวจสอบว่าเลือก key ที่ least recently used ตามลำดับเวลา
      expect(evict, ['a', 'b']);
    });
  });
}
