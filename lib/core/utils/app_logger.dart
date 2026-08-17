class AppLogger {
  AppLogger._();

  static bool isLoggingEnabled = false;

  static void logApiRequest(
    String method,
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) {}

  static void logApiResponse(int statusCode, String url, String responseBody) {}

  static void logModelParse(String modelName, bool success, String details) {}

  static void logState(String screen, String stateTransition) {}

  static void logAction(String userAction, String relevantId) {}

  static void logApiError(
    String url,
    int statusCode,
    String errorType,
    String message,
  ) {}

  static void logBookingFlow({
    required String step,
    required String salonId,
    required String serviceId,
    String? stylistId,
    required String date,
    required String timeSlot,
    required String status,
  }) {}

  static void logAvailability({
    required String salonId,
    String? serviceId,
    String? stylistId,
    required String date,
    required int slotCount,
  }) {}

  static Future<void> clearLogs() async {}
}
