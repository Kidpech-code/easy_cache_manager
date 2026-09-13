// Browser builds (JavaScript and WASM) must not import dart:io.
export 'native_storage_adapter_web.dart'
    if (dart.library.io) 'native_storage_adapter_native.dart';
