import 'package:http/http.dart' as http;
import 'network_info_native.dart'
    if (dart.library.html) 'network_info_web.dart';

/// Network connectivity checker
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Future<bool> isHostReachable(String host);

  /// Factory constructor that returns platform-specific implementation
  factory NetworkInfo({http.Client? httpClient}) = NetworkInfoImpl;
}
