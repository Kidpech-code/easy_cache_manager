import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/cache_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';

/// 🏠 Home Screen - Main Dashboard and Navigation Hub
///
/// This screen provides an overview of Easy Cache Manager capabilities
/// and serves as the main navigation hub for all example scenarios.
///
/// ## Features:
/// - Configuration overview and switching
/// - Quick access to all example categories
/// - Real-time cache statistics
/// - Theme switching
/// - Performance indicators
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CacheProvider, ThemeProvider>(
      builder: (context, cacheProvider, themeProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Easy Cache Manager'),
            actions: [
              // Theme toggle button
              IconButton(
                icon: Icon(themeProvider.themeModeIcon),
                tooltip:
                    'Switch to ${_getNextThemeMode(themeProvider.themeMode)}',
                onPressed: themeProvider.toggleTheme,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _buildBody(context, cacheProvider, themeProvider),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CacheProvider cacheProvider,
      ThemeProvider themeProvider) {
    if (!cacheProvider.isInitialized) {
      return _buildInitializingState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh statistics and reinitialize if needed
        context.read<CacheProvider>().initialize();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome header
            _buildWelcomeHeader(context),
            const SizedBox(height: 24),

            // Configuration selector
            _buildConfigurationSelector(context, cacheProvider),
            const SizedBox(height: 24),

            // Cache statistics overview
            _buildStatisticsOverview(context, cacheProvider),
            const SizedBox(height: 24),

            // Example categories grid
            _buildExampleCategoriesGrid(context),
            const SizedBox(height: 24),

            // Quick actions
            _buildQuickActions(context, cacheProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildInitializingState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Initializing Cache Manager...'),
          SizedBox(height: 8),
          Text('Setting up storage adapters and configurations',
              style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.storage,
                      size: 32, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Easy Cache Manager',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Comprehensive Example Application',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Explore all features and scenarios of the Easy Cache Manager package. From basic API caching to enterprise-level configurations with compression, encryption, and advanced eviction policies.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigurationSelector(
      BuildContext context, CacheProvider cacheProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cache Configuration',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...CacheConfigurationType.values.map((type) {
              final isSelected = cacheProvider.currentConfiguration == type;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: InkWell(
                  onTap: () => cacheProvider.switchConfiguration(type),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).primaryColor, width: 2)
                          : Border.all(
                              color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey[400],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type.displayName,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(type.description,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle,
                              color: Theme.of(context).primaryColor),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsOverview(
      BuildContext context, CacheProvider cacheProvider) {
    final stats = cacheProvider.statistics;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Cache Statistics',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context.go('/monitoring'),
                  icon: const Icon(Icons.analytics, size: 16),
                  label: const Text('View Details'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        context,
                        'Cache Hits',
                        '${stats.hitCount}',
                        Icons.trending_up,
                        CustomColors.success)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatCard(
                        context,
                        'Cache Misses',
                        '${stats.missCount}',
                        Icons.trending_down,
                        CustomColors.warning)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        context,
                        'Total Entries',
                        '${stats.totalEntries}',
                        Icons.storage,
                        CustomColors.info)),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Cache Size',
                    _formatBytes(stats.totalSizeInBytes),
                    Icons.folder_open,
                    Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            if (stats.hitRate > 0) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: stats.hitRate,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  stats.hitRate > 0.8
                      ? CustomColors.success
                      : stats.hitRate > 0.5
                          ? CustomColors.warning
                          : CustomColors.danger,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hit Rate',
                      style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    '${(stats.hitRate * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildExampleCategoriesGrid(BuildContext context) {
    final categories = [
      _ExampleCategory(
        title: 'Basic Examples',
        subtitle: 'API caching, images, offline support',
        icon: Icons.play_circle_outline,
        route: '/basic-examples',
        color: Colors.blue,
      ),
      _ExampleCategory(
        title: 'Advanced Features',
        subtitle: 'Compression, encryption, policies',
        icon: Icons.settings,
        route: '/advanced-examples',
        color: Colors.purple,
      ),
      _ExampleCategory(
        title: 'Performance Demo',
        subtitle: 'Benchmarks, memory usage, optimization',
        icon: Icons.speed,
        route: '/performance-demo',
        color: Colors.green,
      ),
      _ExampleCategory(
        title: 'Platform Features',
        subtitle: 'Cross-platform storage, native features',
        icon: Icons.devices,
        route: '/platform-demo',
        color: Colors.orange,
      ),
      _ExampleCategory(
        title: 'Custom Scenarios',
        subtitle: 'Enterprise use cases, batch operations',
        icon: Icons.business,
        route: '/custom-scenarios',
        color: Colors.indigo,
      ),
      _ExampleCategory(
        title: 'Real-time Monitoring',
        subtitle: 'Live stats, debugging, analytics',
        icon: Icons.analytics,
        route: '/monitoring',
        color: Colors.teal,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Explore Examples',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCategoryCard(context, category);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, _ExampleCategory category) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => context.go(category.route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(category.icon, size: 32, color: category.color),
              ),
              const SizedBox(height: 12),
              Text(
                category.title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  category.subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, CacheProvider cacheProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _clearCurrentCache(context, cacheProvider),
                icon: const Icon(Icons.clear),
                label: const Text('Clear Current Cache'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _clearAllCaches(context, cacheProvider),
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear All Caches'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, foregroundColor: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper methods
  String _getNextThemeMode(ThemeMode currentMode) {
    switch (currentMode) {
      case ThemeMode.light:
        return 'Dark Mode';
      case ThemeMode.dark:
        return 'Light Mode';
      case ThemeMode.system:
        return 'Light Mode';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  Future<void> _clearCurrentCache(
      BuildContext context, CacheProvider cacheProvider) async {
    try {
      await cacheProvider.clearCurrentCache();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${cacheProvider.currentConfiguration.displayName} cache cleared successfully'),
            backgroundColor: CustomColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to clear cache: $e'),
            backgroundColor: CustomColors.danger));
      }
    }
  }

  Future<void> _clearAllCaches(
      BuildContext context, CacheProvider cacheProvider) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Caches?'),
        content: const Text(
            'This will clear all cached data from all configurations. This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Clear All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await cacheProvider.clearAllCaches();
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(
              content: Text('All caches cleared successfully'),
              backgroundColor: CustomColors.success));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to clear caches: $e'),
              backgroundColor: CustomColors.danger));
        }
      }
    }
  }
}

/// Data class for example categories
class _ExampleCategory {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final Color color;

  _ExampleCategory(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.route,
      required this.color});
}
