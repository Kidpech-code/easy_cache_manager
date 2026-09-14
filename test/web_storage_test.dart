@TestOn('browser')
library;

import 'dart:typed_data';
import 'package:easy_cache_manager/easy_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('simple storage persists JSON and bytes across close and reopen',
      () async {
    final storage = SimpleCacheStorage();
    await storage.init();
    addTearDown(() async {
      await storage.clear();
      await storage.close();
    });
    await storage.clear();
    await storage.setJson('profile', {'name': 'ทดสอบ', 'count': 7});
    await storage.setBytes('photo', Uint8List.fromList([0, 127, 255]));
    await storage.close();
    await storage.init();
    expect(await storage.getJson('profile'), {'name': 'ทดสอบ', 'count': 7});
    expect(await storage.getBytes('photo'), [0, 127, 255]);
  });

  test('Hive storage round-trips JSON and binary data on the web', () async {
    final storage = HiveCacheStorage();
    await storage.initialize();
    addTearDown(() async {
      await storage.clear();
      await storage.dispose();
    });
    await storage.store('record', {'value': 42}, {});
    await storage.storeBytes('binary', Uint8List.fromList([1, 2, 255]), {});
    expect((await storage.retrieve('record'))?.data, {'value': 42});
    expect(await storage.retrieveBytes('binary'), [1, 2, 255]);
  });

  test('web NetworkInfo uses HTTP results instead of assuming connectivity',
      () async {
    final client = MockClient((request) async {
      expect(request.method, 'HEAD');
      return http.Response(
          '', request.url.host == 'reachable.example' ? 204 : 503);
    });
    addTearDown(client.close);
    final network = NetworkInfo(httpClient: client);
    expect(await network.isHostReachable('reachable.example'), isTrue);
    expect(
        await network.isHostReachable('https://unreachable.example'), isFalse);
    expect(await network.isConnected, isFalse);
  });
}
