class ApiConfig {
  /// Optional custom override URL for local testing (e.g. 'http://10.0.1.11:5000')
  static String? customUrl;

  /// Active base URL: Defaults to deployed production backend (https://api.salonverse.live)
  static String get baseUrl {
    if (customUrl != null && customUrl!.isNotEmpty) {
      return customUrl!;
    }
    return 'https://api.salonverse.live';
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
