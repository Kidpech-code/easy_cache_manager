/// Represents the current status of cache operations
enum CacheStatus { loading, cached, fresh, stale, error, offline }

/// Detailed information about cache operation status
class CacheStatusInfo {
  final CacheStatus status;
  final String message;
  final DateTime timestamp;
  final String? key;
  final Duration? loadTime;
  final int? sizeInBytes;
  final bool isFromCache;

  const CacheStatusInfo({
    required this.status,
    required this.message,
    required this.timestamp,
    this.key,
    this.loadTime,
    this.sizeInBytes,
    this.isFromCache = false,
  });

  factory CacheStatusInfo.loading({String? key}) {
    return CacheStatusInfo(
        status: CacheStatus.loading,
        message: 'Loading data...',
        timestamp: DateTime.now(),
        key: key);
  }

  factory CacheStatusInfo.cached(
      {required String key,
      required Duration loadTime,
      required int sizeInBytes}) {
    return CacheStatusInfo(
      status: CacheStatus.cached,
      message: 'Data loaded from cache',
      timestamp: DateTime.now(),
      key: key,
      loadTime: loadTime,
      sizeInBytes: sizeInBytes,
      isFromCache: true,
    );
  }

  factory CacheStatusInfo.fresh(
      {required String key,
      required Duration loadTime,
      required int sizeInBytes}) {
    return CacheStatusInfo(
      status: CacheStatus.fresh,
      message: 'Fresh data loaded from network',
      timestamp: DateTime.now(),
      key: key,
      loadTime: loadTime,
      sizeInBytes: sizeInBytes,
      isFromCache: false,
    );
  }

  factory CacheStatusInfo.stale(
      {required String key, required int sizeInBytes}) {
    return CacheStatusInfo(
      status: CacheStatus.stale,
      message: 'Data is stale, serving from cache',
      timestamp: DateTime.now(),
      key: key,
      sizeInBytes: sizeInBytes,
      isFromCache: true,
    );
  }

  factory CacheStatusInfo.error({required String message, String? key}) {
    return CacheStatusInfo(
        status: CacheStatus.error,
        message: message,
        timestamp: DateTime.now(),
        key: key);
  }

  factory CacheStatusInfo.offline({String? key}) {
    return CacheStatusInfo(
      status: CacheStatus.offline,
      message: 'Offline mode: serving from cache',
      timestamp: DateTime.now(),
      key: key,
      isFromCache: true,
    );
  }

  @override
  String toString() {
    return 'CacheStatusInfo(status: $status, message: $message, key: $key, '
        'loadTime: $loadTime, sizeInBytes: $sizeInBytes, isFromCache: $isFromCache)';
  }
}
