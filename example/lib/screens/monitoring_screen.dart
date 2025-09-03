import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as math;
import '../providers/cache_provider.dart';

/// 📊 Real-Time Monitoring Screen
///
/// Comprehensive cache monitoring dashboard with:
/// - Live performance metrics and statistics
/// - Interactive charts and visualizations
/// - Health indicators and alerts
/// - Historical data trends
/// - User-friendly insights for all skill levels
class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen>
    with TickerProviderStateMixin {
  Timer? _refreshTimer;
  final List<_MetricsSnapshot> _metricsHistory = [];
  bool _isRealTimeEnabled = true;
  String _selectedTimeRange = '1h';
  String _selectedMetric = 'Hit Rate';

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _chartController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _chartAnimation;

  final Map<String, String> _timeRanges = {
    '5m': 'Last 5 minutes',
    '1h': 'Last hour',
    '24h': 'Last 24 hours',
    '7d': 'Last 7 days',
  };

  final List<String> _availableMetrics = [
    'Hit Rate',
    'Storage Usage',
    'Response Time',
    'Throughput',
    'Error Rate',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _pulseController.repeat(reverse: true);
    _chartController.forward();

    // Start real-time monitoring
    _startMonitoring();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pulseController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  void _startMonitoring() {
    _refreshTimer?.cancel();
    if (_isRealTimeEnabled) {
      _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
        if (mounted) {
          _updateMetrics();
        }
      });
      // Initial update
      _updateMetrics();
    }
  }

  Future<void> _updateMetrics() async {
    try {
      final cache = context.read<CacheProvider>().currentCache;
      final stats = await cache.getStats();
      final now = DateTime.now();

      setState(() {
        _metricsHistory.add(_MetricsSnapshot(
          timestamp: now,
          hitRate: stats.hitRate,
          missRate: stats.missRate,
          totalEntries: stats.totalEntries,
          totalSize: stats.totalSizeInBytes,
          hitCount: stats.hitCount,
          missCount: stats.missCount,
          evictionCount: stats.evictionCount,
          averageLoadTime: stats.averageLoadTime,
        ));

        // Keep only recent metrics based on selected time range
        final cutoffTime = _getCutoffTime();
        _metricsHistory
            .removeWhere((snapshot) => snapshot.timestamp.isBefore(cutoffTime));
      });
    } catch (e) {
      // Handle errors gracefully
      debugPrint('Error updating metrics: $e');
    }
  }

  DateTime _getCutoffTime() {
    final now = DateTime.now();
    switch (_selectedTimeRange) {
      case '5m':
        return now.subtract(const Duration(minutes: 5));
      case '1h':
        return now.subtract(const Duration(hours: 1));
      case '24h':
        return now.subtract(const Duration(hours: 24));
      case '7d':
        return now.subtract(const Duration(days: 7));
      default:
        return now.subtract(const Duration(hours: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Live Monitoring'),
            const SizedBox(width: 8),
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _isRealTimeEnabled
                        ? Colors.green.withValues(alpha: _pulseAnimation.value)
                        : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isRealTimeEnabled ? Icons.pause : Icons.play_arrow),
            tooltip:
                _isRealTimeEnabled ? 'Pause monitoring' : 'Start monitoring',
            onPressed: () {
              setState(() {
                _isRealTimeEnabled = !_isRealTimeEnabled;
                _startMonitoring();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh now',
            onPressed: _updateMetrics,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Overview
            _buildStatusOverview(),

            const SizedBox(height: 16),

            // Quick Metrics Cards
            _buildQuickMetrics(),

            const SizedBox(height: 16),

            // Time Range and Metric Selector
            _buildControlPanel(),

            const SizedBox(height: 16),

            // Main Chart
            _buildMainChart(),

            const SizedBox(height: 16),

            // Detailed Metrics
            _buildDetailedMetrics(),

            const SizedBox(height: 16),

            // Health Indicators
            _buildHealthIndicators(),

            const SizedBox(height: 16),

            // Recommendations
            _buildRecommendations(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOverview() {
    final hasData = _metricsHistory.isNotEmpty;
    final latestMetrics = hasData ? _metricsHistory.last : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.monitor_heart,
                  color: Colors.blue[600],
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'System Status',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSystemHealthColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getSystemHealthColor()),
                  ),
                  child: Text(
                    _getSystemHealthText(),
                    style: TextStyle(
                      color: _getSystemHealthColor(),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hasData) ...[
              Row(
                children: [
                  Expanded(
                    child: _buildStatusItem(
                      'Cache Performance',
                      '${(latestMetrics!.hitRate * 100).toStringAsFixed(1)}%',
                      Icons.speed,
                      _getPerformanceColor(latestMetrics.hitRate),
                    ),
                  ),
                  Expanded(
                    child: _buildStatusItem(
                      'Total Entries',
                      '${latestMetrics.totalEntries}',
                      Icons.storage,
                      Colors.blue[600]!,
                    ),
                  ),
                  Expanded(
                    child: _buildStatusItem(
                      'Storage Used',
                      _formatBytes(latestMetrics.totalSize),
                      Icons.folder,
                      Colors.orange[600]!,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Center(
                child: Text(
                  'Waiting for metrics data...',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickMetrics() {
    if (_metricsHistory.isEmpty) {
      return const SizedBox();
    }

    final latest = _metricsHistory.last;
    final previous = _metricsHistory.length > 1
        ? _metricsHistory[_metricsHistory.length - 2]
        : null;

    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            'Hit Rate',
            '${(latest.hitRate * 100).toStringAsFixed(1)}%',
            previous != null ? latest.hitRate - previous.hitRate : 0.0,
            Icons.thumb_up,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            'Response Time',
            '${(latest.averageLoadTime.inMicroseconds / 1000).toStringAsFixed(1)}ms',
            0.0, // Calculate change if needed
            Icons.timer,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            'Evictions',
            '${latest.evictionCount}',
            0.0, // Calculate change if needed
            Icons.delete_outline,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title, String value, double change, IconData icon, Color color) {
    final isPositive = change > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (change != 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    size: 16,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${change > 0 ? '+' : ''}${(change * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monitoring Controls',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time Range',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _timeRanges.entries.map((entry) {
                          final isSelected = _selectedTimeRange == entry.key;
                          return ChoiceChip(
                            label: Text(entry.key),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedTimeRange = entry.key;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Primary Metric',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedMetric,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _availableMetrics.map((metric) {
                          return DropdownMenuItem(
                            value: metric,
                            child: Text(metric),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedMetric = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timeline, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Text(
                  '$_selectedMetric - ${_timeRanges[_selectedTimeRange]}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: AnimatedBuilder(
                animation: _chartAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(double.infinity, 200),
                    painter: _ChartPainter(
                      metrics: _metricsHistory,
                      selectedMetric: _selectedMetric,
                      animation: _chartAnimation.value,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildChartLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('Excellent', Colors.green, '>80%'),
        _buildLegendItem('Good', Colors.blue, '60-80%'),
        _buildLegendItem('Warning', Colors.orange, '40-60%'),
        _buildLegendItem('Critical', Colors.red, '<40%'),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, String range) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          range,
          style: TextStyle(
            fontSize: 8,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedMetrics() {
    if (_metricsHistory.isEmpty) {
      return const SizedBox();
    }

    final latest = _metricsHistory.last;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.teal[600]),
                const SizedBox(width: 8),
                Text(
                  'Detailed Metrics',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricsGrid(latest),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(_MetricsSnapshot metrics) {
    final metricItems = [
      _MetricItem('Total Requests', '${metrics.hitCount + metrics.missCount}',
          Icons.call_made),
      _MetricItem(
          'Cache Hits', '${metrics.hitCount}', Icons.check_circle_outline),
      _MetricItem('Cache Misses', '${metrics.missCount}', Icons.error_outline),
      _MetricItem('Hit Rate', '${(metrics.hitRate * 100).toStringAsFixed(2)}%',
          Icons.percent),
      _MetricItem('Miss Rate',
          '${(metrics.missRate * 100).toStringAsFixed(2)}%', Icons.percent),
      _MetricItem(
          'Evictions', '${metrics.evictionCount}', Icons.delete_outline),
      _MetricItem('Entries', '${metrics.totalEntries}', Icons.inventory),
      _MetricItem('Storage', _formatBytes(metrics.totalSize), Icons.storage),
      _MetricItem(
          'Avg Load Time',
          '${(metrics.averageLoadTime.inMicroseconds / 1000).toStringAsFixed(2)}ms',
          Icons.timer),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: metricItems.length,
      itemBuilder: (context, index) {
        final item = metricItems[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 20, color: Colors.grey[600]),
              const SizedBox(height: 4),
              Text(
                item.value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHealthIndicators() {
    if (_metricsHistory.isEmpty) {
      return const SizedBox();
    }

    final latest = _metricsHistory.last;
    final healthItems = _getHealthIndicators(latest);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: Colors.pink[600]),
                const SizedBox(width: 8),
                Text(
                  'System Health Indicators',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...healthItems.map((item) => _buildHealthItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthItem(_HealthIndicator indicator) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: indicator.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  indicator.title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  indicator.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: indicator.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              indicator.status,
              style: TextStyle(
                color: indicator.color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    if (_metricsHistory.isEmpty) {
      return const SizedBox();
    }

    final recommendations = _getRecommendations(_metricsHistory.last);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber[600]),
                const SizedBox(width: 8),
                Text(
                  'Performance Recommendations',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.map((rec) => _buildRecommendationItem(rec)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.amber[600],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              recommendation,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getSystemHealthColor() {
    if (_metricsHistory.isEmpty) return Colors.grey;
    final latest = _metricsHistory.last;
    if (latest.hitRate > 0.8) return Colors.green;
    if (latest.hitRate > 0.6) return Colors.blue;
    if (latest.hitRate > 0.4) return Colors.orange;
    return Colors.red;
  }

  String _getSystemHealthText() {
    if (_metricsHistory.isEmpty) return 'Monitoring';
    final latest = _metricsHistory.last;
    if (latest.hitRate > 0.8) return 'Excellent';
    if (latest.hitRate > 0.6) return 'Good';
    if (latest.hitRate > 0.4) return 'Warning';
    return 'Critical';
  }

  Color _getPerformanceColor(double hitRate) {
    if (hitRate > 0.8) return Colors.green;
    if (hitRate > 0.6) return Colors.blue;
    if (hitRate > 0.4) return Colors.orange;
    return Colors.red;
  }

  List<_HealthIndicator> _getHealthIndicators(_MetricsSnapshot metrics) {
    final indicators = <_HealthIndicator>[];

    // Hit Rate Indicator
    if (metrics.hitRate > 0.8) {
      indicators.add(_HealthIndicator(
        title: 'Excellent Cache Performance',
        description: 'Your cache is performing exceptionally well',
        status: 'Healthy',
        color: Colors.green,
      ));
    } else if (metrics.hitRate > 0.6) {
      indicators.add(_HealthIndicator(
        title: 'Good Cache Performance',
        description: 'Cache is working well with room for optimization',
        status: 'Good',
        color: Colors.blue,
      ));
    } else {
      indicators.add(_HealthIndicator(
        title: 'Cache Performance Issues',
        description: 'Consider reviewing your caching strategy',
        status: 'Warning',
        color: Colors.orange,
      ));
    }

    // Storage Indicator
    if (metrics.totalSize < 50 * 1024 * 1024) {
      // < 50MB
      indicators.add(_HealthIndicator(
        title: 'Storage Usage Normal',
        description: 'Cache storage is within recommended limits',
        status: 'Optimal',
        color: Colors.green,
      ));
    } else if (metrics.totalSize < 200 * 1024 * 1024) {
      // < 200MB
      indicators.add(_HealthIndicator(
        title: 'Moderate Storage Usage',
        description: 'Monitor storage growth and consider cleanup',
        status: 'Monitor',
        color: Colors.orange,
      ));
    } else {
      indicators.add(_HealthIndicator(
        title: 'High Storage Usage',
        description: 'Consider implementing more aggressive cleanup policies',
        status: 'Action Needed',
        color: Colors.red,
      ));
    }

    // Response Time Indicator
    final avgLoadTimeMs = metrics.averageLoadTime.inMicroseconds / 1000;
    if (avgLoadTimeMs < 10) {
      indicators.add(_HealthIndicator(
        title: 'Excellent Response Times',
        description: 'Cache responses are very fast',
        status: 'Excellent',
        color: Colors.green,
      ));
    } else if (avgLoadTimeMs < 50) {
      indicators.add(_HealthIndicator(
        title: 'Good Response Times',
        description: 'Response times are acceptable',
        status: 'Good',
        color: Colors.blue,
      ));
    } else {
      indicators.add(_HealthIndicator(
        title: 'Slow Response Times',
        description: 'Consider optimizing cache operations',
        status: 'Needs Attention',
        color: Colors.orange,
      ));
    }

    return indicators;
  }

  List<String> _getRecommendations(_MetricsSnapshot metrics) {
    final recommendations = <String>[];

    if (metrics.hitRate < 0.6) {
      recommendations
          .add('Consider increasing cache size or adjusting TTL values');
      recommendations
          .add('Review your caching keys to ensure optimal cache usage');
    }

    if (metrics.totalSize > 100 * 1024 * 1024) {
      recommendations.add('Enable compression to reduce storage usage');
      recommendations.add('Implement more aggressive eviction policies');
    }

    if (metrics.averageLoadTime.inMicroseconds > 50000) {
      recommendations.add('Consider optimizing data serialization');
      recommendations.add('Check for network latency in cache operations');
    }

    if (metrics.evictionCount > metrics.totalEntries * 0.5) {
      recommendations
          .add('Increase cache capacity to reduce frequent evictions');
    }

    if (recommendations.isEmpty) {
      recommendations.add(
          'Your cache is performing well! Consider monitoring trends over time');
      recommendations
          .add('Great job! Keep monitoring to maintain optimal performance');
    }

    return recommendations;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

// Data classes
class _MetricsSnapshot {
  final DateTime timestamp;
  final double hitRate;
  final double missRate;
  final int totalEntries;
  final int totalSize;
  final int hitCount;
  final int missCount;
  final int evictionCount;
  final Duration averageLoadTime;

  _MetricsSnapshot({
    required this.timestamp,
    required this.hitRate,
    required this.missRate,
    required this.totalEntries,
    required this.totalSize,
    required this.hitCount,
    required this.missCount,
    required this.evictionCount,
    required this.averageLoadTime,
  });
}

class _MetricItem {
  final String label;
  final String value;
  final IconData icon;

  _MetricItem(this.label, this.value, this.icon);
}

class _HealthIndicator {
  final String title;
  final String description;
  final String status;
  final Color color;

  _HealthIndicator({
    required this.title,
    required this.description,
    required this.status,
    required this.color,
  });
}

// Custom Chart Painter
class _ChartPainter extends CustomPainter {
  final List<_MetricsSnapshot> metrics;
  final String selectedMetric;
  final double animation;

  _ChartPainter({
    required this.metrics,
    required this.selectedMetric,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (metrics.isEmpty) {
      _drawEmptyState(canvas, size);
      return;
    }

    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw grid
    _drawGrid(canvas, size);

    // Draw the main metric line
    _drawMetricLine(canvas, size, paint);

    // Draw data points
    _drawDataPoints(canvas, size);
  }

  void _drawEmptyState(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'No data available',
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;

    // Horizontal lines
    for (int i = 0; i <= 5; i++) {
      final y = size.height / 5 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Vertical lines
    final stepCount = math.min(metrics.length, 10);
    if (stepCount > 1) {
      for (int i = 0; i < stepCount; i++) {
        final x = size.width / (stepCount - 1) * i;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      }
    }
  }

  void _drawMetricLine(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final animatedMetrics =
        metrics.take((metrics.length * animation).round()).toList();

    if (animatedMetrics.length < 2) return;

    for (int i = 0; i < animatedMetrics.length; i++) {
      final metric = animatedMetrics[i];
      final value = _getMetricValue(metric, selectedMetric);
      final x = size.width / (animatedMetrics.length - 1) * i;
      final y = size.height - (size.height * value);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Color the line based on performance
    final averageValue = animatedMetrics
            .map((m) => _getMetricValue(m, selectedMetric))
            .reduce((a, b) => a + b) /
        animatedMetrics.length;

    paint.color = _getMetricColor(averageValue, selectedMetric);
    canvas.drawPath(path, paint);
  }

  void _drawDataPoints(Canvas canvas, Size size) {
    final animatedMetrics =
        metrics.take((metrics.length * animation).round()).toList();

    for (int i = 0; i < animatedMetrics.length; i++) {
      final metric = animatedMetrics[i];
      final value = _getMetricValue(metric, selectedMetric);
      final x = size.width / (animatedMetrics.length - 1) * i;
      final y = size.height - (size.height * value);

      final pointPaint = Paint()
        ..color = _getMetricColor(value, selectedMetric)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  double _getMetricValue(_MetricsSnapshot metric, String metricName) {
    switch (metricName) {
      case 'Hit Rate':
        return metric.hitRate;
      case 'Storage Usage':
        return math.min(
            metric.totalSize / (100 * 1024 * 1024), 1.0); // Normalize to 100MB
      case 'Response Time':
        return math.min(metric.averageLoadTime.inMicroseconds / 100000,
            1.0); // Normalize to 100ms
      case 'Throughput':
        return math.min((metric.hitCount + metric.missCount) / 1000,
            1.0); // Normalize to 1000 requests
      case 'Error Rate':
        return metric.missRate;
      default:
        return metric.hitRate;
    }
  }

  Color _getMetricColor(double value, String metricName) {
    if (metricName == 'Error Rate') {
      // For error rate, lower is better
      if (value < 0.2) return Colors.green;
      if (value < 0.4) return Colors.orange;
      return Colors.red;
    } else {
      // For other metrics, higher is better
      if (value > 0.8) return Colors.green;
      if (value > 0.6) return Colors.blue;
      if (value > 0.4) return Colors.orange;
      return Colors.red;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
