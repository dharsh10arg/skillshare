import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  final http.Client _http;
  String? token;

  Future<Map<String, dynamic>> get(String path) async {
    return _decode(await _http.get(_uri(path), headers: _headers()));
  }

  Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    return _decode(await _http.post(_uri(path),
        headers: _headers(), body: jsonEncode(body)));
  }

  Future<Map<String, dynamic>> put(
      String path, Map<String, dynamic> body) async {
    return _decode(await _http.put(_uri(path),
        headers: _headers(), body: jsonEncode(body)));
  }

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _headers() => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Map<String, dynamic> _decode(http.Response response) {
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) {
      throw ApiException(
          body['message']?.toString() ?? 'Request failed', response.statusCode);
    }
    return body;
  }
}

class ApiException implements Exception {
  ApiException(this.message, this.statusCode);
  final String message;
  final int statusCode;

  @override
  String toString() => message;
}
