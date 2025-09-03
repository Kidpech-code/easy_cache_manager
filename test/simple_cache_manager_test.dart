/// Tests for SimpleCacheManager complete implementation
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:easy_cache_manager/easy_cache_manager.dart';
import 'package:easy_cache_manager/src/data/datasources/network_remote_data_source.dart';
import 'mocks/mock_hive_cache_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';

void main() {
  group('SimpleCacheManager Complete Implementation Tests', () {
    setUp(() async {
      // Initialize with mocked dependencies to avoid plugin/timeouts in tests
      final mockHive = MockHiveCacheStorage();

      // Lightweight fake HTTP client with pre-programmed responses
      final fakeClient = _FakeHttpClient(
        getHandlers: {
          Uri.parse('https://example.com/api/data'): () async =>
              http.Response('{"ok":true}', 200),
        },
        headHandlers: {
          Uri.parse('https://example.com/api/data'): () async =>
              http.Response('', 200),
        },
      );

      final mockRemote = NetworkRemoteDataSourceImpl(client: fakeClient);

      // NetworkInfo that always reports connected to avoid DNS checks in tests
      final alwaysConnected = _AlwaysConnectedNetworkInfo();

      await SimpleCacheManager.init(
        hiveCacheStorage: mockHive,
        remoteDataSource: mockRemote,
        networkInfo: alwaysConnected,
      );
    });

    tearDown(() async {
      // Clean up after each test
      try {
        await SimpleCacheManager.clearAll();
        await SimpleCacheManager.close();
      } catch (e) {
        // Ignore cleanup errors
      }
    });

    group('Key-Value Storage Tests', () {
      test('should save and retrieve JSON data', () async {
        const key = 'user_profile';
        final jsonData = {
          'id': 123,
          'name': 'John Doe',
          'email': 'john@example.com',
          'preferences': {
            'theme': 'dark',
            'notifications': true,
          },
        };

        // Save JSON
        await SimpleCacheManager.saveJson(key, jsonData);

        // Retrieve JSON
        final retrieved = await SimpleCacheManager.getJson(key);
        expect(retrieved, isNotNull);
        expect(retrieved!['id'], equals(123));
        expect(retrieved['name'], equals('John Doe'));
        expect(retrieved['email'], equals('john@example.com'));
        expect(retrieved['preferences']['theme'], equals('dark'));
        expect(retrieved['preferences']['notifications'], equals(true));
      });

      test('should save and retrieve string data', () async {
        const key = 'username';
        const value = 'john_doe_2024';

        await SimpleCacheManager.saveString(key, value);
        final retrieved = await SimpleCacheManager.getString(key);

        expect(retrieved, equals(value));
      });

      test('should save and retrieve integer data', () async {
        const key = 'user_age';
        const value = 25;

        await SimpleCacheManager.saveInt(key, value);
        final retrieved = await SimpleCacheManager.getInt(key);

        expect(retrieved, equals(value));
      });

      test('should save and retrieve boolean data', () async {
        const key = 'is_premium';
        const value = true;

        await SimpleCacheManager.saveBool(key, value);
        final retrieved = await SimpleCacheManager.getBool(key);

        expect(retrieved, equals(value));
      });

      test('should save and retrieve binary data', () async {
        const key = 'avatar_image';
        final value = Uint8List.fromList([1, 2, 3, 4, 5, 255, 0, 128]);

        await SimpleCacheManager.saveBytes(key, value);
        final retrieved = await SimpleCacheManager.getBytes(key);

        expect(retrieved, isNotNull);
        expect(retrieved!.length, equals(value.length));
        for (int i = 0; i < value.length; i++) {
          expect(retrieved[i], equals(value[i]));
        }
      });

      test('should return null for non-existent keys', () async {
        final jsonResult = await SimpleCacheManager.getJson('nonexistent');
        final stringResult = await SimpleCacheManager.getString('nonexistent');
        final intResult = await SimpleCacheManager.getInt('nonexistent');
        final boolResult = await SimpleCacheManager.getBool('nonexistent');
        final bytesResult = await SimpleCacheManager.getBytes('nonexistent');

        expect(jsonResult, isNull);
        expect(stringResult, isNull);
        expect(intResult, isNull);
        expect(boolResult, isNull);
        expect(bytesResult, isNull);
      });
    });

    group('Utility Methods Tests', () {
      test('should check key existence correctly', () async {
        const key = 'test_key';

        // Should not exist initially
        expect(await SimpleCacheManager.contains(key), isFalse);

        // Should exist after saving
        await SimpleCacheManager.saveString(key, 'test_value');
        expect(await SimpleCacheManager.contains(key), isTrue);

        // Should not exist after removal
        await SimpleCacheManager.remove(key);
        expect(await SimpleCacheManager.contains(key), isFalse);
      });

      test('should remove data by key', () async {
        const key = 'remove_test';
        final value = {'data': 'to_be_removed'};

        // Save and verify
        await SimpleCacheManager.saveJson(key, value);
        expect(await SimpleCacheManager.getJson(key), isNotNull);

        // Remove and verify
        await SimpleCacheManager.remove(key);
        expect(await SimpleCacheManager.getJson(key), isNull);
      });

      test('should get all keys correctly', () async {
        // Save multiple keys
        await SimpleCacheManager.saveString('key1', 'value1');
        await SimpleCacheManager.saveInt('key2', 42);
        await SimpleCacheManager.saveBool('key3', false);

        final keys = await SimpleCacheManager.getAllKeys();

        expect(keys.length, equals(3));
        expect(keys.contains('key1'), isTrue);
        expect(keys.contains('key2'), isTrue);
        expect(keys.contains('key3'), isTrue);
      });

      test('should provide storage statistics', () async {
        // Save some data
        await SimpleCacheManager.saveString('str1', 'Hello World');
        await SimpleCacheManager.saveInt('int1', 123);
        await SimpleCacheManager.saveBool('bool1', true);
        await SimpleCacheManager.saveJson('json1', {'key': 'value'});

        final stats = await SimpleCacheManager.getStats();

        expect(stats['totalEntries'], greaterThan(0));
        expect(stats['stringEntries'], equals(1));
        expect(stats['intEntries'], equals(1));
        expect(stats['boolEntries'], equals(1));
        expect(stats['jsonEntries'], equals(1));
        expect(stats['approximateSizeBytes'], greaterThan(0));
        expect(stats['approximateSizeMB'], isA<String>());
      });

      test('should clear key-value storage only', () async {
        // Save some key-value data
        await SimpleCacheManager.saveString('test1', 'value1');
        await SimpleCacheManager.saveJson('test2', {'key': 'value'});

        // Verify data exists
        expect(await SimpleCacheManager.getString('test1'), equals('value1'));
        expect(await SimpleCacheManager.getJson('test2'), isNotNull);

        // Clear key-value storage
        await SimpleCacheManager.clearKeyValueStorage();

        // Verify data is gone
        expect(await SimpleCacheManager.getString('test1'), isNull);
        expect(await SimpleCacheManager.getJson('test2'), isNull);
      });
    });

    group('URL-Based Caching Tests', () {
      test('should cache and retrieve JSON from URL (mocked)', () async {
        final data = await SimpleCacheManager.cacheJsonFromUrl(
            'https://example.com/api/data');
        expect(data['ok'], isTrue);
      });

      test('should cache and retrieve image from URL (mocked)', () async {
        // Mock bytes response using fake client
        final fakeClient = _FakeHttpClient(
          getHandlers: {
            Uri.parse('https://example.com/image.jpg'): () async =>
                http.Response.bytes(List.filled(16, 1), 200),
          },
        );
        final mockRemote = NetworkRemoteDataSourceImpl(client: fakeClient);

        // Re-init with mocked byte client and connected network info
        await SimpleCacheManager.close();
        await SimpleCacheManager.init(
          hiveCacheStorage: MockHiveCacheStorage(),
          remoteDataSource: mockRemote,
          networkInfo: _AlwaysConnectedNetworkInfo(),
        );

        await SimpleCacheManager.cacheImage('https://example.com/image.jpg');
        final img =
            await SimpleCacheManager.getImage('https://example.com/image.jpg');
        expect(img, isNotNull);
        expect(img!.length, greaterThan(0));
      });
    });

    group('Error Handling Tests', () {
      test('should throw error when not initialized', () async {
        // Close the manager
        await SimpleCacheManager.close();

        // Try to use methods - should throw
        expect(() => SimpleCacheManager.saveString('test', 'value'),
            throwsA(isA<StateError>()));
        expect(() => SimpleCacheManager.getString('test'),
            throwsA(isA<StateError>()));
        expect(() => SimpleCacheManager.instance, throwsA(isA<StateError>()));
      });

      test('should handle malformed JSON gracefully', () async {
        // This would test JSON parsing errors
        // The implementation should handle this gracefully by returning null
        const key = 'malformed_json';

        // Save some data first
        await SimpleCacheManager.saveString(key, 'not_json');

        // Try to retrieve as JSON - should return null due to parsing error
        final result = await SimpleCacheManager.getJson('malformed_key');
        expect(result, isNull);
      });
    });

    group('Multiple Data Types for Same Key Tests', () {
      test('should handle different data types with same key', () async {
        const key = 'multi_type_key';

        // Save different types with same key (they should be stored separately)
        await SimpleCacheManager.saveString(key, 'string_value');
        await SimpleCacheManager.saveInt(key, 42);
        await SimpleCacheManager.saveBool(key, true);

        // Each type should retrieve its own value
        expect(await SimpleCacheManager.getString(key), equals('string_value'));
        expect(await SimpleCacheManager.getInt(key), equals(42));
        expect(await SimpleCacheManager.getBool(key), equals(true));

        // Key should exist
        expect(await SimpleCacheManager.contains(key), isTrue);

        // Remove should remove all types
        await SimpleCacheManager.remove(key);
        expect(await SimpleCacheManager.getString(key), isNull);
        expect(await SimpleCacheManager.getInt(key), isNull);
        expect(await SimpleCacheManager.getBool(key), isNull);
        expect(await SimpleCacheManager.contains(key), isFalse);
      });
    });

    group('Performance and Large Data Tests', () {
      test('should handle large JSON objects', () async {
        const key = 'large_json';

        // Create a large JSON object
        final largeJson = <String, dynamic>{};
        for (int i = 0; i < 1000; i++) {
          largeJson['item_$i'] = {
            'id': i,
            'name': 'Item $i',
            'description':
                'This is item number $i with some longer text to make it bigger',
            'tags': ['tag1', 'tag2', 'tag3'],
            'metadata': {
              'created': '2024-01-$i',
              'updated': '2024-02-$i',
              'version': i % 10,
            }
          };
        }

        // Save and retrieve
        await SimpleCacheManager.saveJson(key, largeJson);
        final retrieved = await SimpleCacheManager.getJson(key);

        expect(retrieved, isNotNull);
        expect(retrieved!.length, equals(1000));
        expect(retrieved['item_0']['id'], equals(0));
        expect(retrieved['item_999']['id'], equals(999));
      });

      test('should handle binary data efficiently', () async {
        const key = 'large_binary';

        // Create large binary data (1MB)
        final largeData = Uint8List(1024 * 1024);
        for (int i = 0; i < largeData.length; i++) {
          largeData[i] = i % 256;
        }

        // Save and retrieve
        await SimpleCacheManager.saveBytes(key, largeData);
        final retrieved = await SimpleCacheManager.getBytes(key);

        expect(retrieved, isNotNull);
        expect(retrieved!.length, equals(largeData.length));

        // Verify some random samples
        expect(retrieved[0], equals(0));
        expect(retrieved[255], equals(255));
        expect(retrieved[1000], equals(1000 % 256));
      });
    });
  });
}

class _AlwaysConnectedNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true;

  @override
  Future<bool> isHostReachable(String host) async => true;
}

// Minimal fake http.Client to avoid Mockito stubbing pitfalls inside thenAnswer
class _FakeHttpClient implements http.Client {
  final Map<Uri, Future<http.Response> Function()> getHandlers;
  final Map<Uri, Future<http.Response> Function()> headHandlers;

  _FakeHttpClient(
      {Map<Uri, Future<http.Response> Function()>? getHandlers,
      Map<Uri, Future<http.Response> Function()>? headHandlers})
      : getHandlers = getHandlers ?? {},
        headHandlers = headHandlers ?? {};

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    final handler = getHandlers[url];
    if (handler != null) return handler();
    return Future.value(http.Response('Not Found', 404));
  }

  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) {
    final handler = headHandlers[url];
    if (handler != null) return handler();
    return Future.value(http.Response('', 200));
  }

  // Unused methods in tests; provide simple fallbacks
  @override
  Future<http.Response> delete(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      Future.value(http.Response('', 200));

  @override
  void close() {}

  @override
  Future<http.Response> patch(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      Future.value(http.Response('', 200));

  @override
  Future<http.Response> post(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      Future.value(http.Response('', 200));

  @override
  Future<http.Response> put(Uri url,
          {Map<String, String>? headers, Object? body, Encoding? encoding}) =>
      Future.value(http.Response('', 200));

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) async => '';

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) async =>
      Uint8List(0);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Try to honor GET/HEAD handlers for send as well
    if (request.method.toUpperCase() == 'GET') {
      final handler = getHandlers[request.url];
      if (handler != null) {
        final resp = await handler();
        return http.StreamedResponse(
            Stream.value(resp.bodyBytes), resp.statusCode,
            request: request, headers: resp.headers);
      }
    }
    if (request.method.toUpperCase() == 'HEAD') {
      final handler = headHandlers[request.url];
      if (handler != null) {
        final resp = await handler();
        return http.StreamedResponse(const Stream.empty(), resp.statusCode,
            request: request, headers: resp.headers);
      }
    }
    return http.StreamedResponse(const Stream.empty(), 200, request: request);
  }
}
