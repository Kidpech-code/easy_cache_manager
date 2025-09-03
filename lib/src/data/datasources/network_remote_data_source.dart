import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../core/error/exceptions.dart';

/// Remote data source interface
abstract class NetworkRemoteDataSource {
  Future<Map<String, dynamic>> fetchJson(String url,
      {Map<String, String>? headers, Duration? timeout});

  Future<String> fetchString(String url,
      {Map<String, String>? headers, Duration? timeout});

  Future<Uint8List> fetchBytes(String url,
      {Map<String, String>? headers, Duration? timeout});

  Future<Map<String, String>> getHeaders(String url,
      {Map<String, String>? headers, Duration? timeout});

  Future<bool> isUrlReachable(String url);
}

/// HTTP implementation of network remote data source
class NetworkRemoteDataSourceImpl implements NetworkRemoteDataSource {
  final http.Client client;
  static const Duration _defaultTimeout = Duration(seconds: 30);

  NetworkRemoteDataSourceImpl({http.Client? client})
      : client = client ?? http.Client();

  @override
  Future<Map<String, dynamic>> fetchJson(String url,
      {Map<String, String>? headers, Duration? timeout}) async {
    try {
      final response = await client
          .get(Uri.parse(url), headers: headers)
          .timeout(timeout ?? _defaultTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          throw SerializationException(
              message: 'Failed to decode JSON response', originalError: e);
        }
      } else {
        throw NetworkException(
            message: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
            errorCode: response.statusCode);
      }
    } catch (e) {
      if (e is NetworkException || e is SerializationException) rethrow;

      throw NetworkException(
          message: 'Network request failed: $e', originalError: e);
    }
  }

  @override
  Future<String> fetchString(String url,
      {Map<String, String>? headers, Duration? timeout}) async {
    try {
      final response = await client
          .get(Uri.parse(url), headers: headers)
          .timeout(timeout ?? _defaultTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.body;
      } else {
        throw NetworkException(
            message: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
            errorCode: response.statusCode);
      }
    } catch (e) {
      if (e is NetworkException) rethrow;

      throw NetworkException(
          message: 'Network request failed: $e', originalError: e);
    }
  }

  @override
  Future<Uint8List> fetchBytes(String url,
      {Map<String, String>? headers, Duration? timeout}) async {
    try {
      final response = await client
          .get(Uri.parse(url), headers: headers)
          .timeout(timeout ?? _defaultTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      } else {
        throw NetworkException(
            message: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
            errorCode: response.statusCode);
      }
    } catch (e) {
      if (e is NetworkException) rethrow;

      throw NetworkException(
          message: 'Network request failed: $e', originalError: e);
    }
  }

  @override
  Future<Map<String, String>> getHeaders(String url,
      {Map<String, String>? headers, Duration? timeout}) async {
    try {
      final response = await client
          .head(Uri.parse(url), headers: headers)
          .timeout(timeout ?? _defaultTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.headers;
      } else {
        throw NetworkException(
            message: 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
            errorCode: response.statusCode);
      }
    } catch (e) {
      if (e is NetworkException) rethrow;

      throw NetworkException(
          message: 'Network HEAD request failed: $e', originalError: e);
    }
  }

  @override
  Future<bool> isUrlReachable(String url) async {
    try {
      final response = await client
          .head(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (e) {
      return false;
    }
  }

  /// Dispose of resources
  void dispose() {
    client.close();
  }
}
