/// Easy Cache Manager - High-performance cache manager for Flutter
///
/// v0.1.0 Performance upgrade: Now powered by Hive NoSQL for substantial speed improvements in many scenarios.
///
/// This library aims to provide a fast Flutter caching solution with features:
///
/// ## Performance profile
/// - Significant speedups vs SQL-based approaches in our internal tests
/// - Memory usage reductions in typical read-heavy workloads
/// - Built on Hive NoSQL engine
/// - Cross-platform optimized for Web, Mobile, Desktop
/// - Zero-copy binary operations where applicable
///
/// ## Competitive positioning
/// - Built on top of Hive with an intelligent caching layer and network support
/// - Aims to be simple to integrate while offering advanced controls
///
/// ## ✨ DEVELOPER EXPERIENCE
/// - 🚀 Smart Auto-Configuration with AI
/// - 👶 Simple wrapper for beginners
/// - 📱 App-specific templates (ecommerce, social, news, etc.)
/// - 🏗️ Clean Architecture with Domain Driven Design (DDD)
/// - 📊 Real-time performance monitoring
/// - 🔧 Built-in benchmark tools
///
/// ## Zero-Config Usage (Just 2 Lines!)
/// ```dart
/// import 'package:easy_cache_manager/easy_cache_manager.dart';
///
/// // Automatic high-performance configuration
/// final cache = EasyCacheManager.auto(); // Now with Hive power!
///
/// // Or use optimized templates
/// final cache = EasyCacheManager.template(AppType.ecommerce);
/// ```
///
/// ## Simple Usage (For Beginners - URL-based caching only)
/// ```dart
/// // Initialize once - gets Hive performance automatically
/// await SimpleCacheManager.init();
///
/// // Cache images from URLs
/// await SimpleCacheManager.cacheImage('https://example.com/image.jpg');
/// final cached = await SimpleCacheManager.getImage('https://example.com/image.jpg'); // Very fast on cache hits
///
/// // Note: Direct key-value storage (like saveJson/getJson) will be implemented in next update
/// // For now, use EasyCacheManager.auto() for full functionality
/// ```
///
/// ## Advanced Usage (Full Power)
/// ```dart
/// // Create high-performance cache manager
/// final cacheManager = CacheManager(
///   config: CacheConfig(
///     maxCacheSize: 100 * 1024 * 1024, // 100MB
///     stalePeriod: Duration(days: 7),
///     // Hive storage used automatically - no configuration needed!
///   ),
/// );
///
/// // Fetch JSON with blazing fast caching
/// final userData = await cacheManager.getJson(
///   'https://api.example.com/users/123',
///   maxAge: Duration(hours: 1),
/// );
/// ```
///
/// ## 📊 Performance Benchmarks
/// Benchmarks vary by device and workload. See README for the suite and methodology.
library;

// 🚀 Pure Hive Performance Revolution
export 'src/core/storage/hive_cache_storage.dart';
export 'src/core/storage/cache_storage_factory.dart';
export 'src/core/storage/simple_cache_storage.dart';
export 'src/utils/hive_performance_benchmark.dart';

// 🤖 Smart Auto-Configuration AI System
export 'src/utils/auto_config.dart';

// 🎯 Core Cache Manager
export 'src/presentation/cache_manager.dart';

// 🛠️ Advanced Configuration & Policies
export 'src/domain/entities/advanced_cache_config.dart';
export 'src/core/policies/eviction_policies.dart';
export 'src/core/analytics/cache_analytics.dart';

// 📋 Core Models & Entities
export 'src/domain/entities/cache_entry.dart';
export 'src/domain/entities/cache_stats.dart';
export 'src/domain/entities/cache_status.dart';

// 🎨 UI Components & Widgets
export 'src/presentation/widgets/cached_network_image_widget.dart';
export 'src/presentation/widgets/cache_status_widget.dart';
export 'src/presentation/widgets/cache_stats_widget.dart';

// 🔧 Enhanced Features - Policies and Utils
export 'src/core/utils/compression_utils.dart';

// 🛠️ Core utilities
export 'src/core/utils/cache_utils.dart';
export 'src/core/error/failures.dart';
export 'src/core/error/exceptions.dart';

// 🌐 Network utilities
export 'src/core/network/network_info.dart';

import 'src/domain/entities/cache_config.dart';
import 'src/domain/entities/advanced_cache_config.dart';

/// Top-level factory for default config (for user convenience)
CacheConfig defaultCacheConfig() => const CacheConfig();
AdvancedCacheConfig defaultAdvancedCacheConfig() =>
    AdvancedCacheConfig.production();
