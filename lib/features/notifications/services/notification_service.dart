import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/network/base_client.dart';
import 'package:salonverse/features/notifications/models/notification_model.dart';

class NotificationService {
  final BaseClient _client = BaseClient.instance;

  Future<ApiResult<List<NotificationModel>>> getNotifications() async {
    return _client.request<List<NotificationModel>>(
      "GET",
      "/api/v1/notifications",
      auth: true,
      onSuccess: (data) {
        final List list = data is List
            ? data
            : (data is Map && data['data'] is List
                  ? data['data'] as List
                  : (data is Map && data['items'] is List
                        ? data['items'] as List
                        : []));
        return list
            .map(
              (e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
      },
    );
  }

  Future<ApiResult<void>> markAsRead(String notificationId) async {
    return _client.request<void>(
      "PATCH",
      "/api/v1/notifications/$notificationId/read",
      auth: true,
      onSuccess: (_) {},
    );
  }
}
