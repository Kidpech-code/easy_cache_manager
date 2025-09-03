import 'dart:typed_data';
import '../../domain/repositories/network_repository.dart';
import '../datasources/network_remote_data_source.dart';
import '../../core/error/exceptions.dart';

/// Network repository implementation
class NetworkRepositoryImpl implements NetworkRepository {
  final NetworkRemoteDataSource remoteDataSource;

  NetworkRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>> fetchJson(String url,
      {Map<String, String>? headers, Duration? timeout}) async {
    try {
      return await remoteDataSource.fetchJson(url,
          headers: headers, timeout: timeout);
    } catch (e) {
      if (e is NetworkException || e is SerializationException) rethrow;
      throw NetworkException(
          message: 'Failed to fetch JSON: $e', originalError: e);
    }
  }

  @override
  Future<String> fetchString(String url,
      {Map<String, String>? headers, Duration? timeout}) async {
    try {
      return await remoteDataSource.fetchString(url,
          headers: headers, timeout: timeout);
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException(
          message: 'Failed to fetch string: $e', originalError: e);
    }
  }

  @override
  Future<Uint8List> fetchBytes(String url,
      {Map<String, String>? headers, Duration? timeout}) async {
    try {
      return await remoteDataSource.fetchBytes(url,
          headers: headers, timeout: timeout);
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException(
          message: 'Failed to fetch bytes: $e', originalError: e);
    }
  }

  @override
  Future<Map<String, String>> getHeaders(String url,
      {Map<String, String>? headers, Duration? timeout}) async {
    try {
      return await remoteDataSource.getHeaders(url,
          headers: headers, timeout: timeout);
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw NetworkException(
          message: 'Failed to get headers: $e', originalError: e);
    }
  }

  @override
  Future<bool> isUrlReachable(String url) async {
    try {
      return await remoteDataSource.isUrlReachable(url);
    } catch (e) {
      return false;
    }
  }
}
