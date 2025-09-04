import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Mobile/Desktop storage adapter that uses path_provider
///
/// This adapter is used for platforms that support file system access
/// and don't have WASM compatibility concerns.
class NativeStorageAdapter {
  static Future<String> getDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<String> getSupportDirectory() async {
    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  static Future<String> getCacheDirectory() async {
    if (Platform.isIOS) {
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } else {
      final directory = await getApplicationCacheDirectory();
      return directory.path;
    }
  }
}
