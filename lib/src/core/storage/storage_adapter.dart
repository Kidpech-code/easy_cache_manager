/// Platform-aware storage adapter selector for WASM compatibility
///
/// This library provides conditional imports to ensure proper platform support:
/// - Web: Uses WebStorageAdapter (localStorage) for WASM compatibility
/// - Native: Uses NativeStorageAdapter (path_provider) for file system access
library;

export 'web_storage_adapter.dart' if (dart.library.io) 'native_storage_adapter.dart';
