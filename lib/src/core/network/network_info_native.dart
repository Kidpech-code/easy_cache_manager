import 'dart:io';
import 'package:http/http.dart' as http;
import 'network_info.dart';

class NetworkInfoImpl implements NetworkInfo {
  final http.Client httpClient;

  NetworkInfoImpl({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isHostReachable(String host) async {
    try {
      final uri = Uri.parse(host);
      final hostName = uri.host.isNotEmpty ? uri.host : host;
      final result = await InternetAddress.lookup(hostName);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
