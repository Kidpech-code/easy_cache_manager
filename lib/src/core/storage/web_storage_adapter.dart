import 'package:web/web.dart' as web;
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Web-specific storage adapter for WASM compatibility
///
/// This adapter provides localStorage support for Web platform
/// without depending on path_provider, ensuring full WASM compatibility.
class WebStorageAdapter {
  static const String _keyPrefix = 'easy_cache_';

  /// Initialize web storage - no-op for web as localStorage is always available
  static Future<void> initialize() async {
    // Web storage (localStorage) is always available
    // No initialization required for WASM compatibility
  }

  /// Save data to localStorage for WASM compatibility
  static Future<void> saveData(String key, Map<String, dynamic> data) async {
    try {
      final jsonString = jsonEncode(data);
      web.window.localStorage.setItem(_keyPrefix + key, jsonString);
    } catch (e) {
      if (kDebugMode) {
        print('WebStorageAdapter: Error saving $key: $e');
      }
      rethrow;
    }
  }

  /// Load data from localStorage for WASM compatibility
  static Future<Map<String, dynamic>?> loadData(String key) async {
    try {
      final jsonString = web.window.localStorage.getItem(_keyPrefix + key);
      if (jsonString == null) return null;

      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('WebStorageAdapter: Error loading $key: $e');
      }
      return null;
    }
  }

  /// Remove data from localStorage
  static Future<void> removeData(String key) async {
    web.window.localStorage.removeItem(_keyPrefix + key);
  }

  /// Clear all cache data from localStorage
  static Future<void> clearAll() async {
    final keysToRemove = <String>[];
    for (int i = 0; i < web.window.localStorage.length; i++) {
      final key = web.window.localStorage.key(i);
      if (key != null && key.startsWith(_keyPrefix)) {
        keysToRemove.add(key);
      }
    }

    for (final key in keysToRemove) {
      web.window.localStorage.removeItem(key);
    }
  }

  /// Get all keys with the cache prefix
  static List<String> getAllKeys() {
    final keys = <String>[];
    for (int i = 0; i < web.window.localStorage.length; i++) {
      final key = web.window.localStorage.key(i);
      if (key != null && key.startsWith(_keyPrefix)) {
        keys.add(key.substring(_keyPrefix.length));
      }
    }
    return keys;
  }

  /// Check if a key exists in localStorage
  static bool containsKey(String key) {
    return web.window.localStorage.getItem(_keyPrefix + key) != null;
  }

  /// Get storage size estimation for performance monitoring
  static int getStorageSize() {
    int totalSize = 0;
    for (int i = 0; i < web.window.localStorage.length; i++) {
      final key = web.window.localStorage.key(i);
      if (key != null && key.startsWith(_keyPrefix)) {
        final value = web.window.localStorage.getItem(key);
        if (value != null) {
          totalSize += value.length * 2; // Rough estimate (UTF-16)
        }
      }
    }
    return totalSize;
  }
}
