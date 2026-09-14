// Select native DNS only on platforms with dart:io.
export 'network_info_web.dart'
    if (dart.library.io) 'network_info_native_impl.dart';
