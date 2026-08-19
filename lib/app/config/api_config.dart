import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String prodUrl = 'https://api.salonverse.live';
  static const String localDesktopUrl = 'http://127.0.0.1:8080';
  static const String localAndroidUrl = 'http://10.0.2.2:8080';

  static String? customUrl;

  static String get baseUrl {
    if (customUrl != null && customUrl!.isNotEmpty) {
      return customUrl!;
    }
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    const useProd = bool.fromEnvironment('USE_PROD_URL', defaultValue: false);
    if (useProd) {
      return prodUrl;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return localDesktopUrl;
    }
    return localDesktopUrl;
  }

  static Map<String, String> headers([String? token]) {
    final map = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      map['Authorization'] = 'Bearer $token';
    }
    return map;
  }

  static String resolveImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) {
      return '$baseUrl$trimmed';
    }
    return '$baseUrl/$trimmed';
  }
}
