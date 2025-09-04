// Web stub for path_provider to enable WASM compatibility

// Web-compatible directory stub class
class WebDirectory {
  final String _path;
  WebDirectory(this._path);
  String get path => _path;
}

// Stub implementations for Web platform to avoid path_provider dependency
Future<WebDirectory> getApplicationDocumentsDirectory() async {
  throw UnsupportedError(
      'getApplicationDocumentsDirectory is not supported on Web');
}

Future<WebDirectory> getTemporaryDirectory() async {
  throw UnsupportedError('getTemporaryDirectory is not supported on Web');
}

Future<WebDirectory> getApplicationCacheDirectory() async {
  throw UnsupportedError(
      'getApplicationCacheDirectory is not supported on Web');
}

Future<WebDirectory> getApplicationSupportDirectory() async {
  throw UnsupportedError(
      'getApplicationSupportDirectory is not supported on Web');
}
