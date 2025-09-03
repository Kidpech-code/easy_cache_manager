/// Base class for all cache-related failures
abstract class CacheFailure {
  final String message;
  final int? errorCode;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const CacheFailure(
      {required this.message,
      this.errorCode,
      this.originalError,
      this.stackTrace});

  @override
  String toString() => 'CacheFailure: $message';
}

/// Network-related failures
class NetworkFailure extends CacheFailure {
  const NetworkFailure(
      {required super.message,
      super.errorCode,
      super.originalError,
      super.stackTrace});

  factory NetworkFailure.noConnection() {
    return const NetworkFailure(
        message: 'No internet connection available', errorCode: 1001);
  }

  factory NetworkFailure.timeout() {
    return const NetworkFailure(
        message: 'Network request timeout', errorCode: 1002);
  }

  factory NetworkFailure.serverError(int statusCode) {
    return NetworkFailure(
        message: 'Server error: $statusCode', errorCode: statusCode);
  }
}

/// Storage-related failures
class StorageFailure extends CacheFailure {
  const StorageFailure(
      {required super.message,
      super.errorCode,
      super.originalError,
      super.stackTrace});

  factory StorageFailure.diskFull() {
    return const StorageFailure(
        message: 'Insufficient disk space for cache storage', errorCode: 2001);
  }

  factory StorageFailure.accessDenied() {
    return const StorageFailure(
        message: 'Access denied to cache directory', errorCode: 2002);
  }

  factory StorageFailure.corruption() {
    return const StorageFailure(
        message: 'Cache data corruption detected', errorCode: 2003);
  }
}

/// Serialization-related failures
class SerializationFailure extends CacheFailure {
  const SerializationFailure(
      {required super.message,
      super.errorCode,
      super.originalError,
      super.stackTrace});

  factory SerializationFailure.encoding() {
    return const SerializationFailure(
        message: 'Failed to encode data for storage', errorCode: 3001);
  }

  factory SerializationFailure.decoding() {
    return const SerializationFailure(
        message: 'Failed to decode data from storage', errorCode: 3002);
  }
}

/// Configuration-related failures
class ConfigurationFailure extends CacheFailure {
  const ConfigurationFailure(
      {required super.message,
      super.errorCode,
      super.originalError,
      super.stackTrace});

  factory ConfigurationFailure.invalidConfig() {
    return const ConfigurationFailure(
        message: 'Invalid cache configuration', errorCode: 4001);
  }
}
