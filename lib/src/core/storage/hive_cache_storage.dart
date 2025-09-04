import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart' as hive_core;
import 'package:universal_io/io.dart';
import '../../domain/entities/cache_entry.dart';
import '../../domain/entities/cache_stats.dart';
import '../../data/models/hive_cache_entry.dart';
import '../../data/models/hive_cache_stats.dart';
import '../policies/eviction_policy.dart';
import '../analytics/cache_analytics.dart';
import 'platform_cache_storage.dart';
import 'native_storage_adapter.dart'
    if (dart.library.html) 'web_path_provider_stub.dart';

/// High-performance Hive-based cache storage
///
/// Notes:
/// - In many scenarios Hive offers faster read/write than SQL-based approaches
/// - Smaller footprint (no embedded SQL engine)
/// - Type-safe operations
/// - Good memory efficiency
/// - Cross-platform support (Web, Mobile, Desktop)
class HiveCacheStorage implements PlatformCacheStorage {
  final EvictionPolicy? evictionPolicy;
  final CacheAnalytics? analytics;

  /// key access map for LRU/analytics
  final Map<String, DateTime> _keyAccessMap = {};

  HiveCacheStorage({this.evictionPolicy, this.analytics});

  /// Enable verbose logging for troubleshooting (disabled by default)
  static bool loggingEnabled = false;
  static const String _cacheBoxName = 'easy_cache_entries';
  static const String _statsBoxName = 'easy_cache_stats';
  static const String _binaryBoxName = 'easy_cache_binary';

  Box<HiveCacheEntry>? _cacheBox;
  Box<HiveCacheStats>? _statsBox;
  Box<Uint8List>? _binaryBox;
  String? _cacheDirectory;

  HiveCacheStats? _stats;

  @override
  bool get isSupported => true; // Hive supports all platforms

  @override
  String get storageType => 'Hive NoSQL (High-Performance)';

  @override
  Future<void> initialize() async {
    try {
      // Initialize Hive
      if (!Hive.isBoxOpen(_cacheBoxName)) {
        await _initializeHive();

        // Open boxes
        _cacheBox = await Hive.openBox<HiveCacheEntry>(_cacheBoxName);
        _statsBox = await Hive.openBox<HiveCacheStats>(_statsBoxName);
        _binaryBox = await Hive.openBox<Uint8List>(_binaryBoxName);

        // Initialize or load stats
        _stats = _statsBox!.get('main') ?? HiveCacheStats();
        await _statsBox!.put('main', _stats!);

        // Initialize file storage directory for large binaries
        await _initializeCacheDirectory();
      }
    } catch (e) {
      if (loggingEnabled && kDebugMode) {
        debugPrint('HiveCacheStorage: Failed to initialize: $e');
      }
      rethrow;
    }
  }

  Future<void> _initializeHive() async {
    if (kIsWeb) {
      // Web initialization
      await Hive.initFlutter();
    } else {
      // Mobile/Desktop initialization with safe fallbacks for tests
      try {
        final directoryPath =
            await NativeStorageAdapter.getDocumentsDirectory();
        await Hive.initFlutter(directoryPath);
      } catch (e) {
        // Fallback for environments without initialized bindings/plugins (e.g., unit tests)
        final tempDir =
            await Directory.systemTemp.createTemp('easy_cache_hive');
        hive_core.Hive.init(tempDir.path);
      }
    }

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HiveCacheEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HiveCacheStatsAdapter());
    }
  }

  Future<void> _initializeCacheDirectory() async {
    if (kIsWeb) return; // No file system on web
    try {
      final tempDirectoryPath = await NativeStorageAdapter.getCacheDirectory();
      _cacheDirectory = '$tempDirectoryPath/easy_cache_hive';
    } catch (e) {
      // Fallback when path_provider isn't available (e.g., certain test envs)
      final tempDirectory =
          await Directory.systemTemp.createTemp('easy_cache_hive');
      _cacheDirectory = tempDirectory.path;
    }

    final directory = Directory(_cacheDirectory!);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  @override
  Future<void> store(
      String key, dynamic data, Map<String, dynamic> metadata) async {
    try {
      final now = DateTime.now();
      final entryCount = _cacheBox?.length ?? 0;
      const maxEntries = 10000; // default, can be config
      final currentSize = _stats?.totalSizeInBytes ?? 0;
      const maxSize = 100 * 1024 * 1024; // default 100MB

      // Eviction policy check
      if (evictionPolicy != null &&
          evictionPolicy!
              .shouldEvict(key, currentSize, maxSize, entryCount, maxEntries)) {
        final toEvict = evictionPolicy!.selectKeysToEvict(_keyAccessMap, 1);
        for (final k in toEvict) {
          await remove(k);
          analytics?.recordEvent(CacheAnalyticsEvent(type: 'evict', key: k));
        }
      }

      final entry = HiveCacheEntry(
        key: key,
        data: data,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            metadata['created_at'] ?? now.millisecondsSinceEpoch),
        expiresAt: metadata['expires_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(metadata['expires_at'])
            : null,
        headers: metadata['headers'] != null
            ? Map<String, String>.from(metadata['headers'])
            : null,
        etag: metadata['etag'],
        statusCode: metadata['status_code'],
        contentType: metadata['content_type'] ?? 'application/json',
        sizeInBytes: metadata['size_in_bytes'] ?? _calculateSize(data),
        isBinary: false,
      );

      final sw = Stopwatch()..start();
      await _cacheBox!.put(key, entry);
      sw.stop();
      _keyAccessMap[key] = now;
      analytics?.recordEvent(CacheAnalyticsEvent(
          type: 'store',
          key: key,
          sizeBytes: entry.sizeInBytes,
          latency: sw.elapsed));

      // Update stats
      _stats!.totalEntries = _cacheBox!.length;
      _stats!.totalSizeInBytes += entry.sizeInBytes;
      await _statsBox!.put('main', _stats!);
    } catch (e) {
      if (loggingEnabled && kDebugMode) {
        debugPrint('HiveCacheStorage: Failed to store $key: $e');
      }
    }
  }

  @override
  Future<void> storeBytes(
      String key, Uint8List bytes, Map<String, dynamic> metadata) async {
    try {
      final now = DateTime.now();
      String? filePath;

      // For large files, store in file system; small ones in Hive
      const maxInMemorySize = 1024 * 1024; // 1MB threshold

      if (bytes.length > maxInMemorySize && !kIsWeb) {
        // Store large binary in file system
        final fileName = '${key.hashCode}.cache';
        filePath = '${_cacheDirectory!}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(bytes);
      } else {
        // Store in Hive for fast access
        await _binaryBox!.put(key, bytes);
      }

      final entry = HiveCacheEntry(
        key: key,
        data: filePath ?? 'hive_binary_$key',
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            metadata['created_at'] ?? now.millisecondsSinceEpoch),
        expiresAt: metadata['expires_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(metadata['expires_at'])
            : null,
        headers: metadata['headers'] != null
            ? Map<String, String>.from(metadata['headers'])
            : null,
        etag: metadata['etag'],
        statusCode: metadata['status_code'],
        contentType: metadata['content_type'] ?? 'application/octet-stream',
        sizeInBytes: bytes.length,
        isBinary: true,
        filePath: filePath,
      );

      await _cacheBox!.put(key, entry);

      // Update stats
      _stats!.totalEntries = _cacheBox!.length;
      _stats!.totalSizeInBytes += entry.sizeInBytes;
      await _statsBox!.put('main', _stats!);
    } catch (e) {
      if (loggingEnabled && kDebugMode) {
        debugPrint('HiveCacheStorage: Failed to store bytes $key: $e');
      }
    }
  }

  @override
  Future<CacheEntry?> retrieve(String key) async {
    try {
      final sw = Stopwatch()..start();
      final entry = _cacheBox!.get(key);
      sw.stop();
      _keyAccessMap[key] = DateTime.now();
      if (entry == null) {
        _stats!.incrementMiss();
        await _statsBox!.put('main', _stats!);
        analytics?.recordEvent(
            CacheAnalyticsEvent(type: 'miss', key: key, latency: sw.elapsed));
        return null;
      }

      // Check expiration
      if (entry.isExpired) {
        await remove(key);
        _stats!.incrementMiss();
        await _statsBox!.put('main', _stats!);
        analytics?.recordEvent(
            CacheAnalyticsEvent(type: 'miss', key: key, latency: sw.elapsed));
        return null;
      }

      _stats!.incrementHit();
      await _statsBox!.put('main', _stats!);
      analytics?.recordEvent(
          CacheAnalyticsEvent(type: 'hit', key: key, latency: sw.elapsed));

      return entry.toEntity();
    } catch (e) {
      if (loggingEnabled && kDebugMode) {
        debugPrint('HiveCacheStorage: Failed to retrieve $key: $e');
      }
      return null;
    }
  }

  @override
  Future<Uint8List?> retrieveBytes(String key) async {
    try {
      final entry = _cacheBox!.get(key);
      if (entry == null || !entry.isBinary) {
        _stats!.incrementMiss();
        await _statsBox!.put('main', _stats!);
        return null;
      }

      // Check expiration
      if (entry.isExpired) {
        await remove(key);
        _stats!.incrementMiss();
        await _statsBox!.put('main', _stats!);
        return null;
      }

      Uint8List? bytes;

      if (entry.filePath != null) {
        // Load from file
        final file = File(entry.filePath!);
        if (await file.exists()) {
          bytes = await file.readAsBytes();
        }
      } else {
        // Load from Hive
        bytes = _binaryBox!.get(key);
      }

      if (bytes != null) {
        _stats!.incrementHit();
      } else {
        _stats!.incrementMiss();
      }
      await _statsBox!.put('main', _stats!);

      return bytes;
    } catch (e) {
      if (loggingEnabled && kDebugMode) {
        debugPrint('HiveCacheStorage: Failed to retrieve bytes $key: $e');
      }
      return null;
    }
  }

  @override
  Future<bool> exists(String key) async {
    try {
      final entry = _cacheBox!.get(key);
      if (entry == null) return false;

      // Check expiration
      if (entry.isExpired) {
        await remove(key);
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      final entry = _cacheBox!.get(key);
      if (entry != null) {
        // Remove binary data if exists
        if (entry.isBinary) {
          if (entry.filePath != null) {
            final file = File(entry.filePath!);
            if (await file.exists()) {
              await file.delete();
            }
          } else {
            await _binaryBox!.delete(key);
          }
        }

        // Update stats
        _stats!.totalSizeInBytes -= entry.sizeInBytes;
        _stats!.totalEntries = _cacheBox!.length - 1;

        // Remove from cache
        await _cacheBox!.delete(key);
        await _statsBox!.put('main', _stats!);
        _keyAccessMap.remove(key);
        analytics?.recordEvent(CacheAnalyticsEvent(type: 'evict', key: key));
      }
    } catch (e) {
      if (loggingEnabled && kDebugMode) {
        debugPrint('HiveCacheStorage: Failed to remove $key: $e');
      }
    }
  }

  @override
  Future<void> clear() async {
    try {
      // Clear all boxes
      await _cacheBox!.clear();
      await _binaryBox!.clear();

      // Clear file directory
      if (_cacheDirectory != null) {
        final directory = Directory(_cacheDirectory!);
        if (await directory.exists()) {
          await directory.delete(recursive: true);
          await directory.create(recursive: true);
        }
      }

      // Reset stats
      _stats!.reset();
      await _statsBox!.put('main', _stats!);
    } catch (e) {
      if (loggingEnabled && kDebugMode) {
        debugPrint('HiveCacheStorage: Failed to clear: $e');
      }
    }
  }

  @override
  Future<List<String>> getAllKeys() async {
    try {
      // Ensure initialization is complete
      if (_cacheBox == null) {
        await initialize();
      }
      return _cacheBox?.keys.cast<String>().toList() ?? [];
    } catch (e) {
      if (loggingEnabled && kDebugMode) {
        debugPrint('HiveCacheStorage: Failed to get all keys: $e');
      }
      return [];
    }
  }

  @override
  Future<CacheStats> getStats() async {
    try {
      // Ensure initialization is complete
      if (_cacheBox == null || _statsBox == null || _stats == null) {
        await initialize();
        _stats ??= HiveCacheStats();
      }

      // Update real-time stats safely
      _stats!.totalEntries = _cacheBox?.length ?? 0;

      // Calculate total size from all entries
      int totalSize = 0;
      if (_cacheBox != null) {
        for (final entry in _cacheBox!.values) {
          totalSize += entry.sizeInBytes;
        }
      }
      _stats!.totalSizeInBytes = totalSize;

      // Save stats if possible
      if (_statsBox != null) {
        await _statsBox!.put('main', _stats!);
      }

      return _stats!.toEntity();
    } catch (e) {
      if (loggingEnabled && kDebugMode) {
        debugPrint('HiveCacheStorage: Failed to get stats: $e');
      }
      // Return safe default stats
      return CacheStats(
        totalEntries: 0,
        totalSizeInBytes: 0,
        hitCount: 0,
        missCount: 0,
        evictionCount: 0,
        hitRate: 0.0,
        lastCleanup: DateTime.now(),
        averageLoadTime: Duration.zero,
      );
    }
  }

  @override
  Future<void> cleanup() async {
    try {
      final now = DateTime.now();
      final expiredKeys = <String>[];
      int cleanedSize = 0;

      // Find expired entries (super fast iteration)
      for (final entry in _cacheBox!.values) {
        if (entry.isExpired) {
          expiredKeys.add(entry.key);
          cleanedSize += entry.sizeInBytes;
        }
      }

      // Remove expired entries
      for (final key in expiredKeys) {
        await remove(key);
      }

      // Policy-based cleanup (e.g. max entries)
      if (evictionPolicy != null) {
        final entryCount = _cacheBox?.length ?? 0;
        const maxEntries = 10000;
        if (evictionPolicy!.shouldEvict('', 0, 0, entryCount, maxEntries)) {
          final toEvict = evictionPolicy!
              .selectKeysToEvict(_keyAccessMap, entryCount - maxEntries);
          for (final k in toEvict) {
            await remove(k);
          }
        }
      }

      // Update cleanup stats
      _stats!.incrementEviction(expiredKeys.length);
      _stats!.lastCleanup = now;
      _stats!.totalSizeInBytes -= cleanedSize;
      await _statsBox!.put('main', _stats!);
    } catch (e) {
      if (loggingEnabled && kDebugMode) {
        debugPrint('HiveCacheStorage: Failed to cleanup: $e');
      }
    }
  }

  @override
  Future<int> getTotalSize() async {
    final stats = await getStats();
    return stats.totalSizeInBytes;
  }

  @override
  Future<int> getEntryCount() async {
    return _cacheBox?.length ?? 0;
  }

  @override
  Future<void> dispose() async {
    try {
      await _cacheBox?.close();
      await _statsBox?.close();
      await _binaryBox?.close();

      _cacheBox = null;
      _statsBox = null;
      _binaryBox = null;
      _stats = null;
    } catch (e) {
      if (loggingEnabled && kDebugMode) {
        debugPrint('HiveCacheStorage: Failed to dispose: $e');
      }
    }
  }

  // Private helper methods
  int _calculateSize(dynamic data) {
    if (data is String) {
      return utf8.encode(data).length;
    } else if (data is Map || data is List) {
      try {
        return utf8.encode(jsonEncode(data)).length;
      } catch (e) {
        return data.toString().length;
      }
    }
    return data.toString().length;
  }

  /// Get detailed performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'storage_type': storageType,
      'total_entries': _cacheBox?.length ?? 0,
      'binary_entries': _binaryBox?.length ?? 0,
      'hit_rate': _stats?.hitRate ?? 0.0,
      'average_load_time_ms': _stats != null
          ? _stats!.toEntity().averageLoadTime.inMilliseconds
          : 0,
      'last_cleanup': _stats?.lastCleanup.toIso8601String(),
      'platform_optimized': !kIsWeb, // File system optimization available
    };
  }
}
