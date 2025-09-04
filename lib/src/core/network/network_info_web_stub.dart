import 'network_info.dart';

/// Web/WASM stub for NetworkInfoImpl
class NetworkInfoImpl implements NetworkInfo {
  @override
  Future<bool> get isConnected async => true; // Assume always online on web

  @override
  Future<bool> isHostReachable(String host) async => true;
}
