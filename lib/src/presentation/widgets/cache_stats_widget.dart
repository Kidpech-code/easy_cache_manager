import 'package:flutter/material.dart';
import '../cache_manager.dart';
import '../../domain/entities/cache_stats.dart';

/// A widget that displays cache statistics
class CacheStatsWidget extends StatelessWidget {
  final CacheManager cacheManager;
  final Widget Function(BuildContext, CacheStats)? builder;

  const CacheStatsWidget({super.key, required this.cacheManager, this.builder});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CacheStats>(
      stream: cacheManager.statsStream,
      initialData: cacheManager.currentStats,
      builder: (context, snapshot) {
        final stats = snapshot.data ?? cacheManager.currentStats;

        if (builder != null) {
          return builder!(context, stats);
        }

        return _buildDefaultStatsWidget(context, stats);
      },
    );
  }

  Widget _buildDefaultStatsWidget(BuildContext context, CacheStats stats) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cache Statistics',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildStatsGrid(context, stats),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, CacheStats stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildStatItem(context, 'Entries',
                    stats.totalEntries.toString(), Icons.storage)),
            Expanded(
                child: _buildStatItem(
                    context,
                    'Size',
                    '${stats.totalSizeInMB.toStringAsFixed(1)} MB',
                    Icons.folder_open)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                'Hit Rate',
                '${(stats.hitRate * 100).toStringAsFixed(1)}%',
                Icons.trending_up,
                color: _getHitRateColor(stats.hitRate),
              ),
            ),
            Expanded(
                child: _buildStatItem(context, 'Avg Load',
                    '${stats.averageLoadTime.inMilliseconds}ms', Icons.timer)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildStatItem(context, 'Cache Hits',
                    stats.hitCount.toString(), Icons.check_circle,
                    color: Colors.green)),
            Expanded(
                child: _buildStatItem(context, 'Cache Misses',
                    stats.missCount.toString(), Icons.cancel,
                    color: Colors.red)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildStatItem(context, 'Evictions',
                    stats.evictionCount.toString(), Icons.delete_sweep,
                    color: Colors.orange)),
            Expanded(
                child: _buildStatItem(
                    context,
                    'Last Cleanup',
                    _formatLastCleanup(stats.lastCleanup),
                    Icons.cleaning_services)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, IconData icon,
      {Color? color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border:
            Border.all(color: (color ?? Colors.blue).withAlpha(76), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color ?? Colors.blue, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold, color: color ?? Colors.blue),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getHitRateColor(double hitRate) {
    if (hitRate >= 0.8) return Colors.green;
    if (hitRate >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _formatLastCleanup(DateTime lastCleanup) {
    final now = DateTime.now();
    final difference = now.difference(lastCleanup);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
