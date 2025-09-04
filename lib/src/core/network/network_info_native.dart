// Conditional import: native implementation (dart:io) or web stub
// In lib/src/core/network/network_info_native.dart
export 'network_info_native_impl.dart'
    if (dart.library.html) 'network_info_web_stub.dart';
