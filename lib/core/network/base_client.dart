import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/app/config/api_config.dart';

class BaseClient {
  static String get baseUrl => ApiConfig.baseUrl;
  static const Duration _timeout = Duration(seconds: 20);
  static const String _tokenKey = 'backend_access_token';

  static final BaseClient _instance = BaseClient._();
  static BaseClient get instance => _instance;
  BaseClient._();

  http.Client _client = http.Client();

  void _resetClient() {
    try {
      _client.close();
    } catch (_) {}
    _client = http.Client();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<ApiResult<T>> request<T>(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
    required T Function(dynamic data) onSuccess,
    int maxAttempts = 2,
  }) async {
    final headers = <String, String>{
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    if (auth) {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }
    }

    final fullPath = path.startsWith('/') ? path : '/$path';
    final url = Uri.parse("$baseUrl$fullPath");

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        http.Response response;
        final encodedBody = body != null ? jsonEncode(body) : null;

        if (method == "GET") {
          response = await _client.get(url, headers: headers).timeout(_timeout);
        } else if (method == "POST") {
          response = await _client
              .post(url, headers: headers, body: encodedBody)
              .timeout(_timeout);
        } else if (method == "PUT") {
          response = await _client
              .put(url, headers: headers, body: encodedBody)
              .timeout(_timeout);
        } else if (method == "PATCH") {
          response = await _client
              .patch(url, headers: headers, body: encodedBody)
              .timeout(_timeout);
        } else if (method == "DELETE") {
          response = await _client
              .delete(url, headers: headers)
              .timeout(_timeout);
        } else {
          return const Failure("Unsupported HTTP method");
        }

        final json = response.body.isNotEmpty ? jsonDecode(response.body) : {};

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = json is Map<String, dynamic> && json.containsKey('data')
              ? json['data']
              : json;
          return Success(onSuccess(data));
        } else {
          final message = json is Map<String, dynamic>
              ? (json['message'] ?? 'Request failed (${response.statusCode})')
              : 'Request failed (${response.statusCode})';
          return Failure(message, statusCode: response.statusCode);
        }
      } catch (e) {
        _resetClient();
        if (attempt < maxAttempts) {
          await Future.delayed(const Duration(milliseconds: 250));
          continue;
        }
        final errText = e.toString();
        if (errText.contains('Connection closed') ||
            errText.contains('ClientException') ||
            errText.contains('SocketException')) {
          return const Failure("Network connection unavailable. Please check backend connection.");
        }
        return Failure(errText);
      }
    }
    return const Failure("Request failed after retries.");
  }
}
