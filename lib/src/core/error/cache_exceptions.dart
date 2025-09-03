/// Professional-grade cache-specific exceptions
///
/// This provides detailed, specific exceptions for different cache failure scenarios
/// allowing applications to handle different error cases appropriately.
library cache_exceptions;

/// Base exception for all cache-related errors
abstract class CacheException implements Exception {
  /// Human-readable error message
  final String message;

  /// Error code for programmatic handling
  final String errorCode;

  /// Optional underlying cause
  final dynamic cause;

  /// Timestamp when error occurred
  final DateTime timestamp;

  CacheException({
    required this.message,
    required this.errorCode,
    this.cause,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => 'CacheException($errorCode): $message';
}

/// Storage-related cache exceptions
class CacheStorageException extends CacheException {
  CacheStorageException({
    required super.message,
    required super.errorCode,
    super.cause,
  });

  /// Factory constructors for common storage errors
  factory CacheStorageException.initializationFailed({
    String? details,
    dynamic cause,
  }) =>
      CacheStorageException(
        message:
            'Failed to initialize cache storage${details != null ? ': $details' : ''}',
        errorCode: 'CACHE_INIT_FAILED',
        cause: cause,
      );

  factory CacheStorageException.diskFull({dynamic cause}) =>
      CacheStorageException(
        message: 'Insufficient disk space for cache operation',
        errorCode: 'CACHE_DISK_FULL',
        cause: cause,
      );

  factory CacheStorageException.accessDenied({dynamic cause}) =>
      CacheStorageException(
        message: 'Access denied to cache storage location',
        errorCode: 'CACHE_ACCESS_DENIED',
        cause: cause,
      );

  factory CacheStorageException.corruption({
    String? key,
    dynamic cause,
  }) =>
      CacheStorageException(
        message:
            'Cache data corruption detected${key != null ? ' for key: $key' : ''}',
        errorCode: 'CACHE_DATA_CORRUPTION',
        cause: cause,
      );

  factory CacheStorageException.writeFailed({
    String? key,
    dynamic cause,
  }) =>
      CacheStorageException(
        message:
            'Failed to write cache entry${key != null ? ' for key: $key' : ''}',
        errorCode: 'CACHE_WRITE_FAILED',
        cause: cause,
      );

  factory CacheStorageException.readFailed({
    String? key,
    dynamic cause,
  }) =>
      CacheStorageException(
        message:
            'Failed to read cache entry${key != null ? ' for key: $key' : ''}',
        errorCode: 'CACHE_READ_FAILED',
        cause: cause,
      );
}

/// Network-related cache exceptions
class CacheNetworkException extends CacheException {
  CacheNetworkException({
    required super.message,
    required super.errorCode,
    super.cause,
  });

  /// Factory constructors for common network errors
  factory CacheNetworkException.noConnection({dynamic cause}) =>
      CacheNetworkException(
        message: 'No internet connection available',
        errorCode: 'CACHE_NO_CONNECTION',
        cause: cause,
      );

  factory CacheNetworkException.timeout({
    String? url,
    Duration? timeout,
    dynamic cause,
  }) =>
      CacheNetworkException(
        message:
            'Network request timeout${url != null ? ' for $url' : ''}${timeout != null ? ' after ${timeout.inSeconds}s' : ''}',
        errorCode: 'CACHE_NETWORK_TIMEOUT',
        cause: cause,
      );

  factory CacheNetworkException.serverError({
    int? statusCode,
    String? url,
    dynamic cause,
  }) =>
      CacheNetworkException(
        message:
            'Server error${statusCode != null ? ' ($statusCode)' : ''}${url != null ? ' for $url' : ''}',
        errorCode: 'CACHE_SERVER_ERROR',
        cause: cause,
      );

  factory CacheNetworkException.invalidResponse({
    String? url,
    String? reason,
    dynamic cause,
  }) =>
      CacheNetworkException(
        message:
            'Invalid server response${url != null ? ' from $url' : ''}${reason != null ? ': $reason' : ''}',
        errorCode: 'CACHE_INVALID_RESPONSE',
        cause: cause,
      );

  factory CacheNetworkException.rateLimited({
    String? url,
    Duration? retryAfter,
    dynamic cause,
  }) =>
      CacheNetworkException(
        message:
            'Request rate limited${url != null ? ' for $url' : ''}${retryAfter != null ? ', retry after ${retryAfter.inSeconds}s' : ''}',
        errorCode: 'CACHE_RATE_LIMITED',
        cause: cause,
      );
}

/// Configuration-related cache exceptions
class CacheConfigurationException extends CacheException {
  CacheConfigurationException({
    required super.message,
    required super.errorCode,
    super.cause,
  });

  /// Factory constructors for common configuration errors
  factory CacheConfigurationException.invalidMaxSize({
    int? provided,
    dynamic cause,
  }) =>
      CacheConfigurationException(
        message:
            'Invalid max cache size${provided != null ? ': $provided bytes. Must be positive.' : ''}',
        errorCode: 'CACHE_INVALID_MAX_SIZE',
        cause: cause,
      );

  factory CacheConfigurationException.invalidEvictionPolicy({
    String? policy,
    List<String>? available,
    dynamic cause,
  }) =>
      CacheConfigurationException(
        message:
            'Invalid eviction policy${policy != null ? ': $policy' : ''}${available != null ? '. Available: ${available.join(', ')}' : ''}',
        errorCode: 'CACHE_INVALID_EVICTION_POLICY',
        cause: cause,
      );

  factory CacheConfigurationException.invalidEncryptionKey({
    String? reason,
    dynamic cause,
  }) =>
      CacheConfigurationException(
        message: 'Invalid encryption key${reason != null ? ': $reason' : ''}',
        errorCode: 'CACHE_INVALID_ENCRYPTION_KEY',
        cause: cause,
      );

  factory CacheConfigurationException.unsupportedPlatform({
    String? feature,
    String? platform,
    dynamic cause,
  }) =>
      CacheConfigurationException(
        message:
            'Feature not supported${feature != null ? ' ($feature)' : ''}${platform != null ? ' on platform: $platform' : ''}',
        errorCode: 'CACHE_UNSUPPORTED_PLATFORM',
        cause: cause,
      );
}

/// Data-related cache exceptions
class CacheDataException extends CacheException {
  CacheDataException({
    required super.message,
    required super.errorCode,
    super.cause,
  });

  /// Factory constructors for common data errors
  factory CacheDataException.serializationFailed({
    String? dataType,
    dynamic cause,
  }) =>
      CacheDataException(
        message:
            'Failed to serialize data${dataType != null ? ' of type: $dataType' : ''}',
        errorCode: 'CACHE_SERIALIZATION_FAILED',
        cause: cause,
      );

  factory CacheDataException.deserializationFailed({
    String? key,
    String? expectedType,
    dynamic cause,
  }) =>
      CacheDataException(
        message:
            'Failed to deserialize cached data${key != null ? ' for key: $key' : ''}${expectedType != null ? ', expected type: $expectedType' : ''}',
        errorCode: 'CACHE_DESERIALIZATION_FAILED',
        cause: cause,
      );

  factory CacheDataException.compressionFailed({
    String? algorithm,
    dynamic cause,
  }) =>
      CacheDataException(
        message:
            'Failed to compress data${algorithm != null ? ' using $algorithm' : ''}',
        errorCode: 'CACHE_COMPRESSION_FAILED',
        cause: cause,
      );

  factory CacheDataException.decompressionFailed({
    String? key,
    String? algorithm,
    dynamic cause,
  }) =>
      CacheDataException(
        message:
            'Failed to decompress cached data${key != null ? ' for key: $key' : ''}${algorithm != null ? ' using $algorithm' : ''}',
        errorCode: 'CACHE_DECOMPRESSION_FAILED',
        cause: cause,
      );

  factory CacheDataException.encryptionFailed({
    String? key,
    dynamic cause,
  }) =>
      CacheDataException(
        message:
            'Failed to encrypt cache data${key != null ? ' for key: $key' : ''}',
        errorCode: 'CACHE_ENCRYPTION_FAILED',
        cause: cause,
      );

  factory CacheDataException.decryptionFailed({
    String? key,
    dynamic cause,
  }) =>
      CacheDataException(
        message:
            'Failed to decrypt cached data${key != null ? ' for key: $key' : ''}',
        errorCode: 'CACHE_DECRYPTION_FAILED',
        cause: cause,
      );

  factory CacheDataException.keyNotFound({
    required String key,
    dynamic cause,
  }) =>
      CacheDataException(
        message: 'Cache entry not found for key: $key',
        errorCode: 'CACHE_KEY_NOT_FOUND',
        cause: cause,
      );

  factory CacheDataException.keyExpired({
    required String key,
    DateTime? expiredAt,
    dynamic cause,
  }) =>
      CacheDataException(
        message:
            'Cache entry expired for key: $key${expiredAt != null ? ' at ${expiredAt.toIso8601String()}' : ''}',
        errorCode: 'CACHE_KEY_EXPIRED',
        cause: cause,
      );

  factory CacheDataException.oversizedEntry({
    String? key,
    int? size,
    int? maxSize,
    dynamic cause,
  }) =>
      CacheDataException(
        message:
            'Cache entry too large${key != null ? ' for key: $key' : ''}${size != null && maxSize != null ? ' ($size bytes > $maxSize bytes limit)' : ''}',
        errorCode: 'CACHE_ENTRY_TOO_LARGE',
        cause: cause,
      );
}

/// Memory-related cache exceptions
class CacheMemoryException extends CacheException {
  CacheMemoryException({
    required super.message,
    required super.errorCode,
    super.cause,
  });

  /// Factory constructors for memory-related errors
  factory CacheMemoryException.outOfMemory({
    String? operation,
    dynamic cause,
  }) =>
      CacheMemoryException(
        message:
            'Out of memory${operation != null ? ' during $operation' : ''}',
        errorCode: 'CACHE_OUT_OF_MEMORY',
        cause: cause,
      );

  factory CacheMemoryException.memoryPressure({
    double? usageRatio,
    dynamic cause,
  }) =>
      CacheMemoryException(
        message:
            'High memory pressure detected${usageRatio != null ? ' (${(usageRatio * 100).toStringAsFixed(1)}% usage)' : ''}',
        errorCode: 'CACHE_MEMORY_PRESSURE',
        cause: cause,
      );

  factory CacheMemoryException.allocationFailed({
    int? requestedBytes,
    dynamic cause,
  }) =>
      CacheMemoryException(
        message:
            'Failed to allocate memory${requestedBytes != null ? ' for $requestedBytes bytes' : ''}',
        errorCode: 'CACHE_MEMORY_ALLOCATION_FAILED',
        cause: cause,
      );
}

/// Extension to add error handling utilities
extension CacheExceptionExtensions on CacheException {
  /// Check if this is a recoverable error
  bool get isRecoverable {
    switch (errorCode) {
      case 'CACHE_NO_CONNECTION':
      case 'CACHE_NETWORK_TIMEOUT':
      case 'CACHE_RATE_LIMITED':
      case 'CACHE_MEMORY_PRESSURE':
        return true;
      case 'CACHE_DATA_CORRUPTION':
      case 'CACHE_ACCESS_DENIED':
      case 'CACHE_UNSUPPORTED_PLATFORM':
        return false;
      default:
        return true; // Default to recoverable
    }
  }

  /// Check if this error should trigger a retry
  bool get shouldRetry {
    switch (errorCode) {
      case 'CACHE_NETWORK_TIMEOUT':
      case 'CACHE_SERVER_ERROR':
      case 'CACHE_MEMORY_PRESSURE':
        return true;
      case 'CACHE_RATE_LIMITED':
      case 'CACHE_ACCESS_DENIED':
      case 'CACHE_DATA_CORRUPTION':
        return false;
      default:
        return false;
    }
  }

  /// Get suggested retry delay
  Duration get suggestedRetryDelay {
    switch (errorCode) {
      case 'CACHE_NETWORK_TIMEOUT':
        return const Duration(seconds: 5);
      case 'CACHE_SERVER_ERROR':
        return const Duration(seconds: 10);
      case 'CACHE_RATE_LIMITED':
        return const Duration(minutes: 1);
      case 'CACHE_MEMORY_PRESSURE':
        return const Duration(seconds: 2);
      default:
        return const Duration(seconds: 1);
    }
  }

  /// Convert to user-friendly message
  String get userFriendlyMessage {
    switch (errorCode) {
      case 'CACHE_NO_CONNECTION':
        return 'Please check your internet connection and try again.';
      case 'CACHE_NETWORK_TIMEOUT':
        return 'Request timed out. Please try again.';
      case 'CACHE_SERVER_ERROR':
        return 'Server is temporarily unavailable. Please try again later.';
      case 'CACHE_DISK_FULL':
        return 'Not enough storage space. Please free up some space.';
      case 'CACHE_ACCESS_DENIED':
        return 'Permission denied. Please check app permissions.';
      case 'CACHE_DATA_CORRUPTION':
        return 'Data corruption detected. Cache will be cleared.';
      case 'CACHE_RATE_LIMITED':
        return 'Too many requests. Please wait a moment and try again.';
      case 'CACHE_OUT_OF_MEMORY':
        return 'Not enough memory available. Please close some apps.';
      default:
        return message;
    }
  }
}
