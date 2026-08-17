import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/network/base_client.dart';
import 'package:salonverse/models/target_model.dart';

class TargetService {
  final BaseClient _client = BaseClient.instance;

  Future<ApiResult<List<TargetModel>>> getTargets() async {
    return _client.request<List<TargetModel>>(
      "GET",
      "/api/v1/targets",
      auth: true,
      onSuccess: (data) {
        dynamic targetsList = data;
        if (data is Map && data.containsKey('targets')) {
          targetsList = data['targets'];
        } else if (data is Map && data.containsKey('items')) {
          targetsList = data['items'];
        }
        final List list = targetsList is List ? targetsList : [];
        return list
            .map((e) => TargetModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
  }

  Future<ApiResult<TargetModel>> createTarget({
    required String title,
    required String targetType,
    required String startDate,
    required String endDate,
    required double targetAmount,
    String? salonId,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'targetType': targetType,
      'startDate': startDate,
      'endDate': endDate,
      'targetAmount': targetAmount,
      if (salonId != null && salonId.isNotEmpty) 'salonId': salonId,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    return _client.request<TargetModel>(
      "POST",
      "/api/v1/targets",
      auth: true,
      body: body,
      onSuccess: (data) =>
          TargetModel.fromJson(Map<String, dynamic>.from(data)),
    );
  }

  Future<ApiResult<TargetModel>> updateTarget({
    required String id,
    String? title,
    double? targetAmount,
    String? startDate,
    String? endDate,
    String? notes,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (targetAmount != null) body['targetAmount'] = targetAmount;
    if (startDate != null) body['startDate'] = startDate;
    if (endDate != null) body['endDate'] = endDate;
    if (notes != null) body['notes'] = notes;
    if (status != null) body['status'] = status;

    return _client.request<TargetModel>(
      "PUT",
      "/api/v1/targets/$id",
      auth: true,
      body: body,
      onSuccess: (data) =>
          TargetModel.fromJson(Map<String, dynamic>.from(data)),
    );
  }

  Future<ApiResult<void>> deleteTarget(String id) async {
    return _client.request<void>(
      "DELETE",
      "/api/v1/targets/$id",
      auth: true,
      onSuccess: (_) {},
    );
  }
}
