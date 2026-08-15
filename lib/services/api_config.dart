class ApiConfig {
  static const String prodUrl = 'https://api.salonverse.live';
  static const String localUrl = 'http://localhost:3000';

  static String? customUrl;

  static String get baseUrl {
    if (customUrl != null && customUrl!.isNotEmpty) {
      return customUrl!;
    }
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    return prodUrl;
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
}
