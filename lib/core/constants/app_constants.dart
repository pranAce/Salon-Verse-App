import 'package:salonverse/app/config/api_config.dart';

class KConstants {
  KConstants._();

  static String get apiBaseUrl => ApiConfig.baseUrl;

  static const String onboardingSeenKey = 'onboarding_seen';
  static const String themeModeKey = 'theme_mode';
  static const String accentColorKey = 'accent_color';
  static const String favoriteSalonsKey = 'favorite_salons';
  static const String userProfileKey = 'user_profile';
  static const String backendAccessTokenKey = 'backend_access_token';

  static const bool defaultMockMode = false;
}
