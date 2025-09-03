import 'dart:async';
import 'dart:typed_data';
import 'package:rxdart/rxdart.dart';
import '../domain/entities/cache_config.dart';
import '../domain/entities/cache_stats.dart';
import '../domain/entities/cache_status.dart';
import '../domain/usecases/get_json_usecase.dart';
import '../domain/usecases/get_bytes_usecase.dart';
import '../domain/usecases/cache_management_usecase.dart';
import '../data/repositories/cache_repository_impl.dart';
import '../data/repositories/network_repository_impl.dart';
import '../data/datasources/network_remote_data_source.dart';
import '../core/network/network_info.dart';
import '../core/storage/hive_cache_storage.dart';

/// Main cache manager class - the public API
class CacheManager {
  late final GetJsonUseCase _getJsonUseCase;
  late final GetBytesUseCase _getBytesUseCase;
  late final CacheManagementUseCase _cacheManagementUseCase;

  final CacheConfig config;
  final BehaviorSubject<CacheStatusInfo> _statusController;
  final BehaviorSubject<CacheStats> _statsController;

  Timer? _cleanupTimer;

  /// Stream of cache status updates
  Stream<CacheStatusInfo> get statusStream => _statusController.stream;

  /// Stream of cache statistics updates
  Stream<CacheStats> get statsStream => _statsController.stream;

  /// Current cache status
  CacheStatusInfo get currentStatus => _statusController.value;

  /// Current cache statistics
  CacheStats get currentStats => _statsController.value;

  CacheManager(
      {required this.config,
      HiveCacheStorage? hiveCacheStorage,
      NetworkRemoteDataSource? remoteDataSource,
      NetworkInfo? networkInfo})
      : _statusController = BehaviorSubject<CacheStatusInfo>.seeded(
          CacheStatusInfo(
              status: CacheStatus.loading,
              message: 'Initializing high-performance Hive cache...',
              timestamp: DateTime.now()),
        ),
        _statsController =
            BehaviorSubject<CacheStats>.seeded(CacheStats.empty()) {
    _initialize(hiveCacheStorage, remoteDataSource, networkInfo);
  }

  void _initialize(HiveCacheStorage? hiveCacheStorage,
      NetworkRemoteDataSource? remoteDataSource, NetworkInfo? networkInfo) {
    // Initialize dependencies with blazing-fast Hive storage
    final hiveStorage = hiveCacheStorage ?? HiveCacheStorage();
    final remoteDS = remoteDataSource ?? NetworkRemoteDataSourceImpl();
    final netInfo = networkInfo ?? NetworkInfoImpl();

    final cacheRepository = CacheRepositoryImpl(hiveCacheStorage: hiveStorage);
    final networkRepository = NetworkRepositoryImpl(remoteDataSource: remoteDS);

    // Initialize use cases
    _getJsonUseCase = GetJsonUseCase(
        cacheRepository: cacheRepository,
        networkRepository: networkRepository,
        networkInfo: netInfo,
        config: config);

    _getBytesUseCase = GetBytesUseCase(
        cacheRepository: cacheRepository,
        networkRepository: networkRepository,
        networkInfo: netInfo,
        config: config);

    _cacheManagementUseCase =
        CacheManagementUseCase(cacheRepository: cacheRepository);

    // Set up auto cleanup if enabled
    if (config.autoCleanup) {
      _setupAutoCleanup();
    }

    // Initialize stats
    _updateStats();

    _statusController.add(CacheStatusInfo(
        status: CacheStatus.cached,
        message: 'Cache manager ready',
        timestamp: DateTime.now()));
  }

  /// Fetch JSON data with caching
  Future<Map<String, dynamic>> getJson(String url,
      {Duration? maxAge,
      Map<String, String>? headers,
      bool forceRefresh = false}) async {
    _statusController.add(CacheStatusInfo.loading(key: url));

    try {
      final result = await _getJsonUseCase.execute(url,
          maxAge: maxAge, headers: headers, forceRefresh: forceRefresh);

      if (result.isSuccess) {
        final statusInfo = result.isFromCache
            ? CacheStatusInfo.cached(
                key: url,
                loadTime: result.loadTime,
                sizeInBytes: result.data.toString().length)
            : CacheStatusInfo.fresh(
                key: url,
                loadTime: result.loadTime,
                sizeInBytes: result.data.toString().length);

        _statusController.add(statusInfo);
        _updateStats();

        return result.data!;
      } else {
        final errorInfo = CacheStatusInfo.error(
            message: result.failure?.message ?? 'Unknown error', key: url);
        _statusController.add(errorInfo);
        throw Exception(result.failure?.message ?? 'Failed to get JSON');
      }
    } catch (e) {
      _statusController
          .add(CacheStatusInfo.error(message: e.toString(), key: url));
      rethrow;
    }
  }

  /// Fetch binary data with caching
  Future<Uint8List> getBytes(String url,
      {Duration? maxAge,
      Map<String, String>? headers,
      bool forceRefresh = false}) async {
    _statusController.add(CacheStatusInfo.loading(key: url));

    try {
      final result = await _getBytesUseCase.execute(url,
          maxAge: maxAge, headers: headers, forceRefresh: forceRefresh);

      if (result.isSuccess) {
        final statusInfo = result.isFromCache
            ? CacheStatusInfo.cached(
                key: url,
                loadTime: result.loadTime,
                sizeInBytes: result.data!.length)
            : CacheStatusInfo.fresh(
                key: url,
                loadTime: result.loadTime,
                sizeInBytes: result.data!.length);

        _statusController.add(statusInfo);
        _updateStats();

        return result.data!;
      } else {
        final errorInfo = CacheStatusInfo.error(
            message: result.failure?.message ?? 'Unknown error', key: url);
        _statusController.add(errorInfo);
        throw Exception(result.failure?.message ?? 'Failed to get bytes');
      }
    } catch (e) {
      _statusController
          .add(CacheStatusInfo.error(message: e.toString(), key: url));
      rethrow;
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      await _cacheManagementUseCase.clearCache();
      await _updateStats();

      _statusController.add(CacheStatusInfo(
          status: CacheStatus.cached,
          message: 'Cache cleared successfully',
          timestamp: DateTime.now()));
    } catch (e) {
      _statusController
          .add(CacheStatusInfo.error(message: 'Failed to clear cache: $e'));
      rethrow;
    }
  }

  /// Remove specific cached item
  Future<void> removeItem(String key) async {
    try {
      await _cacheManagementUseCase.removeItem(key);
      await _updateStats();
    } catch (e) {
      _statusController.add(CacheStatusInfo.error(
          message: 'Failed to remove cache item: $e', key: key));
      rethrow;
    }
  }

  /// Check if cache contains specific key
  Future<bool> contains(String key) async {
    try {
      return await _cacheManagementUseCase.contains(key);
    } catch (e) {
      return false;
    }
  }

  /// Get all cache keys
  Future<List<String>> getAllKeys() async {
    try {
      return await _cacheManagementUseCase.getAllKeys();
    } catch (e) {
      return [];
    }
  }

  /// Manual cleanup of expired entries
  Future<void> cleanup() async {
    try {
      await _cacheManagementUseCase.cleanup();
      await _updateStats();

      _statusController.add(CacheStatusInfo(
          status: CacheStatus.cached,
          message: 'Cache cleanup completed',
          timestamp: DateTime.now()));
    } catch (e) {
      _statusController
          .add(CacheStatusInfo.error(message: 'Failed to cleanup cache: $e'));
      rethrow;
    }
  }

  /// Get cache statistics
  Future<CacheStats> getStats() async {
    try {
      return await _cacheManagementUseCase.getStats();
    } catch (e) {
      return CacheStats.empty();
    }
  }

  void _setupAutoCleanup() {
    _cleanupTimer = Timer.periodic(
      const Duration(hours: 1), // Check every hour
      (timer) async {
        try {
          final stats = await getStats();
          final sizeRatio = stats.totalSizeInBytes / config.maxCacheSize;

          if (sizeRatio > config.cleanupThreshold) {
            await cleanup();
          }
        } catch (e) {
          if (config.enableLogging) {}
        }
      },
    );
  }

  Future<void> _updateStats() async {
    try {
      final stats = await getStats();
      _statsController.add(stats);
    } catch (e) {
      // Ignore stats update errors
    }
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _statusController.close();
    _statsController.close();
  }
}
