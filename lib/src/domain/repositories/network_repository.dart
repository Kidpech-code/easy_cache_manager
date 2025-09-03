import 'dart:typed_data';

/// Repository interface for network operations
abstract class NetworkRepository {
  /// Fetch JSON data from URL
  Future<Map<String, dynamic>> fetchJson(String url,
      {Map<String, String>? headers, Duration? timeout});

  /// Fetch string data from URL
  Future<String> fetchString(String url,
      {Map<String, String>? headers, Duration? timeout});

  /// Fetch binary data from URL
  Future<Uint8List> fetchBytes(String url,
      {Map<String, String>? headers, Duration? timeout});

  /// Make a HEAD request to get headers
  Future<Map<String, String>> getHeaders(String url,
      {Map<String, String>? headers, Duration? timeout});

  /// Check if URL is reachable
  Future<bool> isUrlReachable(String url);
}
