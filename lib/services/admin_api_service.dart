import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/network/base_client.dart';

class AdminApiService {
  static final AdminApiService instance = AdminApiService._();
  AdminApiService._();

  final BaseClient _client = BaseClient.instance;

  bool get isMockMode => false;

  Future<ApiResult<Map<String, dynamic>>> getDashboardMetrics() async {
    return _client.request<Map<String, dynamic>>(
      "GET",
      "/api/v1/admin/dashboard",
      auth: true,
      onSuccess: (data) => Map<String, dynamic>.from(data is Map ? data : {}),
    );
  }

  Future<ApiResult<Map<String, dynamic>>> createStaff({
    required String salonId,
    required String email,
    required String password,
    required String name,
    String? phone,
    List<String> assignedServices = const [],
    Map<String, dynamic> schedule = const {},
  }) async {
    return _client.request<Map<String, dynamic>>(
      "POST",
      "/api/v1/admin/staff",
      auth: true,
      body: {
        'email': email,
        'password': password,
        'name': name,
        'phone': phone ?? '',
        'role': 'salon_staff',
        'assignedSalons': [salonId],
        'assignedServices': assignedServices,
        'schedule': schedule,
      },
      onSuccess: (data) => Map<String, dynamic>.from(data is Map ? data : {}),
    );
  }

  Future<ApiResult<void>> updateStaff({
    required String salonId,
    required String staffId,
    String? name,
    String? phone,
    List<String>? assignedServices,
    Map<String, dynamic>? schedule,
    String? status,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (assignedServices != null) body['assignedServices'] = assignedServices;
    if (schedule != null) body['schedule'] = schedule;
    if (status != null) body['status'] = status;

    return _client.request<void>(
      "PUT",
      "/api/v1/admin/staff/$staffId",
      auth: true,
      body: body,
      onSuccess: (_) {},
    );
  }

  Future<ApiResult<void>> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    return _client.request<void>(
      "PATCH",
      "/api/v1/bookings/$bookingId/status",
      auth: true,
      body: {'status': status},
      onSuccess: (_) {},
    );
  }

  Future<ApiResult<List<dynamic>>> getStaffList({
    required String salonId,
  }) async {
    final result = await _client.request<List<dynamic>>(
      "GET",
      "/api/v1/admin/users?role=salon_staff",
      auth: true,
      onSuccess: (data) => data is List ? data : [],
    );

    if (result is Success<List<dynamic>> && result.data.isNotEmpty) {
      return result;
    }

    return _client.request<List<dynamic>>(
      "GET",
      salonId.isNotEmpty
          ? "/api/v1/stylists/salon/$salonId"
          : "/api/v1/stylists",
      auth: true,
      onSuccess: (data) => data is List ? data : [],
    );
  }

  Future<ApiResult<void>> resetStaffPassword({
    required String salonId,
    required String staffId,
    required String newPassword,
  }) async {
    return _client.request<void>(
      "PATCH",
      "/api/v1/admin/users/$staffId",
      auth: true,
      body: {'password': newPassword},
      onSuccess: (_) {},
    );
  }

  Future<ApiResult<void>> saveService({
    required String salonId,
    required String id,
    required String name,
    required double price,
    required int durationMinutes,
    required String category,
    required String description,
  }) async {
    final isNew = id.isEmpty;
    final method = isNew ? "POST" : "PUT";
    final path = isNew
        ? "/api/v1/admin/services"
        : "/api/v1/admin/services/$id";

    return _client.request<void>(
      method,
      path,
      auth: true,
      body: {
        'salonId': salonId,
        'salon': salonId,
        'name': name,
        'price': price,
        'durationMinutes': durationMinutes,
        'category': category,
        'description': description,
      },
      onSuccess: (_) {},
    );
  }

  Future<ApiResult<void>> deleteService({
    required String salonId,
    required String serviceId,
  }) async {
    return _client.request<void>(
      "DELETE",
      "/api/v1/admin/services/$serviceId",
      auth: true,
      onSuccess: (_) {},
    );
  }

  Future<ApiResult<void>> updateSalon({
    required String salonId,
    required String name,
    required String phone,
    required String address,
    required String city,
    required String description,
    required String priceRange,
    String? imageUrl,
  }) async {
    return _client.request<void>(
      "PUT",
      "/api/v1/salons/$salonId",
      auth: true,
      body: {
        'name': name,
        'phoneNumber': phone,
        'address': address,
        'city': city,
        'description': description,
        'priceRange': priceRange,
        if (imageUrl != null && imageUrl.isNotEmpty) 'imageUrl': imageUrl,
      },
      onSuccess: (_) {},
    );
  }
}
