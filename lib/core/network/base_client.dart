import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/services/api_config.dart';

class BaseClient {
  static String get baseUrl => ApiConfig.baseUrl;
  static const Duration _timeout = Duration(seconds: 20);
  static const String _tokenKey = 'backend_access_token';

  static final BaseClient _instance = BaseClient._();
  static BaseClient get instance => _instance;
  BaseClient._();

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

    try {
      if (kDebugMode) {
        debugPrint('[BaseClient] $method $url');
      }

      http.Response response;
      final encodedBody = body != null ? jsonEncode(body) : null;

      if (method == "GET") {
        response = await http.get(url, headers: headers).timeout(_timeout);
      } else if (method == "POST") {
        response = await http
            .post(url, headers: headers, body: encodedBody)
            .timeout(_timeout);
      } else if (method == "PUT") {
        response = await http
            .put(url, headers: headers, body: encodedBody)
            .timeout(_timeout);
      } else if (method == "PATCH") {
        response = await http
            .patch(url, headers: headers, body: encodedBody)
            .timeout(_timeout);
      } else if (method == "DELETE") {
        response = await http.delete(url, headers: headers).timeout(_timeout);
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
      if (kDebugMode) debugPrint('[BaseClient Error] $e');
      return Failure(e.toString());
    }
  }
}
