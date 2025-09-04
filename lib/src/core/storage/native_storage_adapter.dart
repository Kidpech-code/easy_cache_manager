// Conditional import: native implementation (dart:io) or web stub
// In lib/src/core/storage/native_storage_adapter.dart
export 'native_storage_adapter_native.dart'
    if (dart.library.html) 'native_storage_adapter_web.dart';
