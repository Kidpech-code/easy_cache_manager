/// HTTP and key-value caching for Flutter using Hive CE.
///
/// [CacheManager] caches JSON and binary HTTP responses. [SimpleCacheStorage]
/// provides a separate key-value API. HTTP responses are fresh for `maxAge`
/// and may be used for another `stalePeriod` when offline or on error.
/// Cached response bodies are not encrypted by default.
///
/// See the README for initialization, migration, and privacy guidance.
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
