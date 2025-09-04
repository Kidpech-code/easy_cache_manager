/// Simple key-value storage for SimpleCacheManager
///
/// This provides a direct key-value storage interface that's separate from
/// the URL-based caching system, perfect for beginners who want to store
/// arbitrary data with simple keys.
library simple_cache_storage;

import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

// This module uses path_provider conditionally for native platforms
import 'web_path_provider.dart' // Web-compatible path provider
    if (dart.library.io) 'package:path_provider/path_provider.dart' // Native path provider
    as path_provider; // Unified import name

/// Simple storage interface for key-value data
abstract class SimpleCacheStorageInterface {
  /// Initialize the storage
  Future<void> init();

  /// Store JSON data with a key
  Future<void> setJson(String key, Map<String, dynamic> data);

  /// Retrieve JSON data by key
  Future<Map<String, dynamic>?> getJson(String key);

  /// Store string data with a key
  Future<void> setString(String key, String data);

  /// Retrieve string data by key
  Future<String?> getString(String key);

  /// Store integer data with a key
  Future<void> setInt(String key, int data);

  /// Retrieve integer data by key
  Future<int?> getInt(String key);

  /// Store boolean data with a key
  Future<void> setBool(String key, bool data);

  /// Retrieve boolean data by key
  Future<bool?> getBool(String key);

  /// Store binary data with a key
  Future<void> setBytes(String key, Uint8List data);

  /// Retrieve binary data by key
  Future<Uint8List?> getBytes(String key);

  /// Check if a key exists
  Future<bool> contains(String key);

  /// Remove data by key
  Future<void> remove(String key);

  /// Clear all data
  Future<void> clear();

  /// Get all keys
  Future<List<String>> getAllKeys();

  /// Get storage stats
  Future<Map<String, dynamic>> getStats();

  /// Close the storage
  Future<void> close();
}

/// Hive-based implementation of SimpleCacheStorageInterface
class SimpleCacheStorage implements SimpleCacheStorageInterface {
  static const String _boxName = 'simple_cache_box';
  Box<dynamic>? _box;
  bool _initialized = false;

  /// Check if storage is initialized
  bool get isInitialized => _initialized;

  @override
  Future<void> init() async {
    if (_initialized) return;

    try {
      // Initialize Hive if not already initialized
      // For testing environment, we'll use in-memory storage
      if (!Hive.isBoxOpen(_boxName)) {
        try {
          // Try to initialize for Flutter first
          if (!Hive.isAdapterRegistered(0)) {
            await Hive.initFlutter();
          }
        } catch (e) {
          // If Flutter initialization fails (like in testing), use regular Hive
          // This is common in unit tests where Flutter bindings aren't available
          try {
            final tempDir = await path_provider.getTemporaryDirectory();
            final tempPath = tempDir.path;
            Hive.init(tempPath);
          } catch (initError) {
            // If both fail, we'll use in-memory storage
            if (kDebugMode) {
              debugPrint('SimpleCacheStorage: fallback to in-memory (temp) failed: $initError');
            }
          }
        }

        _box = await Hive.openBox<dynamic>(_boxName);
      } else {
        _box = Hive.box<dynamic>(_boxName);
      }

      _initialized = true;
    } catch (e) {
      throw Exception('Failed to initialize SimpleCacheStorage: $e');
    }
  }

  /// Ensure storage is initialized
  void _ensureInitialized() {
    if (!_initialized || _box == null) {
      throw StateError('SimpleCacheStorage not initialized. Call init() first.');
    }
  }

  @override
  Future<void> setJson(String key, Map<String, dynamic> data) async {
    _ensureInitialized();
    try {
      final jsonString = jsonEncode(data);
      await _box!.put('json_$key', jsonString);
    } catch (e) {
      throw Exception('Failed to store JSON data for key "$key": $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    _ensureInitialized();
    try {
      final jsonString = _box!.get('json_$key');
      if (jsonString == null) return null;

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // Return null if data is corrupted or can't be parsed
      return null;
    }
  }

  @override
  Future<void> setString(String key, String data) async {
    _ensureInitialized();
    try {
      await _box!.put('string_$key', data);
    } catch (e) {
      throw Exception('Failed to store string data for key "$key": $e');
    }
  }

  @override
  Future<String?> getString(String key) async {
    _ensureInitialized();
    return _box!.get('string_$key');
  }

  @override
  Future<void> setInt(String key, int data) async {
    _ensureInitialized();
    try {
      await _box!.put('int_$key', data);
    } catch (e) {
      throw Exception('Failed to store int data for key "$key": $e');
    }
  }

  @override
  Future<int?> getInt(String key) async {
    _ensureInitialized();
    return _box!.get('int_$key');
  }

  @override
  Future<void> setBool(String key, bool data) async {
    _ensureInitialized();
    try {
      await _box!.put('bool_$key', data);
    } catch (e) {
      throw Exception('Failed to store bool data for key "$key": $e');
    }
  }

  @override
  Future<bool?> getBool(String key) async {
    _ensureInitialized();
    return _box!.get('bool_$key');
  }

  @override
  Future<void> setBytes(String key, Uint8List data) async {
    _ensureInitialized();
    try {
      await _box!.put('bytes_$key', data);
    } catch (e) {
      throw Exception('Failed to store bytes data for key "$key": $e');
    }
  }

  @override
  Future<Uint8List?> getBytes(String key) async {
    _ensureInitialized();
    final data = _box!.get('bytes_$key');
    if (data == null) return null;

    // Convert to Uint8List if needed
    if (data is Uint8List) return data;
    if (data is List<int>) return Uint8List.fromList(data);

    return null;
  }

  @override
  Future<bool> contains(String key) async {
    _ensureInitialized();

    // Check all possible prefixes
    return _box!.containsKey('json_$key') ||
        _box!.containsKey('string_$key') ||
        _box!.containsKey('int_$key') ||
        _box!.containsKey('bool_$key') ||
        _box!.containsKey('bytes_$key');
  }

  @override
  Future<void> remove(String key) async {
    _ensureInitialized();
    try {
      // Remove all possible prefixed versions
      await _box!.delete('json_$key');
      await _box!.delete('string_$key');
      await _box!.delete('int_$key');
      await _box!.delete('bool_$key');
      await _box!.delete('bytes_$key');
    } catch (e) {
      throw Exception('Failed to remove data for key "$key": $e');
    }
  }

  @override
  Future<void> clear() async {
    _ensureInitialized();
    try {
      await _box!.clear();
    } catch (e) {
      throw Exception('Failed to clear SimpleCacheStorage: $e');
    }
  }

  @override
  Future<List<String>> getAllKeys() async {
    _ensureInitialized();
    try {
      final keys = <String>{};

      // Extract original keys by removing prefixes
      for (final key in _box!.keys) {
        if (key is String) {
          if (key.startsWith('json_')) {
            keys.add(key.substring(5));
          } else if (key.startsWith('string_')) {
            keys.add(key.substring(7));
          } else if (key.startsWith('int_')) {
            keys.add(key.substring(4));
          } else if (key.startsWith('bool_')) {
            keys.add(key.substring(5));
          } else if (key.startsWith('bytes_')) {
            keys.add(key.substring(6));
          }
        }
      }

      return keys.toList()..sort();
    } catch (e) {
      throw Exception('Failed to get all keys: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getStats() async {
    _ensureInitialized();
    try {
      final keys = _box!.keys.length;
      final jsonCount = _box!.keys.where((k) => k.toString().startsWith('json_')).length;
      final stringCount = _box!.keys.where((k) => k.toString().startsWith('string_')).length;
      final intCount = _box!.keys.where((k) => k.toString().startsWith('int_')).length;
      final boolCount = _box!.keys.where((k) => k.toString().startsWith('bool_')).length;
      final bytesCount = _box!.keys.where((k) => k.toString().startsWith('bytes_')).length;

      // Calculate approximate size
      int totalSize = 0;
      for (final value in _box!.values) {
        if (value is String) {
          totalSize += value.length * 2; // Rough UTF-16 estimate
        } else if (value is Uint8List) {
          totalSize += value.length;
        } else if (value is List<int>) {
          totalSize += value.length;
        } else {
          totalSize += 64; // Rough estimate for other types
        }
      }

      return {
        'totalEntries': keys,
        'jsonEntries': jsonCount,
        'stringEntries': stringCount,
        'intEntries': intCount,
        'boolEntries': boolCount,
        'bytesEntries': bytesCount,
        'approximateSizeBytes': totalSize,
        'approximateSizeMB': (totalSize / 1024 / 1024).toStringAsFixed(2),
      };
    } catch (e) {
      throw Exception('Failed to get storage stats: $e');
    }
  }

  @override
  Future<void> close() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
    }
    _initialized = false;
    _box = null;
  }
}
