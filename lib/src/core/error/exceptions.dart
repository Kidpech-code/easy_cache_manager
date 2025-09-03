/// Custom exceptions for the cache system
class CacheException implements Exception {
  final String message;
  final int? errorCode;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const CacheException(
      {required this.message,
      this.errorCode,
      this.originalError,
      this.stackTrace});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException extends CacheException {
  const NetworkException(
      {required super.message,
      super.errorCode,
      super.originalError,
      super.stackTrace});
}

class StorageException extends CacheException {
  const StorageException(
      {required super.message,
      super.errorCode,
      super.originalError,
      super.stackTrace});
}

class SerializationException extends CacheException {
  const SerializationException(
      {required super.message,
      super.errorCode,
      super.originalError,
      super.stackTrace});
}
