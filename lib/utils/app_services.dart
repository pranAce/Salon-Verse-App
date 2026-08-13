import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class AppServices {
  static final InternetConnectionChecker connectionChecker =
      InternetConnectionChecker.createInstance(
    checkTimeout: const Duration(seconds: 3),
  );

  static late SharedPreferences prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> hasConnection() async {
    try {
      return await connectionChecker.hasConnection;
    } catch (_) {
      return false;
    }
  }
}
