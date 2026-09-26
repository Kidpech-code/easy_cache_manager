@TestOn('vm')
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:easy_cache_manager/src/core/network/network_info.dart';
import 'package:easy_cache_manager/src/core/storage/hive_cache_storage.dart';
import 'package:easy_cache_manager/src/core/utils/cache_utils.dart';
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

class _ConnectedNetwork implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;

  @override
  Future<bool> isHostReachable(String host) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final hiveDirectory = IsolatedHiveDirectory();
  setUpAll(hiveDirectory.open);
  tearDownAll(hiveDirectory.close);

  test('public key helper hashes header values and ignores header name case',
      () {
    const url = 'https://example.test/account';
    final lower = CacheUtils.generateCacheKey(
      url,
      headers: {'authorization': 'Bearer private-token'},
    );
    final upper = CacheUtils.generateCacheKey(
      url,
      headers: {'Authorization': 'Bearer private-token'},
    );

    expect(lower, upper);
    expect(lower, isNot(contains('private-token')));
    expect(lower, isNot(CacheUtils.generateCacheKey(url)));
  });

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

  test('JSON cache separates authorization and never persists the token',
      () async {
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      return http.Response(
        jsonEncode({'account': request.headers['authorization']}),
        200,
      );
    });
    addTearDown(client.close);
    final useCase = GetJsonUseCase(
      cacheRepository: cache,
      networkRepository: NetworkRepositoryImpl(
        remoteDataSource: NetworkRemoteDataSourceImpl(client: client),
      ),
      networkInfo: _ConnectedNetwork(),
      config: const AdvancedCacheConfig(autoCleanup: false),
    );
    const url = 'https://example.test/account';

    final alice = await useCase.execute(
      url,
      headers: {'Authorization': 'Bearer alice-secret'},
    );
    final bob = await useCase.execute(
      url,
      headers: {'authorization': 'Bearer bob-secret'},
    );
    final aliceAgain = await useCase.execute(
      url,
      headers: {'authorization': 'Bearer alice-secret'},
    );

    expect(alice.data, {'account': 'Bearer alice-secret'});
    expect(bob.data, {'account': 'Bearer bob-secret'});
    expect(aliceAgain.data, {'account': 'Bearer alice-secret'});
    expect(aliceAgain.isFromCache, isTrue);
    expect(requests, 2);
    final keys = await storage.getAllKeys();
    expect(keys.join(), isNot(contains('secret')));
    for (final key in keys) {
      expect((await storage.retrieve(key))?.headers, isNull);
    }
  });

  test('binary cache separates responses for different request headers',
      () async {
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      return http.Response.bytes(
        Uint8List.fromList(utf8.encode(request.headers['x-tenant']!)),
        200,
      );
    });
    addTearDown(client.close);
    final useCase = GetBytesUseCase(
      cacheRepository: cache,
      networkRepository: NetworkRepositoryImpl(
        remoteDataSource: NetworkRemoteDataSourceImpl(client: client),
      ),
      networkInfo: _ConnectedNetwork(),
      config: const AdvancedCacheConfig(autoCleanup: false),
    );
    const url = 'https://example.test/avatar.png';

    final tenantA = await useCase.execute(url, headers: {'X-Tenant': 'A'});
    final tenantB = await useCase.execute(url, headers: {'x-tenant': 'B'});
    final tenantAAgain = await useCase.execute(url, headers: {'x-tenant': 'A'});

    expect(utf8.decode(tenantA.data!), 'A');
    expect(utf8.decode(tenantB.data!), 'B');
    expect(utf8.decode(tenantAAgain.data!), 'A');
    expect(tenantAAgain.isFromCache, isTrue);
    expect(requests, 2);
  });

  test('anonymous JSON request discards a legacy authenticated entry',
      () async {
    const url = 'https://example.test/account';
    await cache.store(
      'json_$url',
      {'account': 'private'},
      headers: {'Authorization': 'Bearer legacy-secret'},
    );
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      return http.Response('{"account":"public"}', 200);
    });
    addTearDown(client.close);
    final useCase = GetJsonUseCase(
      cacheRepository: cache,
      networkRepository: NetworkRepositoryImpl(
        remoteDataSource: NetworkRemoteDataSourceImpl(client: client),
      ),
      networkInfo: _ConnectedNetwork(),
      config: const AdvancedCacheConfig(autoCleanup: false),
    );

    final result = await useCase.execute(url);

    expect(result.data, {'account': 'public'});
    expect(result.isFromCache, isFalse);
    expect(requests, 1);
    expect((await cache.retrieve('json_$url'))?.headers, isNull);
  });

  test('anonymous binary request discards a legacy authenticated entry',
      () async {
    const url = 'https://example.test/avatar.png';
    await cache.storeBytes(
      'bytes_$url',
      Uint8List.fromList([1]),
      headers: {'Authorization': 'Bearer legacy-secret'},
    );
    var requests = 0;
    final client = MockClient((request) async {
      requests++;
      return http.Response.bytes(Uint8List.fromList([2]), 200);
    });
    addTearDown(client.close);
    final useCase = GetBytesUseCase(
      cacheRepository: cache,
      networkRepository: NetworkRepositoryImpl(
        remoteDataSource: NetworkRemoteDataSourceImpl(client: client),
      ),
      networkInfo: _ConnectedNetwork(),
      config: const AdvancedCacheConfig(autoCleanup: false),
    );

    final result = await useCase.execute(url);

    expect(result.data, [2]);
    expect(result.isFromCache, isFalse);
    expect(requests, 1);
    expect((await cache.retrieve('bytes_$url'))?.headers, isNull);
  });

  test('authenticated requests remove legacy entries containing credentials',
      () async {
    const jsonUrl = 'https://example.test/account';
    const bytesUrl = 'https://example.test/avatar.png';
    await cache.store(
      'json_$jsonUrl',
      {'account': 'old'},
      headers: {'Authorization': 'Bearer old-secret'},
    );
    await cache.storeBytes(
      'bytes_$bytesUrl',
      Uint8List.fromList([1]),
      headers: {'Authorization': 'Bearer old-secret'},
    );
    final client = MockClient((request) async {
      if (request.url.path == '/account') {
        return http.Response('{"account":"new"}', 200);
      }
      return http.Response.bytes(Uint8List.fromList([2]), 200);
    });
    addTearDown(client.close);
    final network = NetworkRepositoryImpl(
      remoteDataSource: NetworkRemoteDataSourceImpl(client: client),
    );
    const config = AdvancedCacheConfig(autoCleanup: false);
    final json = GetJsonUseCase(
      cacheRepository: cache,
      networkRepository: network,
      networkInfo: _ConnectedNetwork(),
      config: config,
    );
    final bytes = GetBytesUseCase(
      cacheRepository: cache,
      networkRepository: network,
      networkInfo: _ConnectedNetwork(),
      config: config,
    );

    expect(
      (await json.execute(jsonUrl, headers: {'Authorization': 'Bearer new'}))
          .data,
      {'account': 'new'},
    );
    expect(
      (await bytes.execute(bytesUrl, headers: {'Authorization': 'Bearer new'}))
          .data,
      [2],
    );
    expect(await cache.retrieve('json_$jsonUrl'), isNull);
    expect(await cache.retrieve('bytes_$bytesUrl'), isNull);
  });
}
