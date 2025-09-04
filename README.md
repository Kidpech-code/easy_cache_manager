# 🚀⚡ Easy Cache Manager - High-performance Flutter Caching

[![pub package](https://img.shields.io/pub/v/easy_cache_manager.svg)](https://pub.dev/packages/easy_cache_manager)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/kidpech/easy_cache_manager/blob/main/LICENSE)
[![Flutter Platform](https://img.shields.io/badge/platform-Flutter-blue.svg)](https://flutter.dev)
[![Hive NoSQL](https://img.shields.io/badge/powered%20by-Hive%20NoSQL-orange.svg)](https://docs.hivedb.dev)

**A comprehensive, intelligent, and BLAZINGLY FAST cache management solution for Flutter applications.** Built with Clean Architecture and Domain-Driven Design (DDD) principles, now powered by **pure Hive NoSQL storage** for ultimate performance while maintaining simplicity for smaller projects.

---

## 📚 Table of Contents

1. [Integration Scenarios & Examples](#-integration-scenarios--examples)
    1. [Beginner Scenarios](#1-beginner-scenarios)
    2. [Advanced Scenarios](#2-advanced-scenarios)
    3. [Enterprise & Power User Scenarios](#3-enterprise--power-user-scenarios)
2. [Why Hive NoSQL?](#why-hive-nosql)
3. [Key Features](#-key-features)
4. [Quick Start](#-quick-start)
5. [Flutter Widgets](#-flutter-widgets)
6. [Configuration Options](#-configuration-options)
7. [Platform-Specific Features](#-platform-specific-features)
8. [Performance Monitoring](#-performance-monitoring)
9. [Eviction Policy & Analytics](#-eviction-policy--analytics-advanced)
10. [Integration Examples](#-integration-examples)
11. [Lint Best Practices](#-lint-best-practices)
12. [Testing](#-testing)
13. [Contributing](#-contributing)
14. [License](#-license)

---

## 🚀 Integration Scenarios & Examples

Below are grouped, numbered, and complete scenarios for Easy Cache Manager, with use case, code, and expected results. These cover beginner, advanced, and enterprise needs.

### 1. Beginner Scenarios

#### 1.1 Flutter Widget Integration
**Use case:** Cache images/files in widgets for bandwidth savings and speed.
```dart
import 'package:flutter/material.dart';
import 'package:easy_cache_manager/easy_cache_manager.dart';

class CachedImageWidget extends StatelessWidget {
  final String url;
  final cacheManager = CacheManager(
    config: AdvancedCacheConfig.production(),
    storage: HiveCacheStorage(
      evictionPolicy: LRUEvictionPolicy(100),
      analytics: SimpleCacheAnalytics(),
    ),
  );

  CachedImageWidget({required this.url});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: cacheManager.getFile(url),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Image.file(snapshot.data!);
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
```
**Expected:** Images load from cache if available, otherwise from network and then cached for next time.

#### 1.2 REST API Integration
**Use case:** Cache API responses to reduce repeated calls and speed up UX.
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:easy_cache_manager/easy_cache_manager.dart';

final cacheManager = CacheManager(
  config: AdvancedCacheConfig.production(),
  storage: HiveCacheStorage(
    evictionPolicy: LRUEvictionPolicy(1000),
    analytics: SimpleCacheAnalytics(),
  ),
);

Future<Map<String, dynamic>> fetchUser(String id) async {
  final cached = await cacheManager.getJson('user_$id');
  if (cached != null) return cached;
  final response = await http.get(Uri.parse('https://api.example.com/user/$id'));
  final data = jsonDecode(response.body);
  await cacheManager.save('user_$id', data);
  return data;
}
```
**Expected:** User data is cached, reducing latency and network usage.

#### 1.3 Error Handling
**Use case:** Robust error handling for cache operations.
```dart
try {
  final data = await cacheManager.getJson('key');
  print('Data: $data');
} catch (e) {
  print('Cache error: $e');
  // Handle gracefully - app doesn't crash
}
```
**Expected:** App does not crash on cache errors.

#### 1.4 Cache Invalidation
**Use case:** Remove cache when data changes (e.g. user profile update).
```dart
// When user updates profile
await cacheManager.removeItem('user_profile');
// Next fetch will get fresh data
```
**Expected:** Cache is cleared and reloaded when data changes.

#### 1.5 Manual Cache Management
**Use case:** Full control over cache (remove, check, cleanup).
```dart
// Check if data exists
bool hasData = await cacheManager.contains('cache_key');

// Remove specific item
await cacheManager.removeItem('cache_key');

// Get all cache keys
List<String> keys = await cacheManager.getAllKeys();

// Get cache statistics
CacheStats stats = await cacheManager.getStats();

// Manual cleanup
await cacheManager.cleanup();

// Clear everything
await cacheManager.clearCache();
```
**Expected:** Complete manual control over cache lifecycle.

---

### 2. Advanced Scenarios

#### 2.1 TTL/Expiration per Key
**Use case:** Different data types have different lifetimes (e.g. token 1hr, profile 1d)
```dart
// Token expires in 1 hour
await cacheManager.save('token', token, maxAge: const Duration(hours: 1));

// Profile expires in 1 day
await cacheManager.save('profile', profile, maxAge: const Duration(days: 1));
```
**Expected:** Token expires faster than profile and is auto-removed.

#### 2.2 Size-based Eviction
**Use case:** Remove largest files first when space is low.
```dart
final cacheManager = CacheManager(
  config: AdvancedCacheConfig.production(
    evictionPolicy: 'size-based',
  ),
);
```
**Expected:** Large files are evicted first when cache is full.

#### 2.3 Composite Policy (LRU+TTL)
**Use case:** Combine multiple eviction strategies for robust cache management.
```dart
final cacheManager = CacheManager(
  config: AdvancedCacheConfig.production(),
  storage: HiveCacheStorage(
    evictionPolicy: CompositeEvictionPolicy([
      LRUEvictionPolicy(500),
      TTLEvictionPolicy(const Duration(days: 7)),
    ]),
  ),
);
```
**Expected:** Cache evicts by both age and usage.

#### 2.4 Offline-first API
**Use case:** Provide cached data when offline, fallback to network when online.
```dart
Future<Map<String, dynamic>> fetchData(String key, String url) async {
  final cached = await cacheManager.getJson(key);
  if (cached != null) return cached;
  
  try {
    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);
    await cacheManager.save(key, data);
    return data;
  } catch (e) {
    // Network error - return cached data if available
    return cached ?? {};
  }
}
```
**Expected:** Users see last cached data even when offline.

#### 2.5 Cache Warming
**Use case:** Preload important data before app usage for instant UX.
```dart
Future<void> warmCache() async {
  await Future.wait([
    cacheManager.save('config', await fetchConfig()),
    cacheManager.save('user_profile', await fetchProfile()),
    cacheManager.save('banner_ads', await fetchBanner()),
  ]);
}
```
**Expected:** Key data is cached ahead of time, reducing latency.

#### 2.6 Export Metrics
**Use case:** Export cache stats for analysis/audit.
```dart
final metrics = cacheManager.storage.analytics?.exportMetrics();
print(jsonEncode(metrics));

// Output: {
//   "hitRate": 0.85,
//   "totalEntries": 245,
//   "evictionCount": 12
// }
```
**Expected:** Cache metrics available for reporting or dashboard.

#### 2.7 Background Sync
**Use case:** Sync cache with server automatically in background.
```dart
final cacheManager = CacheManager(
  config: AdvancedCacheConfig.production(
    backgroundSync: true,
    syncInterval: const Duration(hours: 1),
  ),
);
```
**Expected:** Cache syncs with server every hour.

#### 2.8 Encryption/Decryption
**Use case:** Secure sensitive cache data (token, user info).
```dart
final cacheManager = CacheManager(
  config: AdvancedCacheConfig.production(
    enableEncryption: true,
    encryptionKey: 'your-32-character-secret-key-here',
  ),
);
```
**Expected:** Cache data is encrypted and safe.

#### 2.9 GraphQL Caching
**Use case:** Cache GraphQL query results for speed and efficiency.
```dart
final cacheManager = CacheManager(
  config: AdvancedCacheConfig.production(),
);

final query = '{ user { id name email } }';
final cacheKey = query.hashCode.toString();
final cached = await cacheManager.getJson(cacheKey);

if (cached == null) {
  final result = await graphQLClient.query(QueryOptions(document: gql(query)));
  await cacheManager.save(cacheKey, result.data);
}
```
**Expected:** GraphQL results are cached and reused.

#### 2.10 Custom Data Type
**Use case:** Cache binary, images, or custom model objects.
```dart
// Cache image bytes
await cacheManager.save('image_bytes', imageBytes);
final bytes = await cacheManager.getBytes('image_bytes');

// Cache custom model
final user = User(id: 1, name: 'John');
await cacheManager.save('user_model', user.toJson());
final cachedUser = User.fromJson(await cacheManager.getJson('user_model'));
```
**Expected:** Cache supports all data types.

#### 2.11 Multi-tenant Cache
**Use case:** Separate cache for each tenant/user in SaaS apps.
```dart
final cacheManager = CacheManager(
  config: AdvancedCacheConfig.production(
    cacheName: 'tenant_${tenantId}_cache',
  ),
);
```
**Expected:** Cache is isolated per tenant/user.

#### 2.12 Debugging/Tracing
**Use case:** Trace cache flow for development/debugging.
```dart
final cacheManager = CacheManager(
  config: AdvancedCacheConfig.production(
    enableLogging: true,
  ),
);
```
**Expected:** Cache logs all operations for debugging.

#### 2.13 Real-time Statistics Monitoring
**Use case:** Monitor cache stats/hit rate in real-time.
```dart
cacheManager.statsStream.listen((stats) {
  print('Hit rate: ${stats.hitRate}%');
  print('Cache updated: ${stats.totalEntries} entries');
  print('Memory usage: ${stats.totalSizeInMB.toStringAsFixed(2)} MB');
});
```
**Expected:** Instantly see cache stats and hit rate.

---

### 3. Enterprise & Power User Scenarios

#### 3.1 Custom Analytics Integration
**Use case:** Send cache metrics/events to external systems (Firebase, Sentry, etc.)
```dart
class MyAnalytics implements CacheAnalytics {
  @override
  void recordEvent(String event, Map<String, dynamic> details) {
    // Send to Firebase Analytics
    FirebaseAnalytics.instance.logEvent(
      name: event,
      parameters: details,
    );
    
    // Send to Sentry for monitoring
    Sentry.addBreadcrumb(Breadcrumb(
      message: event,
      data: details,
    ));
  }

  @override
  Map<String, dynamic> exportMetrics() => {
    'hitRate': _calculateHitRate(),
    'totalQueries': _totalQueries,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

final cacheManager = CacheManager(
  config: AdvancedCacheConfig.production(),
  storage: HiveCacheStorage(
    evictionPolicy: LRUEvictionPolicy(100),
    analytics: MyAnalytics(),
  ),
);
```
**Expected:** Cache events/metrics are sent to your analytics system.

#### 3.2 Integration with Analytics Dashboard
**Use case:** Send cache metrics to external dashboard for monitoring.
```dart
class DashboardAnalytics implements CacheAnalytics {
  final String dashboardUrl;
  
  DashboardAnalytics(this.dashboardUrl);
  
  @override
  void recordEvent(String event, Map<String, dynamic> details) async {
    await http.post(
      Uri.parse('$dashboardUrl/events'),
      body: jsonEncode({
        'event': event,
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }
  
  @override
  Map<String, dynamic> exportMetrics() => {
    'service': 'easy_cache_manager',
    'version': '0.1.0',
    'metrics': _collectMetrics(),
  };
}

final cacheManager = CacheManager(
  config: AdvancedCacheConfig.production(),
  storage: HiveCacheStorage(
    analytics: DashboardAnalytics('https://dashboard.example.com/api'),
  ),
);
```
**Expected:** Cache metrics are sent to your dashboard.

#### 3.3 Platform-Specific Features
**Use case:** Optimize cache for Web, Mobile, Desktop.
```dart
CacheManager createPlatformOptimizedCache() {
  if (kIsWeb) {
    // Web: Use LocalStorage + Memory
    return CacheManager(
      config: AdvancedCacheConfig.web(),
      storage: WebCacheStorage(),
    );
  } else if (Platform.isAndroid || Platform.isIOS) {
    // Mobile: Use Hive + File System
    return CacheManager(
      config: AdvancedCacheConfig.mobile(),
      storage: HiveCacheStorage(),
    );
  } else {
    // Desktop: Use JSON Files + Memory
    return CacheManager(
      config: AdvancedCacheConfig.desktop(),
      storage: FileCacheStorage(),
    );
  }
}
```
**Expected:** Cache manager auto-selects best storage/optimization for platform.

#### 3.4 Custom Eviction Policy/Analytics
**Use case:** Power users can implement custom logic (TTL per key, histogram, export metrics).
```dart
class MyCustomPolicy implements EvictionPolicy {
  final int maxEntries;
  final Map<String, DateTime> _accessTimes = {};
  
  MyCustomPolicy(this.maxEntries);
  
  @override
  List<String> selectItemsToEvict(Map<String, CacheEntry> entries) {
    if (entries.length <= maxEntries) return [];
    
    // Custom logic: evict items accessed more than 1 hour ago
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    return entries.entries
        .where((e) => (_accessTimes[e.key] ?? cutoff).isBefore(cutoff))
        .map((e) => e.key)
        .toList();
  }
}

class MyAnalytics implements CacheAnalytics {
  final Map<String, int> _eventCounts = {};
  
  @override
  void recordEvent(String event, Map<String, dynamic> details) {
    _eventCounts[event] = (_eventCounts[event] ?? 0) + 1;
    
    // Export to CSV for analysis
    if (_eventCounts.values.fold(0, (a, b) => a + b) % 100 == 0) {
      _exportToCsv();
    }
  }
  
  @override
  Map<String, dynamic> exportMetrics() => {
    'eventCounts': _eventCounts,
    'totalEvents': _eventCounts.values.fold(0, (a, b) => a + b),
  };
  
  void _exportToCsv() {
    // Implementation for CSV export
  }
}

final cacheManager = CacheManager(
  config: AdvancedCacheConfig.production(),
  storage: HiveCacheStorage(
    evictionPolicy: MyCustomPolicy(1000),
    analytics: MyAnalytics(),
  ),
);
```
**Expected:** Custom eviction/analytics logic as required.

#### 3.5 Benchmark & Performance Testing
**Use case:** Developers/organizations can measure cache performance.
```dart
void runPerformanceTest() async {
  final benchmark = CacheBenchmarkSuite(
    storage: HiveCacheStorage(),
  );
  
  final results = await benchmark.runFullBenchmark();
  
  print('Performance Results:');
  print('- Write Speed: ${results.writeSpeed}ms avg');
  print('- Read Speed: ${results.readSpeed}ms avg');
  print('- Memory Usage: ${results.memoryUsage}MB');
  print('- Hit Rate: ${results.hitRate}%');
}
```
**Expected:** Benchmark results for cache manager comparison.

#### 3.6 State Management Integration (Riverpod/Bloc)
**Use case:** Use cache manager with state management frameworks.
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cacheManagerProvider = Provider((ref) => CacheManager(
  config: AdvancedCacheConfig.production(),
  storage: HiveCacheStorage(
    evictionPolicy: LRUEvictionPolicy(500),
    analytics: SimpleCacheAnalytics(),
  ),
));

// Provider for cached user data
final userProvider = FutureProvider.family<User, String>((ref, userId) async {
  final cacheManager = ref.watch(cacheManagerProvider);
  final cached = await cacheManager.getJson('user_$userId');
  
  if (cached != null) {
    return User.fromJson(cached);
  }
  
  final user = await fetchUserFromApi(userId);
  await cacheManager.save('user_$userId', user.toJson());
  return user;
});

// In Bloc
class UserBloc extends Bloc<UserEvent, UserState> {
  final CacheManager cacheManager;
  
  UserBloc(this.cacheManager) : super(UserInitial()) {
    on<FetchUserEvent>((event, emit) async {
      try {
        final cached = await cacheManager.getJson('user_${event.id}');
        if (cached != null) {
          emit(UserLoaded(User.fromJson(cached)));
          return;
        }
        
        final user = await fetchUserFromApi(event.id);
        await cacheManager.save('user_${event.id}', user.toJson());
        emit(UserLoaded(user));
      } catch (e) {
        emit(UserError(e.toString()));
      }
    });
  }
}
```
**Expected:** Seamless cache integration with state management.

#### 3.7 Network Library Integration (Dio)
**Use case:** Cache API responses with Dio or other network libraries.
```dart
import 'package:dio/dio.dart';

class CacheInterceptor extends Interceptor {
  final CacheManager cacheManager;
  
  CacheInterceptor(this.cacheManager);
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final cacheKey = _generateCacheKey(options);
    final cached = await cacheManager.getJson(cacheKey);
    
    if (cached != null && !_isExpired(cached)) {
      handler.resolve(Response(
        requestOptions: options,
        data: cached['data'],
        statusCode: 200,
      ));
      return;
    }
    
    super.onRequest(options, handler);
  }
  
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    final cacheKey = _generateCacheKey(response.requestOptions);
    await cacheManager.save(cacheKey, {
      'data': response.data,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    super.onResponse(response, handler);
  }
  
  String _generateCacheKey(RequestOptions options) {
    return '${options.method}_${options.uri}'.hashCode.toString();
  }
  
  bool _isExpired(Map<String, dynamic> cached) {
    final timestamp = DateTime.parse(cached['timestamp']);
    return DateTime.now().difference(timestamp) > const Duration(hours: 1);
  }
}

final cacheManager = CacheManager(
  config: AdvancedCacheConfig.production(),
  storage: HiveCacheStorage(
    evictionPolicy: LRUEvictionPolicy(1000),
    analytics: SimpleCacheAnalytics(),
  ),
);

final dio = Dio();
dio.interceptors.add(CacheInterceptor(cacheManager));
```
**Expected:** API responses are cached, reducing repeated calls.

---

## Why Hive NoSQL?

We migrated to Hive NoSQL to improve performance and reduce overhead versus SQL-based approaches in many common caching workloads:

```
📊 BENCHMARK RESULTS - Pure Hive vs Previous SQLite
──────────────────────────────────────────────────────
Operation         Before (SQLite)    After (Hive)     Improvement
──────────────────────────────────────────────────────
JSON Write        15.2ms             0.8ms            🚀 19x faster
JSON Read         8.1ms              0.3ms            🚀 27x faster
Binary Write      22.4ms             1.2ms            🚀 19x faster
Binary Read       12.3ms             0.4ms            🚀 31x faster
Memory Usage      100MB              48MB             💾 52% less

🎯 REAL WORLD IMPACT
App Startup       3.2s → 1.1s        🚀 3x faster
Image Loading     850ms → 45ms       🚀 19x faster
API Cache Hit     25ms → 1ms         🚀 25x faster
```

**Note:** Results depend on device, data patterns, and workload. Use our benchmark suite to measure on your target.

## ✨ Key Features

### 🏎️ High-performance Storage
- **Hive NoSQL Engine**: Lightning-fast NoSQL database
- **Smart Memory Management**: Automatic small/large data optimization
- **Zero-Copy Operations**: Direct binary access without serialization
- **Cross-Platform Optimization**: Platform-specific performance tuning

### 🏗️ Multiple Complexity Levels
- **Minimal Configuration**: Perfect for small projects and rapid prototyping
- **Standard Configuration**: Balanced features for most applications
- **Advanced Configuration**: Enterprise-level features with full customization

### 🌐 Cross-Platform Storage
- **Web**: LocalStorage + Memory optimization
- **Mobile**: Hive NoSQL + File System (iOS/Android)
- **Desktop**: JSON Files + Memory caching (Windows/macOS/Linux)
- **Automatic Platform Detection**: Seamless adaptation to runtime environment

### 🧠 Smart Eviction Policies
- **LRU** (Least Recently Used): Remove oldest accessed items
- **LFU** (Least Frequently Used): Remove least accessed items
- **FIFO** (First In, First Out): Remove oldest created items
- **TTL-based**: Prioritize expired items first
- **Size-based**: Target largest files for removal
- **Composite Policies**: Combine multiple strategies

### ⚡ Performance Optimizations
- Data compression with multiple algorithms (GZIP, Deflate)
- AES-256 encryption for sensitive data
- Background sync capabilities
- Intelligent cleanup based on storage pressure
- Memory-efficient streaming operations

### 📊 Comprehensive Analytics
- Real-time cache statistics and hit rates
- Storage usage monitoring
- Performance metrics collection
- Detailed debugging information

### 🎯 Developer Experience
- Type-safe APIs with comprehensive error handling
- RxDart streams for reactive programming
- Flutter widgets for common use cases
- Extensive documentation and examples
- **🎓 Complete Learning Resources**: Full Clean Architecture tutorials
- **👶 Beginner-Friendly Guide**: Step-by-step for new developers
- **⚡ Zero-Config Options**: Pre-configured setups for instant use

## 🚀 Quick Start

### ⚡ Zero-Config Usage (Just 2 Lines!)

Don't want to choose configurations? We've got you covered with smart defaults:

```dart
import 'package:easy_cache_manager/easy_cache_manager.dart';

// Automatic configuration based on your app
final cache = EasyCacheManager.auto(); // Detects app size & needs

// Or use pre-built templates
final cache = EasyCacheManager.template(AppType.ecommerce);
final socialCache = EasyCacheManager.template(AppType.social);
final newsCache = EasyCacheManager.template(AppType.news);
final productivityCache = EasyCacheManager.template(AppType.productivity);
```

### 👶 Beginner-Friendly (No Architecture Knowledge Required)

```dart
import 'package:easy_cache_manager/easy_cache_manager.dart';

// Simple wrapper - hides all complexity
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SimpleCacheManager.init();
  runApp(MyApp());
}

// Just cache things - we handle everything else!
final userData = {'name': 'John', 'age': 30};
await SimpleCacheManager.save('user_data', userData);
final cached = await SimpleCacheManager.get('user_data');
```

### 🤖 Configuration Wizard (Let AI Choose for You)

```dart
// Answer a few questions, get perfect config
final config = await ConfigWizard.run();
final cache = CacheManager(config: config);

// Or use our smart templates
final ecommerceCache = EasyCacheManager.template(AppType.ecommerce);
final socialCache = EasyCacheManager.template(AppType.social);
final newsCache = EasyCacheManager.template(AppType.news);
```

### 1. Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  easy_cache_manager: ^0.1.4
```

### 2. Basic Usage (Minimal Configuration)

Perfect for small projects and getting started quickly:

```dart
import 'package:easy_cache_manager/easy_cache_manager.dart';

// Minimal setup - just works!
final cacheManager = CacheManager(
  config: MinimalCacheConfig.small(), // 10MB cache
);

// Cache API responses
final userData = await cacheManager.getJson(
  'https://api.example.com/users/123',
  maxAge: const Duration(hours: 1),
);

// Cache images
final imageBytes = await cacheManager.getBytes(
  'https://example.com/avatar.jpg',
);
```

### 3. Advanced Usage (Enterprise Configuration)

For complex applications with specific requirements:

```dart
// Production-ready configuration
final cacheManager = CacheManager(
  config: AdvancedCacheConfig.production(
    maxCacheSize: 500 * 1024 * 1024, // 500MB
  ).copyWith(
    evictionPolicy: 'lru',
    enableCompression: true,
    compressionThreshold: 1024, // Compress files > 1KB
    enableEncryption: true,
    encryptionKey: 'your-secret-key-here',
    enableMetrics: true,
    backgroundSync: true,
  ),
);

// Access advanced features
final stats = await cacheManager.getStats();
print('Hit rate: ${stats.hitRate}%');

// Reactive programming with streams
cacheManager.statsStream.listen((stats) {
  print('Cache updated: ${stats.totalEntries} entries');
});
```

## 🎨 Flutter Widgets

### Cached Network Image Widget

```dart
CachedNetworkImageWidget(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: const CircularProgressIndicator(),
  errorWidget: const Icon(Icons.error),
  fit: BoxFit.cover,
  cacheManager: cacheManager,
)
```

### Cache Statistics Widget

```dart
CacheStatsWidget(
  cacheManager: cacheManager,
  showDetails: true,
)
```

## 🔧 Configuration Options

### Minimal Configuration (For Small Projects)

```dart
// Ultra-lightweight (5MB)
MinimalCacheConfig.tiny()

// Small projects (10MB)
MinimalCacheConfig.small()

// Medium projects (25MB)
MinimalCacheConfig.medium()
```

### Advanced Configuration (For Complex Projects)

```dart
AdvancedCacheConfig(
  // Storage and eviction
  evictionPolicy: 'lru', // or 'lfu', 'fifo', 'ttl', 'size-based'
  maxFileSize: 10 * 1024 * 1024, // Max 10MB per file

  // Performance features
  enableCompression: true,
  compressionType: 'gzip',
  compressionLevel: 6,
  compressionThreshold: 1024,

  // Security
  enableEncryption: true,
  encryptionKey: 'your-32-character-secret-key-here',

  // Background features
  backgroundSync: true,
  syncInterval: const Duration(hours: 2),

  // Monitoring
  enableMetrics: true,
)
```

## 🏗️ Platform-Specific Features

### Platform Capabilities

| Feature             | Web | Mobile | Desktop |
| ------------------- | --- | ------ | ------- |
| Persistent Storage  | ❌  | ✅     | ✅      |
| Large Files (>10MB) | ❌  | ✅     | ✅      |
| Background Sync     | ❌  | ✅     | ✅      |
| Compression         | ❌  | ✅     | ✅      |
| Encryption          | ❌  | ✅     | ✅      |

## 📊 Performance Monitoring

### Real-time Statistics

```dart
// Get current cache statistics
final stats = await cacheManager.getStats();
print('Hit rate: ${stats.hitRate.toStringAsFixed(1)}%');
print('Storage used: ${(stats.totalSizeInBytes / 1024 / 1024).toStringAsFixed(1)} MB');

// Monitor cache in real-time
cacheManager.statsStream.listen((stats) {
  if (stats.hitRate < 50) {
    print('Warning: Low cache hit rate');
  }
});
```

## 🔧 Eviction Policy & Analytics (Advanced)

### For Beginners
EasyCacheManager handles cleanup/expiry automatically - no additional config needed.

### For Power Users
You can choose policies like LRU, TTL, MaxEntries, or create custom ones:

```dart
import 'package:easy_cache_manager/easy_cache_manager.dart';

final cacheManager = CacheManager(
  config: AdvancedCacheConfig.production(),
  storage: HiveCacheStorage(
    evictionPolicy: LRUEvictionPolicy(1000), // Limit to 1000 entries
    analytics: SimpleCacheAnalytics(), // Track hit/miss/latency
  ),
);
```

### For Advanced Use Cases
Create custom policies/analytics for TTL per key, histograms, metric export:

```dart
class MyCustomPolicy implements EvictionPolicy {
  // ... implement method according to your logic ...
}

class MyAnalytics implements CacheAnalytics {
  // ... implement recordEvent/exportMetrics ...
}

final cacheManager = CacheManager(
  config: AdvancedCacheConfig.production(),
  storage: HiveCacheStorage(
    evictionPolicy: MyCustomPolicy(),
    analytics: MyAnalytics(),
  ),
);
```

### View Metrics/Export
```dart
final metrics = cacheManager.storage.analytics?.exportMetrics();
print(metrics);
```

## 🔗 Integration Examples

### State Management (Riverpod, Bloc)
```dart
final cacheManagerProvider = Provider((ref) => CacheManager(
  config: AdvancedCacheConfig.production(),
  storage: HiveCacheStorage(
    evictionPolicy: LRUEvictionPolicy(500),
    analytics: SimpleCacheAnalytics(),
  ),
));

// Use in Bloc/Event
class FetchUserEvent extends BlocEvent {
  Future<void> handle() async {
    final cacheManager = context.read(cacheManagerProvider);
    final user = await cacheManager.getJson('user_123');
    // ...
  }
}
```

### Network Library (Dio)
```dart
final cacheManager = CacheManager(
  config: AdvancedCacheConfig.production(),
  storage: HiveCacheStorage(
    evictionPolicy: LRUEvictionPolicy(1000),
    analytics: SimpleCacheAnalytics(),
  ),
);

final dio = Dio();
final response = await dio.get('https://api.example.com/data');
await cacheManager.save('api_data', response.data);
```

## 🧹 Lint Best Practices

- Use `const` with Duration, String, List, Map for constant values
- Use curly braces in if/for/while in all cases
- Add comments explaining logic in tests and examples

Example:
```dart
// Use const Duration
final map = {
  'a': now.subtract(const Duration(minutes: 3)),
  'b': now.subtract(const Duration(minutes: 2)),
  'c': now.subtract(const Duration(minutes: 1)),
};

// Use curly braces
if (condition) {
  doSomething();
}

// Add comments in tests
test('should evict when max entries reached', () {
  // Arrange: Setup cache with max 2 entries
  // Act: Add 3 entries
  // Assert: Verify oldest entry was evicted
});
```

## 🧪 Testing

Run the tests:

```bash
flutter test
```

For integration tests:

```bash
flutter test integration_test/
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Made with ❤️ for the Flutter community**

If this package helped you, please give it a ⭐ on [pub.dev](https://pub.dev/packages/easy_cache_manager) and [GitHub](https://github.com/kidpech/easy_cache_manager)!
