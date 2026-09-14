@TestOn('vm')
library;

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:easy_cache_manager/src/data/models/hive_cache_entry.dart';
import 'package:easy_cache_manager/src/data/models/hive_cache_stats.dart';

void main() {
  test('reads adapter records written by Hive 2.2.3 without migration',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('hive2_compatibility_');
    addTearDown(() async {
      await Hive.close();
      await directory.delete(recursive: true);
    });
    await File('test/fixtures/hive2/legacy.hive')
        .copy('${directory.path}/legacy.hive');
    Hive.init(directory.path);
    Hive.registerAdapter(HiveCacheEntryAdapter());
    Hive.registerAdapter(HiveCacheStatsAdapter());
    final box = await Hive.openBox<dynamic>('legacy');
    final entry = box.get('entry') as HiveCacheEntry;
    expect(entry.key, 'legacy-key');
    expect(entry.data, {'name': 'ทดสอบ'});
    expect(entry.createdAt, DateTime.utc(2025, 1, 2));
    final stats = box.get('stats') as HiveCacheStats;
    expect(stats.totalEntries, 1);
    expect(stats.totalSizeInBytes, 42);
    await box.put('ce-write', 'ok');
    await box.close();
    final reopened = await Hive.openBox<dynamic>('legacy');
    expect(reopened.get('ce-write'), 'ok');
  });
}
