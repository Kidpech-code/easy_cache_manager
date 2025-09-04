// Web stub for path_provider to enable WASM compatibility
import 'dart:io' as io;

// Stub implementations for Web platform to avoid path_provider dependency
Future<io.Directory> getApplicationDocumentsDirectory() async {
  throw UnsupportedError(
      'getApplicationDocumentsDirectory is not supported on Web');
}

Future<io.Directory> getTemporaryDirectory() async {
  throw UnsupportedError('getTemporaryDirectory is not supported on Web');
}

Future<io.Directory> getApplicationCacheDirectory() async {
  throw UnsupportedError(
      'getApplicationCacheDirectory is not supported on Web');
}

Future<io.Directory> getApplicationSupportDirectory() async {
  throw UnsupportedError(
      'getApplicationSupportDirectory is not supported on Web');
}
