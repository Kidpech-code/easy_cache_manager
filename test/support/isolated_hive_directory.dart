import 'dart:io';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _TestPathProvider extends PathProviderPlatform {
  _TestPathProvider(this.path);

  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;

  @override
  Future<String?> getApplicationCachePath() async => path;

  @override
  Future<String?> getTemporaryPath() async => path;
}

/// Give each test file its own Hive location when flutter test runs in parallel.
class IsolatedHiveDirectory {
  late final Directory _directory;
  late final PathProviderPlatform _originalProvider;

  Future<void> open() async {
    _directory = await Directory.systemTemp.createTemp('easy_cache_test_');
    _originalProvider = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _TestPathProvider(_directory.path);
  }

  Future<void> close() async {
    PathProviderPlatform.instance = _originalProvider;
    await _directory.delete(recursive: true);
  }
}
