import '../entities/cache_config.dart';
import '../repositories/cache_repository.dart';
import '../repositories/network_repository.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';

/// Result wrapper for use case operations
class CacheResult<T> {
  final T? data;
  final CacheFailure? failure;
  final bool isFromCache;
  final Duration loadTime;

  const CacheResult._(
      {this.data,
      this.failure,
      this.isFromCache = false,
      this.loadTime = Duration.zero});

  factory CacheResult.success(T data,
      {bool isFromCache = false, Duration loadTime = Duration.zero}) {
    return CacheResult._(
        data: data, isFromCache: isFromCache, loadTime: loadTime);
  }

  factory CacheResult.failure(CacheFailure failure) {
    return CacheResult._(failure: failure);
  }

  bool get isSuccess => failure == null && data != null;
  bool get isFailure => failure != null;
}

/// Use case for fetching JSON data with caching
class GetJsonUseCase {
  final CacheRepository cacheRepository;
  final NetworkRepository networkRepository;
  final NetworkInfo networkInfo;
  final CacheConfig config;

  GetJsonUseCase(
      {required this.cacheRepository,
      required this.networkRepository,
      required this.networkInfo,
      required this.config});

  Future<CacheResult<Map<String, dynamic>>> execute(String url,
      {Duration? maxAge,
      Map<String, String>? headers,
      bool forceRefresh = false}) async {
    final startTime = DateTime.now();
    final cacheKey = _generateCacheKey(url, headers);

    try {
      // Check cache first (unless force refresh)
      if (!forceRefresh) {
        final cachedEntry = await cacheRepository.retrieve(cacheKey);
        if (cachedEntry != null) {
          final effectiveMaxAge = maxAge ?? config.maxAge;
          if (cachedEntry.createdAt
              .add(effectiveMaxAge)
              .isAfter(DateTime.now())) {
            final loadTime = DateTime.now().difference(startTime);
            return CacheResult.success(cachedEntry.data as Map<String, dynamic>,
                isFromCache: true, loadTime: loadTime);
          }
        }
      }

      // Check network connectivity
      final isConnected = await networkInfo.isConnected;
      if (!isConnected && config.enableOfflineMode) {
        // Try to serve stale data if offline
        final cachedEntry = await cacheRepository.retrieve(cacheKey);
        if (cachedEntry != null) {
          final loadTime = DateTime.now().difference(startTime);
          return CacheResult.success(cachedEntry.data as Map<String, dynamic>,
              isFromCache: true, loadTime: loadTime);
        }
        return CacheResult.failure(NetworkFailure.noConnection());
      }

      // Fetch from network
      final data = await networkRepository.fetchJson(url, headers: headers);

      // Cache the result
      await cacheRepository.store(cacheKey, data,
          maxAge: maxAge ?? config.maxAge,
          headers: headers,
          contentType: 'application/json');

      final loadTime = DateTime.now().difference(startTime);
      return CacheResult.success(data, loadTime: loadTime);
    } catch (e) {
      // Try to serve stale data on error
      if (config.enableOfflineMode) {
        final cachedEntry = await cacheRepository.retrieve(cacheKey);
        if (cachedEntry != null) {
          final loadTime = DateTime.now().difference(startTime);
          return CacheResult.success(cachedEntry.data as Map<String, dynamic>,
              isFromCache: true, loadTime: loadTime);
        }
      }

      return CacheResult.failure(NetworkFailure(
          message: 'Failed to fetch data: $e', originalError: e));
    }
  }

  String _generateCacheKey(String url, Map<String, String>? headers) {
    // Simple cache key generation - in real implementation, consider headers
    return 'json_$url';
  }
}
