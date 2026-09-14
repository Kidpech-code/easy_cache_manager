/// Web/WASM stub for NativeStorageAdapter
class NativeStorageAdapter {
  static String get systemTempPath => throw UnsupportedError(
      'System temporary directories are unavailable on web');

  static Future<String> getDocumentsDirectory() async => '';
  static Future<String> getSupportDirectory() async => '';
  static Future<String> getCacheDirectory() async => '';
}
