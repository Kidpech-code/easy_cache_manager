import 'dart:typed_data';
import '../entities/cache_config.dart';
import '../repositories/cache_repository.dart';
import '../repositories/network_repository.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';

/// Result wrapper for use case operations
class BytesResult {
  final Uint8List? data;
  final CacheFailure? failure;
  final bool isFromCache;
  final Duration loadTime;

  const BytesResult._(
      {this.data,
      this.failure,
      this.isFromCache = false,
      this.loadTime = Duration.zero});

  factory BytesResult.success(Uint8List data,
      {bool isFromCache = false, Duration loadTime = Duration.zero}) {
    return BytesResult._(
        data: data, isFromCache: isFromCache, loadTime: loadTime);
  }

  factory BytesResult.failure(CacheFailure failure) {
    return BytesResult._(failure: failure);
  }

  bool get isSuccess => failure == null && data != null;
  bool get isFailure => failure != null;
}

/// Use case for fetching binary data (images, files) with caching
class GetBytesUseCase {
  final CacheRepository cacheRepository;
  final NetworkRepository networkRepository;
  final NetworkInfo networkInfo;
  final CacheConfig config;

  GetBytesUseCase(
      {required this.cacheRepository,
      required this.networkRepository,
      required this.networkInfo,
      required this.config});

  Future<BytesResult> execute(String url,
      {Duration? maxAge,
      Map<String, String>? headers,
      bool forceRefresh = false}) async {
    final startTime = DateTime.now();
    final cacheKey = _generateCacheKey(url, headers);

    try {
      // Check cache first (unless force refresh)
      if (!forceRefresh) {
        final cachedBytes = await cacheRepository.retrieveBytes(cacheKey);
        if (cachedBytes != null) {
          final cachedEntry = await cacheRepository.retrieve(cacheKey);
          if (cachedEntry != null) {
            final effectiveMaxAge = maxAge ?? config.maxAge;
            if (cachedEntry.createdAt
                .add(effectiveMaxAge)
                .isAfter(DateTime.now())) {
              final loadTime = DateTime.now().difference(startTime);
              return BytesResult.success(cachedBytes,
                  isFromCache: true, loadTime: loadTime);
            }
          }
        }
      }

      // Check network connectivity
      final isConnected = await networkInfo.isConnected;
      if (!isConnected && config.enableOfflineMode) {
        // Try to serve stale data if offline
        final cachedBytes = await cacheRepository.retrieveBytes(cacheKey);
        if (cachedBytes != null) {
          final loadTime = DateTime.now().difference(startTime);
          return BytesResult.success(cachedBytes,
              isFromCache: true, loadTime: loadTime);
        }
        return BytesResult.failure(NetworkFailure.noConnection());
      }

      // Fetch from network
      final data = await networkRepository.fetchBytes(url, headers: headers);

      // Cache the result
      await cacheRepository.storeBytes(cacheKey, data,
          maxAge: maxAge ?? config.maxAge,
          headers: headers,
          contentType: _inferContentType(url));

      final loadTime = DateTime.now().difference(startTime);
      return BytesResult.success(data, loadTime: loadTime);
    } catch (e) {
      // Try to serve stale data on error
      if (config.enableOfflineMode) {
        final cachedBytes = await cacheRepository.retrieveBytes(cacheKey);
        if (cachedBytes != null) {
          final loadTime = DateTime.now().difference(startTime);
          return BytesResult.success(cachedBytes,
              isFromCache: true, loadTime: loadTime);
        }
      }

      return BytesResult.failure(NetworkFailure(
          message: 'Failed to fetch data: $e', originalError: e));
    }
  }

  String _generateCacheKey(String url, Map<String, String>? headers) {
    return 'bytes_$url';
  }

  String _inferContentType(String url) {
    final uri = Uri.parse(url);
    final path = uri.path.toLowerCase();

    if (path.endsWith('.jpg') || path.endsWith('.jpeg')) return 'image/jpeg';
    if (path.endsWith('.png')) return 'image/png';
    if (path.endsWith('.gif')) return 'image/gif';
    if (path.endsWith('.webp')) return 'image/webp';
    if (path.endsWith('.svg')) return 'image/svg+xml';
    if (path.endsWith('.pdf')) return 'application/pdf';
    if (path.endsWith('.zip')) return 'application/zip';

    return 'application/octet-stream';
  }
}
