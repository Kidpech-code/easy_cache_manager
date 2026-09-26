@TestOn('vm')
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:easy_cache_manager/easy_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

import 'support/isolated_hive_directory.dart';

class _DelayedStorage extends HiveCacheStorage {
  final Completer<void> _gate = Completer<void>();

  void release() => _gate.complete();

  @override
  Future<void> initialize() async {
    await _gate.future;
    await super.initialize();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final hiveDirectory = IsolatedHiveDirectory();
  setUpAll(hiveDirectory.open);
  tearDownAll(hiveDirectory.close);

  test('CacheManager waits for storage before reporting a successful save',
      () async {
    final storage = _DelayedStorage();
    final manager = CacheManager(
      config: const AdvancedCacheConfig(autoCleanup: false),
      hiveCacheStorage: storage,
    );
    addTearDown(() async {
      manager.dispose();
      await storage.clear();
      await storage.dispose();
    });

    final save = manager.save('manual', {'value': 1});
    await Future<void>.delayed(Duration.zero);
    storage.release();
    await save;

    expect((await storage.retrieve('manual'))?.data, {'value': 1});
    expect(await manager.contains('manual'), isTrue);
  });

  test('a second storage instance keeps working after the first closes',
      () async {
    final first = HiveCacheStorage();
    await first.initialize();
    await first.clear();
    final second = HiveCacheStorage();
    await second.initialize();
    addTearDown(() async {
      await second.clear();
      await second.dispose();
      await first.dispose();
    });

    await second.store('shared', {'value': 1}, {});
    expect((await second.retrieve('shared'))?.data, {'value': 1});

    await first.dispose();
    await second.store('still-open', {'value': 2}, {});
    expect((await second.retrieve('still-open'))?.data, {'value': 2});
  });

  test('opens boxes again after Hive is closed externally', () async {
    final first = HiveCacheStorage();
    await first.initialize();
    await Hive.close();

    final second = HiveCacheStorage();
    await second.initialize();
    addTearDown(() async {
      await second.clear();
      await second.dispose();
      await first.dispose();
    });

    await second.store('reopened', {'value': 3}, {});
    expect((await second.retrieve('reopened'))?.data, {'value': 3});
  });

  test('storage reports failed writes instead of silently succeeding',
      () async {
    final storage = HiveCacheStorage();

    await expectLater(
        storage.store('json', {'value': 1}, {}), throwsStateError);
    await expectLater(
      storage.storeBytes('bytes', Uint8List.fromList([1]), {}),
      throwsStateError,
    );
  });
}
