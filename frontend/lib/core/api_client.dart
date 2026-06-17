import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8001/api/v1',
  );

  final http.Client _http;
  String? token;

  Future<Map<String, dynamic>> get(String path) async {
    try {
      return _decode(await _http.get(_uri(path), headers: _headers()));
    } catch (e) {
      throw ApiException('Network error: $e', 0);
    }
  }

  Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    try {
      return _decode(await _http.post(_uri(path),
          headers: _headers(), body: jsonEncode(body)));
    } catch (e) {
      throw ApiException('Network error: $e', 0);
    }
  }

  Future<Map<String, dynamic>> put(
      String path, Map<String, dynamic> body) async {
    try {
      return _decode(await _http.put(_uri(path),
          headers: _headers(), body: jsonEncode(body)));
    } catch (e) {
      throw ApiException('Network error: $e', 0);
    }
  }

  Future<void> delete(String path) async {
    try {
      final response = await _http.delete(_uri(path), headers: _headers());
      if (response.statusCode >= 400) {
        final body = response.body.isEmpty
            ? <String, dynamic>{}
            : jsonDecode(response.body) as Map<String, dynamic>;
        throw ApiException(
            body['message']?.toString() ?? 'Delete failed', response.statusCode);
      }
    } catch (e) {
      throw ApiException('Network error: $e', 0);
    }
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
      String errorMessage = 'Request failed';
      
      if (response.statusCode == 401) {
        errorMessage = 'Unauthorized. Please login again.';
      } else if (response.statusCode == 403) {
        errorMessage = 'Access denied. You do not have permission.';
      } else if (response.statusCode == 404) {
        errorMessage = 'Resource not found.';
      } else if (response.statusCode == 422) {
        errorMessage = body['message'] ?? 'Validation failed. Please check your input.';
      } else if (body['message'] != null) {
        errorMessage = body['message'].toString();
      }
      
      throw ApiException(errorMessage, response.statusCode);
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
