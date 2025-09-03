import 'package:flutter/material.dart';
import 'package:easy_cache_manager/easy_cache_manager.dart';
// import 'package:fl_chart/fl_chart.dart'; // Uncomment if fl_chart is added

/// Widget สำหรับแสดง cache status/analytics (stub)

class CacheStatusDashboard extends StatefulWidget {
  final CacheManager cacheManager;
  const CacheStatusDashboard({required this.cacheManager, super.key});

  @override
  State<CacheStatusDashboard> createState() => _CacheStatusDashboardState();
}

class _CacheStatusDashboardState extends State<CacheStatusDashboard> {
  String? filterKey;
  DateTimeRange? filterRange;
  List<Map<String, dynamic>> entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final keys = await widget.cacheManager.getAllKeys();
    // TD: Load entry details for chart/filter
    setState(() {
      entries = keys.map((k) => {'key': k, 'size': 1}).toList(); // stub
    });
  }

  void _export(String format) {
    // TD: Export entries as JSON/CSV
    if (format == 'json') {
      // export as JSON
    } else if (format == 'csv') {
      // export as CSV
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Cache Entries: ${entries.length}')),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadEntries,
            ),
          ],
        ),
        // Filter UI
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(labelText: 'Filter by key'),
                onChanged: (v) => setState(() => filterKey = v),
              ),
            ),
            ElevatedButton(
              onPressed: () => _export('json'),
              child: const Text('Export JSON'),
            ),
            ElevatedButton(
              onPressed: () => _export('csv'),
              child: const Text('Export CSV'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // BarChart (stub)
        Container(
          height: 200,
          color: Colors.grey[200],
          child:
              const Center(child: Text('BarChart: cache size by key (stub)')),
          // TD: Integrate fl_chart BarChart with real data
        ),
        const SizedBox(height: 16),
        // List filtered entries
        Expanded(
          child: ListView(
            children: entries
                .where(
                    (e) => filterKey == null || e['key'].contains(filterKey!))
                .map((e) => ListTile(
                      title: Text(e['key']),
                      subtitle: Text('Size: ${e['size']}'),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
