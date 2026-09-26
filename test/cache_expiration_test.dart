@TestOn('vm')
library;

import 'dart:typed_data';

import 'package:easy_cache_manager/src/core/network/network_info.dart';
import 'package:easy_cache_manager/src/core/storage/hive_cache_storage.dart';
import 'package:easy_cache_manager/src/data/datasources/network_remote_data_source.dart';
import 'package:easy_cache_manager/src/data/repositories/cache_repository_impl.dart';
import 'package:easy_cache_manager/src/data/repositories/network_repository_impl.dart';
import 'package:easy_cache_manager/src/domain/entities/advanced_cache_config.dart';
import 'package:easy_cache_manager/src/domain/usecases/get_bytes_usecase.dart';
import 'package:easy_cache_manager/src/domain/usecases/get_json_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'support/isolated_hive_directory.dart';

class _NetworkStatus implements NetworkInfo {
  _NetworkStatus(this.connected);

  bool connected;

  @override
  Future<bool> get isConnected async => connected;

  @override
  Future<bool> isHostReachable(String host) async => connected;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final hiveDirectory = IsolatedHiveDirectory();
  setUpAll(hiveDirectory.open);
  tearDownAll(hiveDirectory.close);

  late HiveCacheStorage storage;
  late CacheRepositoryImpl cache;

  setUp(() async {
    storage = HiveCacheStorage();
    await storage.initialize();
    await storage.clear();
    cache = CacheRepositoryImpl(hiveCacheStorage: storage);
  });

  tearDown(() async {
    await storage.clear();
    await storage.dispose();
  });

  test('manual JSON and bytes expire at maxAge', () async {
    await cache.store('manual-json', {'value': 1}, maxAge: Duration.zero);
    await cache.storeBytes(
      'manual-bytes',
      Uint8List.fromList([1, 2]),
      maxAge: Duration.zero,
    );
    expect(await storage.getAllKeys(),
        containsAll(['manual-json', 'manual-bytes']));

    expect(await cache.retrieve('manual-json'), isNull);
    expect(await cache.retrieveBytes('manual-bytes'), isNull);
    expect(await storage.getAllKeys(), isEmpty);
  });

  test('HTTP JSON stays available offline after its fresh age', () async {
    final networkStatus = _NetworkStatus(true);
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      return http.Response('{"value":1}', 200);
    });
    addTearDown(client.close);
    final useCase = GetJsonUseCase(
      cacheRepository: cache,
      networkRepository: NetworkRepositoryImpl(
        remoteDataSource: NetworkRemoteDataSourceImpl(client: client),
      ),
      networkInfo: networkStatus,
      config: const AdvancedCacheConfig(
        maxAge: Duration.zero,
        stalePeriod: Duration(hours: 1),
      ),
    );
    const url = 'https://example.test/data';

    expect((await useCase.execute(url)).data, {'value': 1});
    networkStatus.connected = false;
    final offline = await useCase.execute(url);

    expect(offline.data, {'value': 1});
    expect(offline.isFromCache, isTrue);
    expect(requests, 1);
  });

  test('HTTP bytes stay available offline after their fresh age', () async {
    final networkStatus = _NetworkStatus(true);
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      return http.Response.bytes(Uint8List.fromList([7, 8]), 200);
    });
    addTearDown(client.close);
    final useCase = GetBytesUseCase(
      cacheRepository: cache,
      networkRepository: NetworkRepositoryImpl(
        remoteDataSource: NetworkRemoteDataSourceImpl(client: client),
      ),
      networkInfo: networkStatus,
      config: const AdvancedCacheConfig(
        maxAge: Duration.zero,
        stalePeriod: Duration(hours: 1),
      ),
    );
    const url = 'https://example.test/file.bin';

    expect((await useCase.execute(url)).data, [7, 8]);
    networkStatus.connected = false;
    final offline = await useCase.execute(url);

    expect(offline.data, [7, 8]);
    expect(offline.isFromCache, isTrue);
    expect(requests, 1);
  });

  test('legacy entries beyond stale retention are not served offline',
      () async {
    final oldTime = DateTime.now().subtract(const Duration(days: 2));
    const jsonUrl = 'https://example.test/old.json';
    const bytesUrl = 'https://example.test/old.bin';
    await storage.store(
      'json_$jsonUrl',
      {'value': 'old'},
      {'created_at': oldTime.millisecondsSinceEpoch},
    );
    await storage.storeBytes(
      'bytes_$bytesUrl',
      Uint8List.fromList([9]),
      {'created_at': oldTime.millisecondsSinceEpoch},
    );
    final client =
        MockClient((request) async => http.Response('unexpected', 500));
    addTearDown(client.close);
    final repository = NetworkRepositoryImpl(
      remoteDataSource: NetworkRemoteDataSourceImpl(client: client),
    );
    const config = AdvancedCacheConfig(
      maxAge: Duration(hours: 1),
      stalePeriod: Duration(hours: 1),
    );
    final json = GetJsonUseCase(
      cacheRepository: cache,
      networkRepository: repository,
      networkInfo: _NetworkStatus(false),
      config: config,
    );
    final bytes = GetBytesUseCase(
      cacheRepository: cache,
      networkRepository: repository,
      networkInfo: _NetworkStatus(false),
      config: config,
    );

    expect((await json.execute(jsonUrl)).isFailure, isTrue);
    expect((await bytes.execute(bytesUrl)).isFailure, isTrue);
    expect(await storage.getAllKeys(), isEmpty);
  });
}
