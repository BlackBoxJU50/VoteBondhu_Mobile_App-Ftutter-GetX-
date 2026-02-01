import 'package:http/http.dart' as http;

class AppHttpClientProvider {
  final http.Client client;

  AppHttpClientProvider({http.Client? client}) : client = client ?? http.Client();

  Future<http.Response> get(String url, {Map<String, String>? headers}) async {
    return client.get(Uri.parse(url), headers: headers);
  }

  void dispose() {
    client.close();
  }
}
