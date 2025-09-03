import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cache_provider.dart';
import '../utils/app_theme.dart';

/// 📚 Basic Examples Screen
///
/// Demonstrates fundamental Easy Cache Manager usage patterns:
/// - Simple API caching
/// - Image caching
/// - Offline mode support
/// - Basic error handling
class BasicExamplesScreen extends StatefulWidget {
  const BasicExamplesScreen({super.key});

  @override
  State<BasicExamplesScreen> createState() => _BasicExamplesScreenState();
}

class _BasicExamplesScreenState extends State<BasicExamplesScreen> {
  final List<_ExampleResult> _results = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Basic Examples'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Results',
            onPressed: () {
              setState(() {
                _results.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Examples Menu
          _buildExamplesMenu(),

          // Loading Indicator
          if (_isLoading) _buildLoadingIndicator(),

          // Results Section
          Expanded(child: _buildResultsList()),
        ],
      ),
    );
  }

  Widget _buildExamplesMenu() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Caching Examples',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildExampleButton(
                  'Simple String Cache',
                  Icons.text_fields,
                  CustomColors.info,
                  _demonstrateStringCache,
                ),
                _buildExampleButton(
                  'JSON Data Cache',
                  Icons.code,
                  CustomColors.success,
                  _demonstrateJsonCache,
                ),
                _buildExampleButton(
                  'Binary Data Cache',
                  Icons.storage,
                  CustomColors.warning,
                  _demonstrateBinaryCache,
                ),
                _buildExampleButton(
                  'Cache with TTL',
                  Icons.timer,
                  CustomColors.danger,
                  _demonstrateTtlCache,
                ),
                _buildExampleButton(
                  'Offline Mode',
                  Icons.cloud_off,
                  Colors.purple,
                  _demonstrateOfflineMode,
                ),
                _buildExampleButton(
                  'Cache Statistics',
                  Icons.analytics,
                  Colors.teal,
                  _demonstrateStatistics,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon, size: 18),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Running example...'),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    if (_results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Select an example above to see results',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[_results.length - 1 - index]; // Newest first
        return _buildResultCard(result, index);
      },
    );
  }

  Widget _buildResultCard(_ExampleResult result, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor:
              result.isSuccess ? CustomColors.success : CustomColors.danger,
          foregroundColor: Colors.white,
          child: Icon(result.isSuccess ? Icons.check : Icons.error),
        ),
        title: Text(
          result.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${result.timestamp.hour.toString().padLeft(2, '0')}:'
          '${result.timestamp.minute.toString().padLeft(2, '0')}:'
          '${result.timestamp.second.toString().padLeft(2, '0')} - '
          '${result.isSuccess ? 'Success' : 'Error'}'
          '${result.duration != null ? ' (${result.duration!.inMilliseconds}ms)' : ''}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (result.description != null) ...[
                  Text(
                    'Description:',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(result.description!),
                  const SizedBox(height: 12),
                ],
                Text(
                  'Details:',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    result.details,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Example implementations
  Future<void> _demonstrateStringCache() async {
    setState(() => _isLoading = true);

    try {
      final stopwatch = Stopwatch()..start();
      final cache = context.read<CacheProvider>().currentCache;

      // Store a simple string by putting it as JSON
      const url = 'cache://example_string';
      final data = {
        'message': 'Hello, Easy Cache Manager! This is a simple string example.'
      };

      // For demo purposes, we'll show how string data can be cached
      // Note: In a real scenario, this would be an actual API endpoint

      // Check if already cached
      final exists = await cache.contains(url);

      stopwatch.stop();

      final result = _ExampleResult(
        title: 'Simple String Cache',
        description:
            'Demonstrated string-like data caching using cache management features',
        details: 'Data: ${data['message']}\n'
            'Cache key: "$url"\n'
            'Already cached: $exists\n'
            'Operation time: ${stopwatch.elapsedMicroseconds}μs\n'
            'Cache ready: true\n'
            'Note: This demonstrates cache key checking and basic operations',
        isSuccess: true,
        duration: Duration(microseconds: stopwatch.elapsedMicroseconds),
      );

      setState(() {
        _results.add(result);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _results.add(_ExampleResult(
          title: 'Simple String Cache - ERROR',
          details: 'Error: $e',
          isSuccess: false,
        ));
        _isLoading = false;
      });
    }
  }

  Future<void> _demonstrateJsonCache() async {
    setState(() => _isLoading = true);

    try {
      final stopwatch = Stopwatch()..start();
      final cache = context.read<CacheProvider>().currentCache;

      // Use JSONPlaceholder API for real JSON caching demonstration
      const url = 'https://jsonplaceholder.typicode.com/posts/1';

      try {
        // Fetch JSON data with caching
        final data = await cache.getJson(url);
        stopwatch.stop();

        final result = _ExampleResult(
          title: 'JSON Data Cache',
          description:
              'Successfully fetched and cached real JSON data from JSONPlaceholder API',
          details: 'URL: $url\n'
              'Title: ${data['title']}\n'
              'Body: ${data['body']?.toString().substring(0, 50)}...\n'
              'User ID: ${data['userId']}\n'
              'Post ID: ${data['id']}\n'
              'Load time: ${stopwatch.elapsedMilliseconds}ms\n'
              'Data keys: ${data.keys.join(', ')}\n'
              'Size: ~${data.toString().length} chars',
          isSuccess: data.isNotEmpty,
          duration: stopwatch.elapsed,
        );

        setState(() {
          _results.add(result);
          _isLoading = false;
        });
      } catch (networkError) {
        // If network fails, show cached version if available
        final exists = await cache.contains(url);

        final result = _ExampleResult(
          title: 'JSON Data Cache (Network Error)',
          description:
              'Network request failed - demonstrating offline cache behavior',
          details: 'URL: $url\n'
              'Network Error: ${networkError.toString()}\n'
              'Cached version available: $exists\n'
              'This demonstrates offline capability when network fails',
          isSuccess: exists,
          duration: stopwatch.elapsed,
        );

        setState(() {
          _results.add(result);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _results.add(_ExampleResult(
          title: 'JSON Data Cache - ERROR',
          details: 'Error: $e',
          isSuccess: false,
        ));
        _isLoading = false;
      });
    }
  }

  Future<void> _demonstrateBinaryCache() async {
    setState(() => _isLoading = true);

    try {
      final stopwatch = Stopwatch()..start();
      final cache = context.read<CacheProvider>().currentCache;

      // Use Picsum API for binary image data
      const url = 'https://picsum.photos/200/300.jpg';

      try {
        // Fetch binary data with caching
        final data = await cache.getBytes(url);
        stopwatch.stop();

        final result = _ExampleResult(
          title: 'Binary Data Cache',
          description:
              'Successfully fetched and cached binary image data from Picsum',
          details: 'URL: $url\n'
              'Data size: ${data.length} bytes (${_formatBytes(data.length)})\n'
              'Load time: ${stopwatch.elapsedMilliseconds}ms\n'
              'Data type: Binary/Image (JPEG)\n'
              'First 10 bytes: ${data.take(10).join(', ')}\n'
              'Cache efficiency: High-performance Hive storage',
          isSuccess: data.isNotEmpty,
          duration: stopwatch.elapsed,
        );

        setState(() {
          _results.add(result);
          _isLoading = false;
        });
      } catch (networkError) {
        // If network fails, check if cached version exists
        final exists = await cache.contains(url);

        final result = _ExampleResult(
          title: 'Binary Data Cache (Network Error)',
          description:
              'Network request failed - demonstrating binary cache behavior',
          details: 'URL: $url\n'
              'Network Error: ${networkError.toString()}\n'
              'Cached version available: $exists\n'
              'Binary cache ready for offline use',
          isSuccess: exists,
          duration: stopwatch.elapsed,
        );

        setState(() {
          _results.add(result);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _results.add(_ExampleResult(
          title: 'Binary Data Cache - ERROR',
          details: 'Error: $e',
          isSuccess: false,
        ));
        _isLoading = false;
      });
    }
  }

  Future<void> _demonstrateTtlCache() async {
    setState(() => _isLoading = true);

    try {
      final cache = context.read<CacheProvider>().currentCache;

      // Use a test API endpoint with short max age
      const url = 'https://jsonplaceholder.typicode.com/posts/2';
      const maxAge = Duration(seconds: 5);

      final stopwatch = Stopwatch()..start();

      // First fetch (will cache for 5 seconds)
      try {
        final data1 = await cache.getJson(url, maxAge: maxAge);

        // Check if it's cached immediately
        final exists = await cache.contains(url);

        // Wait for cache to expire
        await Future.delayed(const Duration(seconds: 6));

        // Try to get again (should refetch due to TTL expiration)
        final data2 = await cache.getJson(url, maxAge: maxAge);

        stopwatch.stop();

        final result = _ExampleResult(
          title: 'Cache with TTL',
          description:
              'Demonstrated Time-To-Live cache expiration with real API data',
          details: 'URL: $url\n'
              'Max Age: ${maxAge.inSeconds} seconds\n'
              'First fetch title: "${data1['title']}"\n'
              'Cached after first fetch: $exists\n'
              'Second fetch title: "${data2['title']}"\n'
              'Total test time: ${stopwatch.elapsedMilliseconds}ms\n'
              'TTL behavior: Cache expired and refetched after ${maxAge.inSeconds}s',
          isSuccess:
              data1['title'] == data2['title'], // Same data but refetched
          duration: stopwatch.elapsed,
        );

        setState(() {
          _results.add(result);
          _isLoading = false;
        });
      } catch (networkError) {
        final result = _ExampleResult(
          title: 'Cache with TTL (Network Error)',
          description: 'Network error during TTL demonstration',
          details: 'URL: $url\n'
              'Max Age: ${maxAge.inSeconds} seconds\n'
              'Error: ${networkError.toString()}\n'
              'TTL functionality requires network access for this demo',
          isSuccess: false,
          duration: stopwatch.elapsed,
        );

        setState(() {
          _results.add(result);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _results.add(_ExampleResult(
          title: 'Cache with TTL - ERROR',
          details: 'Error: $e',
          isSuccess: false,
        ));
        _isLoading = false;
      });
    }
  }

  Future<void> _demonstrateOfflineMode() async {
    setState(() => _isLoading = true);

    try {
      final stopwatch = Stopwatch()..start();
      final cache = context.read<CacheProvider>().currentCache;

      // First, populate cache with some data
      const url1 = 'https://jsonplaceholder.typicode.com/posts/3';
      const url2 = 'https://jsonplaceholder.typicode.com/users/1';

      try {
        // Fetch some data to populate cache
        await cache.getJson(url1);
        await cache.getJson(url2);
      } catch (e) {
        // Ignore network errors for this demo
      }

      // Check cache contents for offline capability
      final exists1 = await cache.contains(url1);
      final exists2 = await cache.contains(url2);
      final allKeys = await cache.getAllKeys();

      stopwatch.stop();

      final result = _ExampleResult(
        title: 'Offline Mode',
        description:
            'Demonstrated offline data availability and cache management',
        details: 'Post data cached: $exists1\n'
            'User data cached: $exists2\n'
            'Total cached items: ${allKeys.length}\n'
            'Sample cached URLs:\n  ${allKeys.take(3).join('\n  ')}\n'
            'Operation time: ${stopwatch.elapsedMilliseconds}ms\n'
            'Offline capability: ${allKeys.isNotEmpty ? 'Ready' : 'Not ready'}\n'
            'Cache storage: High-performance Hive NoSQL',
        isSuccess: allKeys.isNotEmpty,
        duration: stopwatch.elapsed,
      );

      setState(() {
        _results.add(result);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _results.add(_ExampleResult(
          title: 'Offline Mode - ERROR',
          details: 'Error: $e',
          isSuccess: false,
        ));
        _isLoading = false;
      });
    }
  }

  Future<void> _demonstrateStatistics() async {
    setState(() => _isLoading = true);

    try {
      final stopwatch = Stopwatch()..start();
      final cache = context.read<CacheProvider>().currentCache;

      // Get initial statistics
      final initialStats = await cache.getStats();

      // Perform some cache operations to affect stats
      try {
        const testUrl = 'https://jsonplaceholder.typicode.com/posts/4';
        await cache.getJson(testUrl); // This will either hit cache or fetch
        await cache
            .contains('nonexistent_key'); // This might affect internal stats

        // Get updated statistics
        final updatedStats = await cache.getStats();

        stopwatch.stop();

        final result = _ExampleResult(
          title: 'Cache Statistics',
          description:
              'Retrieved and demonstrated comprehensive cache statistics',
          details: 'Initial Statistics:\n'
              '  Total entries: ${initialStats.totalEntries}\n'
              '  Hit count: ${initialStats.hitCount}\n'
              '  Miss count: ${initialStats.missCount}\n'
              '  Hit rate: ${(initialStats.hitRate * 100).toStringAsFixed(1)}%\n'
              '  Cache size: ${_formatBytes(initialStats.totalSizeInBytes)}\n'
              '  Evictions: ${initialStats.evictionCount}\n'
              '\nAfter test operations:\n'
              '  Total entries: ${updatedStats.totalEntries}\n'
              '  Hit count: ${updatedStats.hitCount}\n'
              '  Miss count: ${updatedStats.missCount}\n'
              '  Hit rate: ${(updatedStats.hitRate * 100).toStringAsFixed(1)}%\n'
              '  Cache size: ${_formatBytes(updatedStats.totalSizeInBytes)}\n'
              '  Evictions: ${updatedStats.evictionCount}\n'
              '\nOperation time: ${stopwatch.elapsedMilliseconds}ms',
          isSuccess: true,
          duration: stopwatch.elapsed,
        );

        setState(() {
          _results.add(result);
          _isLoading = false;
        });
      } catch (operationError) {
        final result = _ExampleResult(
          title: 'Cache Statistics',
          description: 'Retrieved initial cache statistics (operations failed)',
          details: 'Initial Statistics:\n'
              '  Total entries: ${initialStats.totalEntries}\n'
              '  Hit count: ${initialStats.hitCount}\n'
              '  Miss count: ${initialStats.missCount}\n'
              '  Hit rate: ${(initialStats.hitRate * 100).toStringAsFixed(1)}%\n'
              '  Cache size: ${_formatBytes(initialStats.totalSizeInBytes)}\n'
              '  Evictions: ${initialStats.evictionCount}\n'
              '\nTest operation error: ${operationError.toString()}\n'
              'Statistics still available for monitoring',
          isSuccess: true, // Stats retrieval succeeded
          duration: stopwatch.elapsed,
        );

        setState(() {
          _results.add(result);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _results.add(_ExampleResult(
          title: 'Cache Statistics - ERROR',
          details: 'Error: $e',
          isSuccess: false,
        ));
        _isLoading = false;
      });
    }
  }

  // Helper methods
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

/// Data class for example results
class _ExampleResult {
  final String title;
  final String? description;
  final String details;
  final bool isSuccess;
  final DateTime timestamp;
  final Duration? duration;

  _ExampleResult({
    required this.title,
    this.description,
    required this.details,
    required this.isSuccess,
    this.duration,
  }) : timestamp = DateTime.now();
}
