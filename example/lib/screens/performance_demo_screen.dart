import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math' as math;
import '../providers/cache_provider.dart';

/// 🚀 Performance Demo Screen
///
/// Comprehensive performance testing and benchmarking:
/// - Speed comparisons with/without cache
/// - Load testing scenarios
/// - Memory usage analysis
/// - Throughput measurements
/// - Real-world performance simulations
class PerformanceDemoScreen extends StatefulWidget {
  const PerformanceDemoScreen({super.key});

  @override
  State<PerformanceDemoScreen> createState() => _PerformanceDemoScreenState();
}

class _PerformanceDemoScreenState extends State<PerformanceDemoScreen>
    with TickerProviderStateMixin {
  String _selectedUserLevel = 'Beginner';
  bool _isTestRunning = false;
  final List<_BenchmarkResult> _testResults = [];
  _BenchmarkResult? _currentTest;

  // Animation controllers
  late AnimationController _progressController;
  late AnimationController _chartController;
  late Animation<double> _progressAnimation;
  late Animation<double> _chartAnimation;

  final List<String> _userLevels = ['Beginner', 'Intermediate', 'Expert'];

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _progressController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Testing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset all tests',
            onPressed: _isTestRunning ? null : _resetAllTests,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Level Selection
            _buildUserLevelSelector(),

            const SizedBox(height: 16),

            // Introduction based on user level
            _buildIntroduction(),

            const SizedBox(height: 16),

            // Performance Tests Grid
            _buildPerformanceTests(),

            const SizedBox(height: 16),

            // Current Test Progress
            if (_currentTest != null) _buildCurrentTestProgress(),

            const SizedBox(height: 16),

            // Test Results
            if (_testResults.isNotEmpty) _buildTestResults(),

            const SizedBox(height: 16),

            // Performance Insights
            if (_testResults.isNotEmpty) _buildPerformanceInsights(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserLevelSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Choose Your Experience Level',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _userLevels.map((level) {
                final isSelected = _selectedUserLevel == level;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getUserLevelIcon(level),
                        size: 16,
                        color: isSelected ? Colors.white : null,
                      ),
                      const SizedBox(width: 4),
                      Text(level),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected && !_isTestRunning) {
                      setState(() {
                        _selectedUserLevel = level;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              _getUserLevelDescription(_selectedUserLevel),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroduction() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: Colors.green[600]),
                const SizedBox(width: 8),
                Text(
                  'Performance Testing Suite',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _getIntroText(_selectedUserLevel),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline,
                      color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _getTipText(_selectedUserLevel),
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceTests() {
    final tests = _getTestsForUserLevel(_selectedUserLevel);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Performance Tests',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _selectedUserLevel == 'Beginner' ? 1 : 2,
            childAspectRatio: _selectedUserLevel == 'Beginner' ? 3 : 1.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: tests.length,
          itemBuilder: (context, index) {
            final test = tests[index];
            return _buildTestCard(test);
          },
        ),
      ],
    );
  }

  Widget _buildTestCard(_PerformanceTest test) {
    final hasResult = _testResults.any((r) => r.testName == test.name);
    final isCurrentTest = _currentTest?.testName == test.name;

    return Card(
      elevation: isCurrentTest ? 4 : 2,
      child: InkWell(
        onTap: _isTestRunning ? null : () => _runPerformanceTest(test),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: test.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(test.icon, color: test.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          test.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        if (_selectedUserLevel != 'Beginner') ...[
                          const SizedBox(height: 4),
                          Text(
                            '${test.operations} ops',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (hasResult)
                    Icon(Icons.check_circle,
                        color: Colors.green[600], size: 20),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                test.description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: _selectedUserLevel == 'Beginner' ? 2 : 3,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '~${test.estimatedDuration}s',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(test.difficulty)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      test.difficulty,
                      style: TextStyle(
                        fontSize: 10,
                        color: _getDifficultyColor(test.difficulty),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTestProgress() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.science, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Running: ${_currentTest!.testName}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor: Colors.blue[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              _currentTest!.statusMessage,
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResults() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: Colors.purple[600]),
                const SizedBox(width: 8),
                Text(
                  'Test Results',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _exportResults,
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Export'),
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
                    painter: _ResultsChartPainter(
                      results: _testResults,
                      animation: _chartAnimation.value,
                      userLevel: _selectedUserLevel,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildResultsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsTable() {
    return Column(
      children: _testResults.map((result) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getResultColor(result),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Text(
                  result.testName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              if (_selectedUserLevel != 'Beginner') ...[
                Expanded(
                  child: Text(
                    '${result.withCache.toStringAsFixed(1)}ms',
                    style: TextStyle(color: Colors.green[600]),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${result.withoutCache.toStringAsFixed(1)}ms',
                    style: TextStyle(color: Colors.red[600]),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getImprovementColor(result.improvement)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${result.improvement.toStringAsFixed(0)}x faster',
                    style: TextStyle(
                      color: _getImprovementColor(result.improvement),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPerformanceInsights() {
    final insights = _generateInsights();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Text(
                  'Performance Insights',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...insights.map((insight) => _buildInsightItem(insight)),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(_PerformanceInsight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: insight.color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: insight.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(insight.icon, color: insight.color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: insight.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: const TextStyle(fontSize: 13),
                ),
                if (insight.recommendation.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            insight.recommendation,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Performance test execution
  Future<void> _runPerformanceTest(_PerformanceTest test) async {
    if (_isTestRunning) return;

    setState(() {
      _isTestRunning = true;
      _currentTest = _BenchmarkResult(
        testName: test.name,
        withCache: 0,
        withoutCache: 0,
        operations: test.operations,
        statusMessage: 'Initializing test...',
        timestamp: DateTime.now(),
      );
    });

    _progressController.reset();
    _progressController.forward();

    try {
      final cache = context.read<CacheProvider>().currentCache;

      // Update status
      setState(() {
        _currentTest = _currentTest!.copyWith(
          statusMessage: 'Running test without cache...',
        );
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // Test without cache
      final stopwatchWithoutCache = Stopwatch()..start();
      for (int i = 0; i < test.operations; i++) {
        await test.testFunction(cache, false, i);
        if (i % (test.operations ~/ 10) == 0) {
          setState(() {
            _currentTest = _currentTest!.copyWith(
              statusMessage:
                  'Without cache: ${((i / test.operations) * 100).toInt()}%',
            );
          });
        }
      }
      stopwatchWithoutCache.stop();
      final withoutCacheTime =
          stopwatchWithoutCache.elapsedMilliseconds.toDouble();

      // Update status
      setState(() {
        _currentTest = _currentTest!.copyWith(
          statusMessage: 'Running test with cache...',
        );
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // Test with cache
      final stopwatchWithCache = Stopwatch()..start();
      for (int i = 0; i < test.operations; i++) {
        await test.testFunction(cache, true, i);
        if (i % (test.operations ~/ 10) == 0) {
          setState(() {
            _currentTest = _currentTest!.copyWith(
              statusMessage:
                  'With cache: ${((i / test.operations) * 100).toInt()}%',
            );
          });
        }
      }
      stopwatchWithCache.stop();
      final withCacheTime = stopwatchWithCache.elapsedMilliseconds.toDouble();

      // Calculate results
      final improvement = withoutCacheTime / withCacheTime;
      final result = _BenchmarkResult(
        testName: test.name,
        withCache: withCacheTime,
        withoutCache: withoutCacheTime,
        operations: test.operations,
        statusMessage: 'Complete',
        timestamp: DateTime.now(),
      );

      setState(() {
        _testResults.removeWhere((r) => r.testName == test.name);
        _testResults.add(result);
        _currentTest = null;
        _isTestRunning = false;
      });

      _chartController.reset();
      _chartController.forward();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${test.name} completed! ${improvement.toStringAsFixed(1)}x faster with cache',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _currentTest = null;
        _isTestRunning = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetAllTests() {
    setState(() {
      _testResults.clear();
      _currentTest = null;
    });
    _chartController.reset();
  }

  void _exportResults() {
    // In a real app, this would export to a file
    final export = _testResults
        .map((r) => {
              'test': r.testName,
              'withCache': r.withCache,
              'withoutCache': r.withoutCache,
              'improvement':
                  '${(r.withoutCache / r.withCache).toStringAsFixed(2)}x',
              'operations': r.operations,
              'timestamp': r.timestamp.toIso8601String(),
            })
        .toList();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Would export ${_testResults.length} test results'),
        action: SnackBarAction(
          label: 'View Data',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Export Data'),
                content: SingleChildScrollView(
                  child: Text(
                    export.map((e) => e.toString()).join('\n\n'),
                    style:
                        const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper methods
  IconData _getUserLevelIcon(String level) {
    switch (level) {
      case 'Beginner':
        return Icons.school;
      case 'Intermediate':
        return Icons.code;
      case 'Expert':
        return Icons.rocket_launch;
      default:
        return Icons.person;
    }
  }

  String _getUserLevelDescription(String level) {
    switch (level) {
      case 'Beginner':
        return 'Simple tests with clear explanations - perfect for learning!';
      case 'Intermediate':
        return 'More detailed metrics and multiple test scenarios';
      case 'Expert':
        return 'Advanced benchmarks with comprehensive analysis tools';
      default:
        return '';
    }
  }

  String _getIntroText(String level) {
    switch (level) {
      case 'Beginner':
        return r'Welcome to performance testing! These tests will show you how much faster your app can be with caching. Do not worry - everything is explained in simple terms.';
      case 'Intermediate':
        return r'These performance tests will help you understand cache behavior under different conditions. You will see detailed metrics and can compare multiple scenarios.';
      case 'Expert':
        return 'Comprehensive performance benchmarking suite with advanced metrics, statistical analysis, and detailed profiling data for production optimization.';
      default:
        return '';
    }
  }

  String _getTipText(String level) {
    switch (level) {
      case 'Beginner':
        return 'Tip: Start with "Basic Read Test" to see the magic of caching in action!';
      case 'Intermediate':
        return 'Tip: Run multiple tests to see how caching helps different types of operations.';
      case 'Expert':
        return 'Tip: Compare results across different cache configurations for optimization insights.';
      default:
        return '';
    }
  }

  List<_PerformanceTest> _getTestsForUserLevel(String level) {
    final allTests = [
      // Beginner Tests
      _PerformanceTest(
        name: 'Basic Read Test',
        description:
            'Simple test reading the same data multiple times. Perfect for seeing how caching speeds things up!',
        operations: level == 'Beginner' ? 50 : 100,
        estimatedDuration: 3,
        difficulty: 'Easy',
        icon: Icons.visibility,
        color: Colors.green,
        testFunction: (cache, useCache, i) async {
          const key = 'basic_read_test';
          if (useCache) {
            await cache.get<String>(key, () async {
              await Future.delayed(const Duration(milliseconds: 10));
              return 'Test data $i';
            });
          } else {
            await Future.delayed(const Duration(milliseconds: 10));
          }
        },
      ),

      _PerformanceTest(
        name: 'Write Performance',
        description:
            'Tests how fast we can save data. Shows the difference between cached and non-cached writes.',
        operations: level == 'Beginner' ? 30 : 75,
        estimatedDuration: 4,
        difficulty: 'Easy',
        icon: Icons.edit,
        color: Colors.blue,
        testFunction: (cache, useCache, i) async {
          if (useCache) {
            await cache.set('write_test_$i', 'Data $i');
          } else {
            await Future.delayed(const Duration(milliseconds: 12));
          }
        },
      ),

      // Intermediate Tests
      if (level != 'Beginner') ...[
        _PerformanceTest(
          name: 'Bulk Operations',
          description:
              'Tests performance when handling many operations at once. Important for real-world apps.',
          operations: level == 'Intermediate' ? 200 : 500,
          estimatedDuration: 6,
          difficulty: 'Medium',
          icon: Icons.list,
          color: Colors.orange,
          testFunction: (cache, useCache, i) async {
            if (useCache) {
              final futures = List.generate(5, (j) async {
                return await cache.get<String>('bulk_$i$j', () async {
                  await Future.delayed(const Duration(milliseconds: 5));
                  return 'Bulk data $i$j';
                });
              });
              await Future.wait(futures);
            } else {
              await Future.delayed(const Duration(milliseconds: 25));
            }
          },
        ),
        _PerformanceTest(
          name: 'Mixed Workload',
          description:
              'Combines reads, writes, and updates to simulate real application usage patterns.',
          operations: 150,
          estimatedDuration: 5,
          difficulty: 'Medium',
          icon: Icons.shuffle,
          color: Colors.purple,
          testFunction: (cache, useCache, i) async {
            final operation = i % 3;
            if (useCache) {
              switch (operation) {
                case 0: // Read
                  await cache.get<String>('mixed_read_$i', () async {
                    await Future.delayed(const Duration(milliseconds: 8));
                    return 'Mixed read $i';
                  });
                  break;
                case 1: // Write
                  await cache.set('mixed_write_$i', 'Mixed write $i');
                  break;
                case 2: // Update
                  await cache.get<String>('mixed_update_$i', () async {
                    await Future.delayed(const Duration(milliseconds: 6));
                    return 'Updated $i';
                  });
                  break;
              }
            } else {
              await Future.delayed(const Duration(milliseconds: 15));
            }
          },
        ),
      ],

      // Expert Tests
      if (level == 'Expert') ...[
        _PerformanceTest(
          name: 'High Concurrency',
          description:
              'Tests cache performance under high concurrent load with multiple parallel operations.',
          operations: 1000,
          estimatedDuration: 8,
          difficulty: 'Hard',
          icon: Icons.multiple_stop,
          color: Colors.red,
          testFunction: (cache, useCache, i) async {
            if (useCache) {
              final futures = List.generate(3, (j) async {
                return await cache.get<String>('concurrent_$i$j', () async {
                  await Future.delayed(const Duration(milliseconds: 3));
                  return 'Concurrent data $i$j';
                });
              });
              await Future.wait(futures);
            } else {
              await Future.delayed(const Duration(milliseconds: 9));
            }
          },
        ),
        _PerformanceTest(
          name: 'Memory Stress Test',
          description:
              'Tests cache behavior with large data objects and memory pressure scenarios.',
          operations: 200,
          estimatedDuration: 10,
          difficulty: 'Hard',
          icon: Icons.memory,
          color: Colors.deepPurple,
          testFunction: (cache, useCache, i) async {
            final largeData =
                List.generate(1000, (j) => 'Large data item $i$j').join(' ');
            if (useCache) {
              await cache.get<String>('memory_test_$i', () async {
                await Future.delayed(const Duration(milliseconds: 20));
                return largeData;
              });
            } else {
              await Future.delayed(const Duration(milliseconds: 20));
            }
          },
        ),
        _PerformanceTest(
          name: 'Cache Eviction Patterns',
          description:
              'Analyzes performance during cache eviction scenarios and memory management.',
          operations: 300,
          estimatedDuration: 7,
          difficulty: 'Hard',
          icon: Icons.auto_delete,
          color: Colors.brown,
          testFunction: (cache, useCache, i) async {
            if (useCache) {
              // Force cache growth and eviction
              await cache.set('eviction_test_$i', 'Eviction data $i');
              if (i % 10 == 0) {
                await cache.get<String>('eviction_read_$i', () async {
                  await Future.delayed(const Duration(milliseconds: 5));
                  return 'Eviction read $i';
                });
              }
            } else {
              await Future.delayed(const Duration(milliseconds: 8));
            }
          },
        ),
      ],
    ];

    return allTests;
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getResultColor(_BenchmarkResult result) {
    final improvement = result.withoutCache / result.withCache;
    if (improvement > 5) return Colors.green;
    if (improvement > 3) return Colors.blue;
    if (improvement > 2) return Colors.orange;
    return Colors.red;
  }

  Color _getImprovementColor(double improvement) {
    if (improvement > 5) return Colors.green;
    if (improvement > 3) return Colors.blue;
    if (improvement > 2) return Colors.orange;
    return Colors.red;
  }

  List<_PerformanceInsight> _generateInsights() {
    if (_testResults.isEmpty) return [];

    final insights = <_PerformanceInsight>[];
    final totalTests = _testResults.length;
    final averageImprovement = _testResults
            .map((r) => r.withoutCache / r.withCache)
            .reduce((a, b) => a + b) /
        totalTests;

    // Overall performance insight
    if (averageImprovement > 4) {
      insights.add(_PerformanceInsight(
        title: 'Excellent Cache Performance!',
        description:
            'Your cache is providing outstanding performance improvements across all tests. Average ${averageImprovement.toStringAsFixed(1)}x faster!',
        recommendation:
            'Keep using these caching patterns in your production applications.',
        icon: Icons.star,
        color: Colors.green,
      ));
    } else if (averageImprovement > 2) {
      insights.add(_PerformanceInsight(
        title: 'Good Performance Gains',
        description:
            'Cache is providing solid performance benefits. Average ${averageImprovement.toStringAsFixed(1)}x improvement.',
        recommendation:
            'Consider optimizing cache configuration for even better results.',
        icon: Icons.thumb_up,
        color: Colors.blue,
      ));
    } else {
      insights.add(_PerformanceInsight(
        title: 'Room for Improvement',
        description:
            'Cache performance could be better. Average ${averageImprovement.toStringAsFixed(1)}x improvement.',
        recommendation:
            'Review cache size, TTL settings, and eviction policies.',
        icon: Icons.warning,
        color: Colors.orange,
      ));
    }

    // Best performing test
    final bestTest = _testResults.reduce((a, b) =>
        (a.withoutCache / a.withCache) > (b.withoutCache / b.withCache)
            ? a
            : b);
    insights.add(_PerformanceInsight(
      title: 'Best Test: ${bestTest.testName}',
      description:
          'This test showed the highest performance gain: ${(bestTest.withoutCache / bestTest.withCache).toStringAsFixed(1)}x faster.',
      recommendation:
          'This pattern works exceptionally well for your use case.',
      icon: Icons.trending_up,
      color: Colors.green,
    ));

    // Operations insight
    final totalOperations =
        _testResults.map((r) => r.operations).reduce((a, b) => a + b);
    insights.add(_PerformanceInsight(
      title: 'Operations Completed',
      description:
          'Successfully completed $totalOperations cache operations across $totalTests different test scenarios.',
      recommendation: 'Great job testing various cache patterns!',
      icon: Icons.assessment,
      color: Colors.purple,
    ));

    return insights;
  }
}

// Data classes
class _PerformanceTest {
  final String name;
  final String description;
  final int operations;
  final int estimatedDuration;
  final String difficulty;
  final IconData icon;
  final Color color;
  final Future<void> Function(dynamic cache, bool useCache, int iteration)
      testFunction;

  _PerformanceTest({
    required this.name,
    required this.description,
    required this.operations,
    required this.estimatedDuration,
    required this.difficulty,
    required this.icon,
    required this.color,
    required this.testFunction,
  });
}

class _BenchmarkResult {
  final String testName;
  final double withCache;
  final double withoutCache;
  final int operations;
  final String statusMessage;
  final DateTime timestamp;

  _BenchmarkResult({
    required this.testName,
    required this.withCache,
    required this.withoutCache,
    required this.operations,
    required this.statusMessage,
    required this.timestamp,
  });

  double get improvement => withoutCache / withCache;

  _BenchmarkResult copyWith({
    String? testName,
    double? withCache,
    double? withoutCache,
    int? operations,
    String? statusMessage,
    DateTime? timestamp,
  }) {
    return _BenchmarkResult(
      testName: testName ?? this.testName,
      withCache: withCache ?? this.withCache,
      withoutCache: withoutCache ?? this.withoutCache,
      operations: operations ?? this.operations,
      statusMessage: statusMessage ?? this.statusMessage,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class _PerformanceInsight {
  final String title;
  final String description;
  final String recommendation;
  final IconData icon;
  final Color color;

  _PerformanceInsight({
    required this.title,
    required this.description,
    required this.recommendation,
    required this.icon,
    required this.color,
  });
}

// Custom Chart Painter for Results
class _ResultsChartPainter extends CustomPainter {
  final List<_BenchmarkResult> results;
  final double animation;
  final String userLevel;

  _ResultsChartPainter({
    required this.results,
    required this.animation,
    required this.userLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (results.isEmpty) return;

    final barWidth = size.width / (results.length * 2 + 1);
    final maxValue = results
        .map((r) => math.max(r.withCache, r.withoutCache))
        .reduce(math.max);

    for (int i = 0; i < results.length; i++) {
      final result = results[i];
      final x = barWidth * (i * 2 + 1);

      // Draw bars
      _drawBar(canvas, size, x, barWidth * 0.4, result.withCache, maxValue,
          Colors.green, animation);
      _drawBar(canvas, size, x + barWidth * 0.5, barWidth * 0.4,
          result.withoutCache, maxValue, Colors.red, animation);

      // Draw labels if not beginner
      if (userLevel != 'Beginner') {
        _drawLabel(
            canvas, x + barWidth * 0.25, size.height - 10, result.testName);
      }
    }

    // Draw legend
    _drawLegend(canvas, size);
  }

  void _drawBar(Canvas canvas, Size size, double x, double width, double value,
      double maxValue, Color color, double animation) {
    final normalizedHeight =
        (value / maxValue) * (size.height * 0.8) * animation;
    final rect = Rect.fromLTWH(
      x,
      size.height * 0.9 - normalizedHeight,
      width,
      normalizedHeight,
    );

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(rect, paint);
  }

  void _drawLabel(Canvas canvas, double x, double y, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text.length > 10 ? '${text.substring(0, 10)}...' : text,
        style: const TextStyle(color: Colors.black, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y));
  }

  void _drawLegend(Canvas canvas, Size size) {
    const legendY = 10.0;

    // With cache legend
    final greenPaint = Paint()..color = Colors.green;
    canvas.drawRect(const Rect.fromLTWH(10, legendY, 15, 10), greenPaint);

    final withCacheTextPainter = TextPainter(
      text: const TextSpan(
          text: 'With Cache',
          style: TextStyle(color: Colors.black, fontSize: 12)),
      textDirection: TextDirection.ltr,
    );
    withCacheTextPainter.layout();
    withCacheTextPainter.paint(canvas, const Offset(30, legendY));

    // Without cache legend
    final redPaint = Paint()..color = Colors.red;
    canvas.drawRect(const Rect.fromLTWH(120, legendY, 15, 10), redPaint);

    final withoutCacheTextPainter = TextPainter(
      text: const TextSpan(
          text: 'Without Cache',
          style: TextStyle(color: Colors.black, fontSize: 12)),
      textDirection: TextDirection.ltr,
    );
    withoutCacheTextPainter.layout();
    withoutCacheTextPainter.paint(canvas, const Offset(140, legendY));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
