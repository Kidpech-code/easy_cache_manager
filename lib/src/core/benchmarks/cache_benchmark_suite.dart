import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import '../storage/platform_cache_storage.dart';

/// Comprehensive real-world benchmarking suite
///
/// Provides accurate performance measurements and comparisons
/// with different storage backends and realistic usage scenarios.
class CacheBenchmarkSuite {
  final PlatformCacheStorage storage;
  final Random _random = Random();

  CacheBenchmarkSuite({required this.storage});

  /// Run comprehensive benchmark suite
  Future<BenchmarkReport> runFullBenchmark({
    int iterations = 1000,
    bool includeHeavyTests = false,
  }) async {
    final report = BenchmarkReport();

    // Initialize storage
    await storage.initialize();

    // Basic Operations Benchmark
    final basicResults = await _benchmarkBasicOperations(iterations);
    report.basicOperations = basicResults;

    // JSON Data Benchmark
    final jsonResults = await _benchmarkJsonOperations(iterations ~/ 2);
    report.jsonOperations = jsonResults;

    // Binary Data Benchmark
    final binaryResults = await _benchmarkBinaryOperations(iterations ~/ 4);
    report.binaryOperations = binaryResults;

    // Concurrent Operations Benchmark
    final concurrentResults =
        await _benchmarkConcurrentOperations(iterations ~/ 10);
    report.concurrentOperations = concurrentResults;

    if (includeHeavyTests) {
      // Large Data Benchmark
      final largeDataResults = await _benchmarkLargeDataOperations();
      report.largeDataOperations = largeDataResults;

      // Memory Pressure Benchmark
      final memoryResults = await _benchmarkMemoryPressure();
      report.memoryPressure = memoryResults;
    }

    return report;
  }

  /// Benchmark basic read/write operations
  Future<BenchmarkResult> _benchmarkBasicOperations(int iterations) async {
    final stopwatch = Stopwatch();
    final writeTimings = <int>[];
    final readTimings = <int>[];
    int successfulWrites = 0;
    int successfulReads = 0;

    // Write benchmark
    for (int i = 0; i < iterations; i++) {
      final key = 'basic_key_$i';
      final data =
          'Basic test data for iteration $i with some content to make it realistic';

      stopwatch.reset();
      stopwatch.start();

      try {
        await storage.store(key, data, {
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'content_type': 'text/plain',
          'size_in_bytes': data.length,
        });
        stopwatch.stop();
        writeTimings.add(stopwatch.elapsedMicroseconds);
        successfulWrites++;
      } catch (e) {
        stopwatch.stop();
      }
    }

    // Read benchmark
    for (int i = 0; i < iterations; i++) {
      final key = 'basic_key_$i';

      stopwatch.reset();
      stopwatch.start();

      try {
        final entry = await storage.retrieve(key);
        stopwatch.stop();
        if (entry != null) {
          readTimings.add(stopwatch.elapsedMicroseconds);
          successfulReads++;
        }
      } catch (e) {
        stopwatch.stop();
      }
    }

    return BenchmarkResult(
      operationType: 'Basic Operations',
      totalIterations: iterations,
      successfulWrites: successfulWrites,
      successfulReads: successfulReads,
      writeTimings: writeTimings,
      readTimings: readTimings,
    );
  }

  /// Benchmark JSON data operations
  Future<BenchmarkResult> _benchmarkJsonOperations(int iterations) async {
    final stopwatch = Stopwatch();
    final writeTimings = <int>[];
    final readTimings = <int>[];
    int successfulWrites = 0;
    int successfulReads = 0;

    // Generate realistic JSON data
    for (int i = 0; i < iterations; i++) {
      final key = 'json_key_$i';
      final data = _generateRealisticJsonData(i);

      stopwatch.reset();
      stopwatch.start();

      try {
        await storage.store(key, data, {
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'content_type': 'application/json',
          'size_in_bytes': data.toString().length,
        });
        stopwatch.stop();
        writeTimings.add(stopwatch.elapsedMicroseconds);
        successfulWrites++;
      } catch (e) {
        stopwatch.stop();
      }
    }

    // Read benchmark
    for (int i = 0; i < iterations; i++) {
      final key = 'json_key_$i';

      stopwatch.reset();
      stopwatch.start();

      try {
        final entry = await storage.retrieve(key);
        stopwatch.stop();
        if (entry != null) {
          readTimings.add(stopwatch.elapsedMicroseconds);
          successfulReads++;
        }
      } catch (e) {
        stopwatch.stop();
      }
    }

    return BenchmarkResult(
      operationType: 'JSON Operations',
      totalIterations: iterations,
      successfulWrites: successfulWrites,
      successfulReads: successfulReads,
      writeTimings: writeTimings,
      readTimings: readTimings,
    );
  }

  /// Benchmark binary data operations
  Future<BenchmarkResult> _benchmarkBinaryOperations(int iterations) async {
    final stopwatch = Stopwatch();
    final writeTimings = <int>[];
    final readTimings = <int>[];
    int successfulWrites = 0;
    int successfulReads = 0;

    // Generate different sizes of binary data
    for (int i = 0; i < iterations; i++) {
      final key = 'binary_key_$i';
      final size = [1024, 5120, 10240, 25600][i % 4]; // 1KB, 5KB, 10KB, 25KB
      final data = _generateBinaryData(size);

      stopwatch.reset();
      stopwatch.start();

      try {
        await storage.storeBytes(key, data, {
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'content_type': 'application/octet-stream',
          'size_in_bytes': data.length,
        });
        stopwatch.stop();
        writeTimings.add(stopwatch.elapsedMicroseconds);
        successfulWrites++;
      } catch (e) {
        stopwatch.stop();
      }
    }

    // Read benchmark
    for (int i = 0; i < iterations; i++) {
      final key = 'binary_key_$i';

      stopwatch.reset();
      stopwatch.start();

      try {
        final data = await storage.retrieveBytes(key);
        stopwatch.stop();
        if (data != null) {
          readTimings.add(stopwatch.elapsedMicroseconds);
          successfulReads++;
        }
      } catch (e) {
        stopwatch.stop();
      }
    }

    return BenchmarkResult(
      operationType: 'Binary Operations',
      totalIterations: iterations,
      successfulWrites: successfulWrites,
      successfulReads: successfulReads,
      writeTimings: writeTimings,
      readTimings: readTimings,
    );
  }

  /// Benchmark concurrent operations
  Future<BenchmarkResult> _benchmarkConcurrentOperations(int iterations) async {
    const concurrency = 10; // Number of concurrent operations
    final operationsPerBatch = iterations ~/ concurrency;

    final stopwatch = Stopwatch();
    final allWriteTimings = <int>[];
    final allReadTimings = <int>[];
    int totalSuccessfulWrites = 0;
    int totalSuccessfulReads = 0;

    // Concurrent write benchmark
    stopwatch.start();

    final writeFutures = <Future>[];
    for (int batch = 0; batch < concurrency; batch++) {
      writeFutures.add(_concurrentWriteBatch(batch, operationsPerBatch));
    }

    final writeResults = await Future.wait(writeFutures);
    stopwatch.stop();

    // Process write results
    for (final result in writeResults) {
      final batchResult = result as Map<String, dynamic>;
      allWriteTimings.addAll(List<int>.from(batchResult['timings']));
      totalSuccessfulWrites += batchResult['successful'] as int;
    }

    // Concurrent read benchmark
    stopwatch.reset();
    stopwatch.start();

    final readFutures = <Future>[];
    for (int batch = 0; batch < concurrency; batch++) {
      readFutures.add(_concurrentReadBatch(batch, operationsPerBatch));
    }

    final readResults = await Future.wait(readFutures);
    stopwatch.stop();

    // Process read results
    for (final result in readResults) {
      final batchResult = result as Map<String, dynamic>;
      allReadTimings.addAll(List<int>.from(batchResult['timings']));
      totalSuccessfulReads += batchResult['successful'] as int;
    }

    return BenchmarkResult(
      operationType: 'Concurrent Operations (${concurrency}x)',
      totalIterations: iterations,
      successfulWrites: totalSuccessfulWrites,
      successfulReads: totalSuccessfulReads,
      writeTimings: allWriteTimings,
      readTimings: allReadTimings,
      metadata: {
        'concurrency_level': concurrency,
        'operations_per_batch': operationsPerBatch,
      },
    );
  }

  /// Benchmark large data operations
  Future<BenchmarkResult> _benchmarkLargeDataOperations() async {
    final sizes = [
      100 * 1024, // 100KB
      500 * 1024, // 500KB
      1024 * 1024, // 1MB
      5 * 1024 * 1024, // 5MB
    ];

    final stopwatch = Stopwatch();
    final writeTimings = <int>[];
    final readTimings = <int>[];
    int successfulWrites = 0;
    int successfulReads = 0;

    for (int i = 0; i < sizes.length; i++) {
      final key = 'large_data_${sizes[i]}_bytes';
      final data = _generateBinaryData(sizes[i]);

      // Write benchmark
      stopwatch.reset();
      stopwatch.start();

      try {
        await storage.storeBytes(key, data, {
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'content_type': 'application/octet-stream',
          'size_in_bytes': data.length,
        });
        stopwatch.stop();
        writeTimings.add(stopwatch.elapsedMicroseconds);
        successfulWrites++;
      } catch (e) {
        stopwatch.stop();
      }

      // Read benchmark
      stopwatch.reset();
      stopwatch.start();

      try {
        final retrievedData = await storage.retrieveBytes(key);
        stopwatch.stop();
        if (retrievedData != null && retrievedData.length == data.length) {
          readTimings.add(stopwatch.elapsedMicroseconds);
          successfulReads++;
        }
      } catch (e) {
        stopwatch.stop();
      }
    }

    return BenchmarkResult(
      operationType: 'Large Data Operations',
      totalIterations: sizes.length,
      successfulWrites: successfulWrites,
      successfulReads: successfulReads,
      writeTimings: writeTimings,
      readTimings: readTimings,
      metadata: {
        'tested_sizes': sizes.map(_formatBytes).toList(),
      },
    );
  }

  /// Benchmark memory pressure scenarios
  Future<BenchmarkResult> _benchmarkMemoryPressure() async {
    final stopwatch = Stopwatch();
    final writeTimings = <int>[];
    final readTimings = <int>[];
    int successfulWrites = 0;
    int successfulReads = 0;

    // Create memory pressure by storing many items
    const itemCount = 100;
    const itemSize = 50 * 1024; // 50KB per item = 5MB total

    stopwatch.start();

    // Fill cache to create memory pressure
    for (int i = 0; i < itemCount; i++) {
      final key = 'memory_pressure_$i';
      final data = _generateBinaryData(itemSize);

      final writeStart = stopwatch.elapsedMicroseconds;

      try {
        await storage.storeBytes(key, data, {
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'content_type': 'application/octet-stream',
          'size_in_bytes': data.length,
        });

        final writeEnd = stopwatch.elapsedMicroseconds;
        writeTimings.add(writeEnd - writeStart);
        successfulWrites++;
      } catch (e) {
        break;
      }
    }

    // Read under memory pressure
    for (int i = 0; i < successfulWrites; i++) {
      final key = 'memory_pressure_$i';

      final readStart = stopwatch.elapsedMicroseconds;

      try {
        final data = await storage.retrieveBytes(key);

        final readEnd = stopwatch.elapsedMicroseconds;

        if (data != null) {
          readTimings.add(readEnd - readStart);
          successfulReads++;
        }
      } catch (e) {
        // Ignore read errors
      }
    }

    stopwatch.stop();

    // Cleanup
    for (int i = 0; i < successfulWrites; i++) {
      try {
        await storage.remove('memory_pressure_$i');
      } catch (e) {
        // Ignore cleanup errors
      }
    }

    return BenchmarkResult(
      operationType: 'Memory Pressure',
      totalIterations: itemCount,
      successfulWrites: successfulWrites,
      successfulReads: successfulReads,
      writeTimings: writeTimings,
      readTimings: readTimings,
      metadata: {
        'item_size': _formatBytes(itemSize),
        'total_data': _formatBytes(itemCount * itemSize),
      },
    );
  }

  /// Helper method for concurrent write batch
  Future<Map<String, dynamic>> _concurrentWriteBatch(
      int batchId, int operations) async {
    final timings = <int>[];
    int successful = 0;
    final stopwatch = Stopwatch();

    for (int i = 0; i < operations; i++) {
      final key = 'concurrent_batch_${batchId}_item_$i';
      final data = 'Concurrent test data for batch $batchId, item $i';

      stopwatch.reset();
      stopwatch.start();

      try {
        await storage.store(key, data, {
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'content_type': 'text/plain',
          'size_in_bytes': data.length,
        });
        stopwatch.stop();
        timings.add(stopwatch.elapsedMicroseconds);
        successful++;
      } catch (e) {
        stopwatch.stop();
      }
    }

    return {
      'timings': timings,
      'successful': successful,
    };
  }

  /// Helper method for concurrent read batch
  Future<Map<String, dynamic>> _concurrentReadBatch(
      int batchId, int operations) async {
    final timings = <int>[];
    int successful = 0;
    final stopwatch = Stopwatch();

    for (int i = 0; i < operations; i++) {
      final key = 'concurrent_batch_${batchId}_item_$i';

      stopwatch.reset();
      stopwatch.start();

      try {
        final entry = await storage.retrieve(key);
        stopwatch.stop();
        if (entry != null) {
          timings.add(stopwatch.elapsedMicroseconds);
          successful++;
        }
      } catch (e) {
        stopwatch.stop();
      }
    }

    return {
      'timings': timings,
      'successful': successful,
    };
  }

  /// Generate realistic JSON data for benchmarking
  Map<String, dynamic> _generateRealisticJsonData(int index) {
    return {
      'id': index,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'user': {
        'id': _random.nextInt(10000),
        'name': 'User ${_random.nextInt(1000)}',
        'email': 'user${_random.nextInt(1000)}@example.com',
        'settings': {
          'theme': _random.nextBool() ? 'dark' : 'light',
          'notifications': _random.nextBool(),
          'language': ['en', 'es', 'fr', 'de'][_random.nextInt(4)],
        }
      },
      'content': {
        'title': 'Test Content $index',
        'body':
            'This is realistic test content with some length to simulate real-world data usage patterns. ' *
                _random.nextInt(5),
        'tags': List.generate(_random.nextInt(5) + 1, (i) => 'tag$i'),
        'metadata': {
          'views': _random.nextInt(1000000),
          'likes': _random.nextInt(10000),
          'comments': _random.nextInt(500),
        }
      },
      'system': {
        'version': '1.0.${_random.nextInt(100)}',
        'platform': ['web', 'mobile', 'desktop'][_random.nextInt(3)],
        'performance': {
          'loadTime': _random.nextDouble() * 1000,
          'renderTime': _random.nextDouble() * 100,
        }
      }
    };
  }

  /// Generate binary data for benchmarking
  Uint8List _generateBinaryData(int size) {
    final data = Uint8List(size);
    for (int i = 0; i < size; i++) {
      data[i] = _random.nextInt(256);
    }
    return data;
  }

  /// Format bytes for display
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Clean up benchmark data
  Future<void> cleanup() async {
    try {
      await storage.clear();
    } catch (e) {
      // Handle cleanup errors
    }
  }
}

/// Individual benchmark result
class BenchmarkResult {
  final String operationType;
  final int totalIterations;
  final int successfulWrites;
  final int successfulReads;
  final List<int> writeTimings;
  final List<int> readTimings;
  final Map<String, dynamic>? metadata;

  BenchmarkResult({
    required this.operationType,
    required this.totalIterations,
    required this.successfulWrites,
    required this.successfulReads,
    required this.writeTimings,
    required this.readTimings,
    this.metadata,
  });

  // Calculated properties
  double get averageWriteTimeMicros => writeTimings.isEmpty
      ? 0
      : writeTimings.reduce((a, b) => a + b) / writeTimings.length;
  double get averageReadTimeMicros => readTimings.isEmpty
      ? 0
      : readTimings.reduce((a, b) => a + b) / readTimings.length;

  double get averageWriteTimeMs => averageWriteTimeMicros / 1000;
  double get averageReadTimeMs => averageReadTimeMicros / 1000;

  double get writeSuccessRate =>
      totalIterations > 0 ? successfulWrites / totalIterations : 0;
  double get readSuccessRate =>
      totalIterations > 0 ? successfulReads / totalIterations : 0;

  int get p95WriteTime => _calculatePercentile(writeTimings, 0.95);
  int get p95ReadTime => _calculatePercentile(readTimings, 0.95);

  int get p99WriteTime => _calculatePercentile(writeTimings, 0.99);
  int get p99ReadTime => _calculatePercentile(readTimings, 0.99);

  int _calculatePercentile(List<int> values, double percentile) {
    if (values.isEmpty) return 0;
    final sorted = List<int>.from(values)..sort();
    final index = ((sorted.length - 1) * percentile).round();
    return sorted[index];
  }

  @override
  String toString() {
    return '''
$operationType Benchmark Results:
  Operations: $successfulWrites writes, $successfulReads reads out of $totalIterations iterations
  Success Rate: Write ${(writeSuccessRate * 100).toStringAsFixed(1)}%, Read ${(readSuccessRate * 100).toStringAsFixed(1)}%
  Average Time: Write ${averageWriteTimeMs.toStringAsFixed(2)}ms, Read ${averageReadTimeMs.toStringAsFixed(2)}ms
  P95 Time: Write ${(p95WriteTime / 1000).toStringAsFixed(2)}ms, Read ${(p95ReadTime / 1000).toStringAsFixed(2)}ms
  P99 Time: Write ${(p99WriteTime / 1000).toStringAsFixed(2)}ms, Read ${(p99ReadTime / 1000).toStringAsFixed(2)}ms
    ''';
  }
}

/// Complete benchmark report
class BenchmarkReport {
  BenchmarkResult? basicOperations;
  BenchmarkResult? jsonOperations;
  BenchmarkResult? binaryOperations;
  BenchmarkResult? concurrentOperations;
  BenchmarkResult? largeDataOperations;
  BenchmarkResult? memoryPressure;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('🚀 Cache Performance Benchmark Report');
    buffer.writeln('=' * 50);

    if (basicOperations != null) buffer.writeln(basicOperations);
    if (jsonOperations != null) buffer.writeln(jsonOperations);
    if (binaryOperations != null) buffer.writeln(binaryOperations);
    if (concurrentOperations != null) buffer.writeln(concurrentOperations);
    if (largeDataOperations != null) buffer.writeln(largeDataOperations);
    if (memoryPressure != null) buffer.writeln(memoryPressure);

    return buffer.toString();
  }

  /// Generate performance summary
  Map<String, dynamic> getSummary() {
    return {
      'basic_operations': basicOperations != null
          ? {
              'avg_write_ms': basicOperations!.averageWriteTimeMs,
              'avg_read_ms': basicOperations!.averageReadTimeMs,
              'write_success_rate': basicOperations!.writeSuccessRate,
              'read_success_rate': basicOperations!.readSuccessRate,
            }
          : null,
      'json_operations': jsonOperations != null
          ? {
              'avg_write_ms': jsonOperations!.averageWriteTimeMs,
              'avg_read_ms': jsonOperations!.averageReadTimeMs,
              'write_success_rate': jsonOperations!.writeSuccessRate,
              'read_success_rate': jsonOperations!.readSuccessRate,
            }
          : null,
      'binary_operations': binaryOperations != null
          ? {
              'avg_write_ms': binaryOperations!.averageWriteTimeMs,
              'avg_read_ms': binaryOperations!.averageReadTimeMs,
              'write_success_rate': binaryOperations!.writeSuccessRate,
              'read_success_rate': binaryOperations!.readSuccessRate,
            }
          : null,
      'concurrent_operations': concurrentOperations != null
          ? {
              'avg_write_ms': concurrentOperations!.averageWriteTimeMs,
              'avg_read_ms': concurrentOperations!.averageReadTimeMs,
              'write_success_rate': concurrentOperations!.writeSuccessRate,
              'read_success_rate': concurrentOperations!.readSuccessRate,
            }
          : null,
    };
  }
}
