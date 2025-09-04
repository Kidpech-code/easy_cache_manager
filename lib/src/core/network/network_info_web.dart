import 'package:http/http.dart' as http;
import 'network_info.dart';

class NetworkInfoImpl implements NetworkInfo {
  final http.Client httpClient;

  NetworkInfoImpl({http.Client? httpClient})
      : httpClient = httpClient ?? http.Client();

  @override
  Future<bool> get isConnected async {
    try {
      // For Web, we try to make a simple HTTP request to check connectivity
      final response = await httpClient
          .head(
            Uri.parse('https://www.google.com'),
          )
          .timeout(
            const Duration(seconds: 5),
          );
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isHostReachable(String host) async {
    try {
      final uri = Uri.parse(host.startsWith('http') ? host : 'https://$host');
      final response = await httpClient.head(uri).timeout(
            const Duration(seconds: 5),
          );
      return response.statusCode >= 200 && response.statusCode < 500;
    } catch (_) {
      return false;
    }
  }
}
