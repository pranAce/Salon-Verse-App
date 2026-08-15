import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/network/base_client.dart';
import 'package:salonverse/models/support_ticket_model.dart';
import 'package:salonverse/models/user_model.dart';

class SupportService {
  final BaseClient _client = BaseClient.instance;

  bool get isMockMode => false;

  Future<ApiResult<SupportTicketModel>> createSupportTicket(
    UserModel? currentUser,
    String subject,
    String message,
  ) async {
    if (currentUser == null) return const Failure("Session required.");

    return _client.request<SupportTicketModel>(
      "POST",
      "/api/v1/support-tickets",
      auth: true,
      body: {'subject': subject, 'message': message},
      onSuccess: (data) =>
          SupportTicketModel.fromJson(Map<String, dynamic>.from(data)),
    );
  }

  Future<ApiResult<List<SupportTicketModel>>> getSupportTickets(
    UserModel? currentUser,
  ) async {
    if (currentUser == null) return const Failure("Session required.");

    return _client.request<List<SupportTicketModel>>(
      "GET",
      "/api/v1/support-tickets",
      auth: true,
      onSuccess: (data) {
        final List list = data is List ? data : [];
        return list
            .map(
              (e) => SupportTicketModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
      },
    );
  }

  Future<ApiResult<SupportTicketModel>> replyToTicket(
    String ticketId,
    String messageText,
  ) async {
    return _client.request<SupportTicketModel>(
      "POST",
      "/api/v1/support-tickets/$ticketId/reply",
      auth: true,
      body: {'messageText': messageText, 'sender': 'user'},
      onSuccess: (data) =>
          SupportTicketModel.fromJson(Map<String, dynamic>.from(data)),
    );
  }
}
