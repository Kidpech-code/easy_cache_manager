import 'dart:typed_data';
import '../entities/cache_config.dart';
import '../entities/cache_entry.dart';
import '../repositories/cache_repository.dart';
import '../repositories/network_repository.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/utils/cache_utils.dart';

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
    final cacheKey = CacheUtils.generateRequestCacheKey('bytes', url, headers);
    final effectiveMaxAge = maxAge ?? config.maxAge;

    try {
      if (headers?.isNotEmpty == true) {
        final legacyKey = 'bytes_$url';
        final legacyEntry = await cacheRepository.retrieve(legacyKey);
        if (legacyEntry?.headers?.isNotEmpty == true) {
          await cacheRepository.remove(legacyKey);
        }
      }

      // Check cache first (unless force refresh)
      if (!forceRefresh) {
        final cachedEntry =
            await _retrieveSafeEntry(cacheKey, headers, effectiveMaxAge);
        if (cachedEntry != null) {
          final cachedBytes = await cacheRepository.retrieveBytes(cacheKey);
          if (cachedBytes != null &&
              cachedEntry.createdAt
                  .add(effectiveMaxAge)
                  .isAfter(DateTime.now())) {
            final loadTime = DateTime.now().difference(startTime);
            return BytesResult.success(cachedBytes,
                isFromCache: true, loadTime: loadTime);
          }
        }
      }

      // Check network connectivity
      final isConnected = await networkInfo.isConnected;
      if (!isConnected && config.enableOfflineMode) {
        // Try to serve stale data if offline
        final cachedEntry =
            await _retrieveSafeEntry(cacheKey, headers, effectiveMaxAge);
        final cachedBytes = cachedEntry == null
            ? null
            : await cacheRepository.retrieveBytes(cacheKey);
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
          maxAge: effectiveMaxAge + config.stalePeriod,
          contentType: _inferContentType(url));

      final loadTime = DateTime.now().difference(startTime);
      return BytesResult.success(data, loadTime: loadTime);
    } catch (e) {
      // Try to serve stale data on error
      if (config.enableOfflineMode) {
        final cachedEntry =
            await _retrieveSafeEntry(cacheKey, headers, effectiveMaxAge);
        final cachedBytes = cachedEntry == null
            ? null
            : await cacheRepository.retrieveBytes(cacheKey);
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

  Future<CacheEntry?> _retrieveSafeEntry(String cacheKey,
      Map<String, String>? requestHeaders, Duration effectiveMaxAge) async {
    final entry = await cacheRepository.retrieve(cacheKey);
    if ((requestHeaders == null || requestHeaders.isEmpty) &&
        entry?.headers?.isNotEmpty == true) {
      // Earlier versions used this URL-only key for authenticated responses.
      await cacheRepository.remove(cacheKey);
      return null;
    }
    if (entry != null &&
        !entry.createdAt
            .add(effectiveMaxAge + config.stalePeriod)
            .isAfter(DateTime.now())) {
      await cacheRepository.remove(cacheKey);
      return null;
    }
    return entry;
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
