import '../error/cache_exceptions.dart';

/// Professional configuration validator for cache settings
///
/// Provides comprehensive validation with detailed error messages
/// and suggestions for fixing configuration issues.
class CacheConfigValidator {
  /// Validate cache configuration thoroughly
  static void validate({
    int? maxCacheSize,
    Duration? stalePeriod,
    Duration? maxAge,
    double? cleanupThreshold,
    String? evictionPolicy,
    String? compressionType,
    int? compressionLevel,
    String? encryptionKey,
    int? maxCacheEntries,
    String? cacheName,
  }) {
    _validateMaxCacheSize(maxCacheSize);
    _validateStalePeriod(stalePeriod);
    _validateMaxAge(maxAge);
    _validateCleanupThreshold(cleanupThreshold);
    _validateEvictionPolicy(evictionPolicy);
    _validateCompressionSettings(compressionType, compressionLevel);
    _validateEncryptionKey(encryptionKey);
    _validateMaxCacheEntries(maxCacheEntries);
    _validateCacheName(cacheName);
  }

  static void _validateMaxCacheSize(int? maxCacheSize) {
    if (maxCacheSize == null) return;

    if (maxCacheSize <= 0) {
      throw CacheConfigurationException.invalidMaxSize(
        provided: maxCacheSize,
        cause: 'Max cache size must be positive',
      );
    }

    // Warn about very small cache sizes (less than 1MB)
    if (maxCacheSize < 1024 * 1024) {
      // This would be a warning in a real logging system
    }

    // Warn about very large cache sizes (more than 1GB)
    if (maxCacheSize > 1024 * 1024 * 1024) {}
  }

  static void _validateStalePeriod(Duration? stalePeriod) {
    if (stalePeriod == null) return;

    if (stalePeriod.isNegative) {
      throw CacheConfigurationException(
        message:
            'Stale period cannot be negative: ${stalePeriod.inMilliseconds}ms',
        errorCode: 'CACHE_INVALID_STALE_PERIOD',
        cause: 'Stale period must be zero or positive',
      );
    }

    // Warn about very short stale periods (less than 1 minute)
    if (stalePeriod.inMinutes < 1 && stalePeriod.inMilliseconds > 0) {}

    // Warn about very long stale periods (more than 30 days)
    if (stalePeriod.inDays > 30) {}
  }

  static void _validateMaxAge(Duration? maxAge) {
    if (maxAge == null) return;

    if (maxAge.isNegative) {
      throw CacheConfigurationException(
        message: 'Max age cannot be negative: ${maxAge.inMilliseconds}ms',
        errorCode: 'CACHE_INVALID_MAX_AGE',
        cause: 'Max age must be zero or positive',
      );
    }

    // Warn about very short max age (less than 30 seconds)
    if (maxAge.inSeconds < 30 && maxAge.inMilliseconds > 0) {}
  }

  static void _validateCleanupThreshold(double? cleanupThreshold) {
    if (cleanupThreshold == null) return;

    if (cleanupThreshold < 0.0 || cleanupThreshold > 1.0) {
      throw CacheConfigurationException(
        message:
            'Cleanup threshold must be between 0.0 and 1.0, got: $cleanupThreshold',
        errorCode: 'CACHE_INVALID_CLEANUP_THRESHOLD',
        cause: 'Cleanup threshold represents a percentage (0-100%)',
      );
    }

    // Warn about very low threshold (may cause frequent cleanup)
    if (cleanupThreshold < 0.5) {}

    // Warn about very high threshold (may cause storage issues)
    if (cleanupThreshold > 0.95) {}
  }

  static void _validateEvictionPolicy(String? evictionPolicy) {
    if (evictionPolicy == null) return;

    const validPolicies = ['lru', 'lfu', 'fifo', 'ttl', 'size-based', 'random'];

    if (!validPolicies.contains(evictionPolicy.toLowerCase())) {
      throw CacheConfigurationException.invalidEvictionPolicy(
        policy: evictionPolicy,
        available: validPolicies,
        cause: 'Unsupported eviction policy',
      );
    }
  }

  static void _validateCompressionSettings(
      String? compressionType, int? compressionLevel) {
    if (compressionType != null) {
      const validTypes = ['gzip', 'deflate', 'lz4', 'none'];

      if (!validTypes.contains(compressionType.toLowerCase())) {
        throw CacheConfigurationException(
          message:
              'Invalid compression type: $compressionType. Available: ${validTypes.join(', ')}',
          errorCode: 'CACHE_INVALID_COMPRESSION_TYPE',
          cause: 'Unsupported compression algorithm',
        );
      }
    }

    if (compressionLevel != null) {
      if (compressionLevel < 0 || compressionLevel > 9) {
        throw CacheConfigurationException(
          message:
              'Compression level must be between 0 and 9, got: $compressionLevel',
          errorCode: 'CACHE_INVALID_COMPRESSION_LEVEL',
          cause: 'Compression level out of valid range',
        );
      }

      // Warn about high compression levels (may be slow)
      if (compressionLevel > 6) {}
    }
  }

  static void _validateEncryptionKey(String? encryptionKey) {
    if (encryptionKey == null) return;

    if (encryptionKey.isEmpty) {
      throw CacheConfigurationException.invalidEncryptionKey(
        reason: 'Encryption key cannot be empty',
        cause: 'Empty encryption key provided',
      );
    }

    // Check minimum key length for security
    if (encryptionKey.length < 16) {
      throw CacheConfigurationException.invalidEncryptionKey(
        reason:
            'Key too short (${encryptionKey.length} chars). Minimum 16 characters required.',
        cause: 'Insufficient key length for secure encryption',
      );
    }

    // Warn about keys that are not 32 characters (AES-256 optimal)
    if (encryptionKey.length != 32) {}

    // Check for weak keys (all same character, sequential, etc.)
    if (_isWeakKey(encryptionKey)) {
      throw CacheConfigurationException.invalidEncryptionKey(
        reason: 'Weak encryption key detected',
        cause: 'Key appears to be predictable or weak',
      );
    }
  }

  static void _validateMaxCacheEntries(int? maxCacheEntries) {
    if (maxCacheEntries == null) return;

    if (maxCacheEntries <= 0) {
      throw CacheConfigurationException(
        message: 'Max cache entries must be positive, got: $maxCacheEntries',
        errorCode: 'CACHE_INVALID_MAX_ENTRIES',
        cause: 'Invalid maximum entries count',
      );
    }

    // Warn about very low entry count
    if (maxCacheEntries < 10) {}

    // Warn about very high entry count (may impact performance)
    if (maxCacheEntries > 100000) {}
  }

  static void _validateCacheName(String? cacheName) {
    if (cacheName == null) return;

    if (cacheName.isEmpty) {
      throw CacheConfigurationException(
        message: 'Cache name cannot be empty',
        errorCode: 'CACHE_INVALID_NAME',
        cause: 'Empty cache name provided',
      );
    }

    // Check for invalid characters in cache name
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(cacheName)) {
      throw CacheConfigurationException(
        message:
            'Invalid cache name: "$cacheName". Use only letters, numbers, hyphens, and underscores.',
        errorCode: 'CACHE_INVALID_NAME_CHARACTERS',
        cause: 'Cache name contains invalid characters',
      );
    }

    // Check cache name length
    if (cacheName.length > 50) {
      throw CacheConfigurationException(
        message:
            'Cache name too long: ${cacheName.length} characters. Maximum 50 characters allowed.',
        errorCode: 'CACHE_NAME_TOO_LONG',
        cause: 'Cache name exceeds maximum length',
      );
    }
  }

  /// Check for commonly weak encryption keys
  static bool _isWeakKey(String key) {
    // All same character
    if (key.split('').toSet().length == 1) {
      return true;
    }

    // Sequential characters
    bool isSequential = true;
    for (int i = 1; i < key.length; i++) {
      if (key.codeUnitAt(i) != key.codeUnitAt(i - 1) + 1) {
        isSequential = false;
        break;
      }
    }
    if (isSequential) return true;

    // Common weak patterns
    const weakPatterns = [
      '123456789',
      'abcdefgh',
      'password',
      'qwerty',
      '000000',
      '111111',
    ];

    for (String pattern in weakPatterns) {
      if (key.toLowerCase().contains(pattern)) {
        return true;
      }
    }

    return false;
  }

  /// Get configuration recommendations based on app type
  static Map<String, dynamic> getRecommendations(String appType) {
    switch (appType.toLowerCase()) {
      case 'small':
      case 'prototype':
        return {
          'maxCacheSize': 10 * 1024 * 1024, // 10MB
          'stalePeriod': const Duration(days: 3),
          'maxAge': const Duration(hours: 1),
          'cleanupThreshold': 0.8,
          'evictionPolicy': 'lru',
          'enableCompression': false,
          'enableEncryption': false,
        };

      case 'medium':
      case 'production':
        return {
          'maxCacheSize': 100 * 1024 * 1024, // 100MB
          'stalePeriod': const Duration(days: 7),
          'maxAge': const Duration(hours: 6),
          'cleanupThreshold': 0.75,
          'evictionPolicy': 'lru',
          'enableCompression': true,
          'enableEncryption': false,
        };

      case 'enterprise':
      case 'large':
        return {
          'maxCacheSize': 500 * 1024 * 1024, // 500MB
          'stalePeriod': const Duration(days: 14),
          'maxAge': const Duration(hours: 12),
          'cleanupThreshold': 0.7,
          'evictionPolicy': 'lfu',
          'enableCompression': true,
          'enableEncryption': true,
        };

      case 'ecommerce':
        return {
          'maxCacheSize': 200 * 1024 * 1024, // 200MB
          'stalePeriod': const Duration(days: 5),
          'maxAge': const Duration(minutes: 30), // Fresh product data
          'cleanupThreshold': 0.8,
          'evictionPolicy': 'lru',
          'enableCompression': true,
          'enableEncryption': false,
        };

      case 'social':
        return {
          'maxCacheSize': 300 * 1024 * 1024, // 300MB
          'stalePeriod': const Duration(days: 2), // Fresh social content
          'maxAge': const Duration(minutes: 15),
          'cleanupThreshold': 0.8,
          'evictionPolicy': 'lru',
          'enableCompression': true,
          'enableEncryption': false,
        };

      case 'news':
        return {
          'maxCacheSize': 150 * 1024 * 1024, // 150MB
          'stalePeriod': const Duration(days: 1), // Fresh news
          'maxAge': const Duration(minutes: 10),
          'cleanupThreshold': 0.8,
          'evictionPolicy': 'ttl', // Time-based for news
          'enableCompression': true,
          'enableEncryption': false,
        };

      default:
        return {
          'maxCacheSize': 50 * 1024 * 1024, // 50MB
          'stalePeriod': const Duration(days: 7),
          'maxAge': const Duration(hours: 2),
          'cleanupThreshold': 0.8,
          'evictionPolicy': 'lru',
          'enableCompression': false,
          'enableEncryption': false,
        };
    }
  }

  /// Validate configuration against platform capabilities
  static void validatePlatformSupport(
      Map<String, dynamic> config, String platform) {
    // Web platform limitations
    if (platform.toLowerCase() == 'web') {
      if (config['enableEncryption'] == true) {
        throw CacheConfigurationException.unsupportedPlatform(
          feature: 'Encryption',
          platform: 'Web',
          cause:
              'Encryption not supported on web platform due to security restrictions',
        );
      }

      if (config['enableCompression'] == true) {}

      final maxSize = config['maxCacheSize'] as int?;
      if (maxSize != null && maxSize > 50 * 1024 * 1024) {}
    }

    // Mobile platform recommendations
    if (platform.toLowerCase() == 'mobile') {
      final maxSize = config['maxCacheSize'] as int?;
      if (maxSize != null && maxSize > 200 * 1024 * 1024) {}
    }
  }
}
