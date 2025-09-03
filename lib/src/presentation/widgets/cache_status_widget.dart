import 'package:flutter/material.dart';
import '../cache_manager.dart';
import '../../domain/entities/cache_status.dart';

/// A widget that displays real-time cache status
class CacheStatusWidget extends StatelessWidget {
  final CacheManager cacheManager;
  final Widget Function(BuildContext, CacheStatusInfo)? builder;

  const CacheStatusWidget(
      {super.key, required this.cacheManager, this.builder});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CacheStatusInfo>(
      stream: cacheManager.statusStream,
      initialData: cacheManager.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? cacheManager.currentStatus;

        if (builder != null) {
          return builder!(context, status);
        }

        return _buildDefaultStatusWidget(context, status);
      },
    );
  }

  Widget _buildDefaultStatusWidget(
      BuildContext context, CacheStatusInfo status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _getStatusColor(status.status),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _getStatusIcon(status.status),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  status.message,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w500),
                ),
                if (status.loadTime != null &&
                    status.loadTime!.inMilliseconds > 0)
                  Text('Load time: ${status.loadTime!.inMilliseconds}ms',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
                if (status.sizeInBytes != null)
                  Text('Size: ${_formatBytes(status.sizeInBytes!)}',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(CacheStatus status) {
    switch (status) {
      case CacheStatus.loading:
        return Colors.blue;
      case CacheStatus.cached:
        return Colors.green;
      case CacheStatus.fresh:
        return Colors.teal;
      case CacheStatus.stale:
        return Colors.orange;
      case CacheStatus.error:
        return Colors.red;
      case CacheStatus.offline:
        return Colors.grey;
    }
  }

  Widget _getStatusIcon(CacheStatus status) {
    switch (status) {
      case CacheStatus.loading:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
        );
      case CacheStatus.cached:
        return const Icon(Icons.storage, color: Colors.white, size: 16);
      case CacheStatus.fresh:
        return const Icon(Icons.refresh, color: Colors.white, size: 16);
      case CacheStatus.stale:
        return const Icon(Icons.schedule, color: Colors.white, size: 16);
      case CacheStatus.error:
        return const Icon(Icons.error, color: Colors.white, size: 16);
      case CacheStatus.offline:
        return const Icon(Icons.wifi_off, color: Colors.white, size: 16);
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
