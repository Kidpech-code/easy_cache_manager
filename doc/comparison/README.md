# Fair comparison guide

This guide explains how to compare Easy Cache Manager fairly against alternatives across platforms and workloads.

## Principles for fair comparisons

- Same device, OS, and power mode (avoid thermal throttling; disable battery saver)
- Same Dart/Flutter versions and build mode (debug/profile/release)
- Same data: size, shape, and content (JSON vs binary, small vs large)
- Same number of iterations with warm-up runs discarded
- Stable network conditions or fully mocked network for pure cache tests
- Report methodology, not just numbers; include code or steps to reproduce

## What to measure

- Latency: average, median, p95, p99 (ms)
- Throughput: operations per second
- Hit rate: cache hits / total
- Storage size: total bytes on disk, entry count
- Memory footprint (optional): RSS or Dart heap if available

## Test scenarios matrix

- Basic key/value JSON (small < 1KB)
- Large JSON (1–10KB)
- Binary data (images/files): 10KB–5MB
- Mixed workload (reads/writes 50/50)
- Concurrency (e.g., 10–50 parallel operations)
- Expiry/eviction under pressure (optional)

## Running the included benchmark suite

Use `CacheBenchmarkSuite` for repeatable measurements:

```dart
import 'package:easy_cache_manager/easy_cache_manager.dart';
import 'package:easy_cache_manager/src/core/benchmarks/cache_benchmark_suite.dart';

final storage = HiveCacheStorage();
final suite = CacheBenchmarkSuite(storage: storage);
final report = await suite.runFullBenchmark(iterations: 1000);
print(report.toString());
await suite.cleanup();
```

Tips:
- Run multiple times; take medians
- Separate cold (first) vs warm cache results
- Pin CPU governor and close background apps where possible

## Comparing with alternatives

Structure your comparison so each library sees the same workload:

- Use identical data and iteration counts
- For network-backed caches, either mock HTTP or ensure the same network path and headers
- Use each library’s recommended configuration; list any tuning applied
- Capture: latency (avg/p95/p99), throughput, hit rate, storage size

Example template (fill with your results):

| Scenario | Library | Avg Read (ms) | p95 Read (ms) | Avg Write (ms) | Throughput (ops/s) | Hit Rate | Disk Size (MB) |
|---|---|---:|---:|---:|---:|---:|---:|
| Small JSON | Easy Cache Manager (Hive) | | | | | | |
| Small JSON | Alternative A | | | | | | |

## Interpreting results

- “Often faster” depends on payloads, platform, and device; avoid absolute claims
- Prefer medians and p95 to reduce outlier bias
- Note any trade-offs: size-on-disk vs speed, memory vs latency

## Reproducibility checklist

- Device/OS/Flutter versions recorded
- Iterations and scenarios listed
- Code snippets or repo link provided
- Mocking strategy (if any) described
- Environment constraints (emulator vs device) noted

## Caveats

- Web vs Mobile/Desktop storage APIs differ; compare within the same platform first
- Emulators/simulators don’t reflect real I/O or CPU consistently
- file system performance varies across OS and hardware

## Ethical claims guidance

- Avoid “fastest” claims; prefer “in our tests” with methodology
- Share raw data or scripts to enable verification
- Update comparisons periodically as dependencies evolve

## Built-in CLI comparator (dev-only)

We include a simple CLI to run identical workloads against Easy Cache Manager and a competitor (Stash in-memory) and export a CSV.

How to run:

1. Ensure dev dependencies are installed
2. Execute the harness

```
flutter pub get
dart run tool/compare_caches.dart --out comparison.csv --quick
```

Options:
- `--out <path>`: CSV output file (default: comparison.csv)
- `--quick`: Reduce workload sizes for a fast sanity run (recommended in CI)

Scenarios covered:
- Small JSON
- Large JSON
- Binary bytes
- Mixed workload

You can extend `tool/compare_caches.dart` to add more adapters or scenarios (e.g., disk-based competitors) following the same adapter interface.
