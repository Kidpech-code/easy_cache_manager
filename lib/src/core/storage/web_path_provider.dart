// Web-compatible path_provider implementation for WASM support
// This file is imported conditionally instead of path_provider for web platforms

/// Web directory implementation with compatible API
class Directory {
  final String _path;
  Directory(this._path);

  /// Get directory path
  String get path => _path;

  /// Creates directory if needed (no-op on web)
  static Directory createTempSync(String prefix) => Directory('/$prefix');
}

// Stub implementations for Web platform to avoid path_provider dependency
/// Get application documents directory (Web compatible)
Future<Directory> getApplicationDocumentsDirectory() async {
  return Directory('/documents');
}

/// Get temporary directory (Web compatible)
Future<Directory> getTemporaryDirectory() async {
  return Directory('/temp');
}

/// Get application cache directory (Web compatible)
Future<Directory> getApplicationCacheDirectory() async {
  return Directory('/cache');
}

/// Get application support directory (Web compatible)
Future<Directory> getApplicationSupportDirectory() async {
  return Directory('/support');
}
