import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/network/base_client.dart';
import 'package:salonverse/models/salon_model.dart';
import 'package:salonverse/models/user_model.dart';

class SalonService {
  final BaseClient _client = BaseClient.instance;
  List<SalonModel>? _cachedSalons;

  bool get isMockMode => false;

  Future<ApiResult<List<SalonModel>>> getSalons({
    String? query,
    String? category,
    double? lat,
    double? lng,
    double? radius,
    bool forceRefresh = false,
  }) async {
    final isAllFetch =
        (query == null || query.isEmpty) &&
        (category == null || category == 'All') &&
        lat == null &&
        lng == null;
    if (_cachedSalons != null && !forceRefresh && isAllFetch) {
      return Success(List<SalonModel>.from(_cachedSalons!));
    }

    final queryParams = <String>[];
    if (query != null && query.isNotEmpty) {
      queryParams.add('query=${Uri.encodeComponent(query)}');
    }
    if (category != null && category.isNotEmpty && category != 'All') {
      queryParams.add('category=${Uri.encodeComponent(category)}');
    }
    if (lat != null && lng != null) {
      queryParams.add('lat=$lat');
      queryParams.add('lng=$lng');
    }
    if (radius != null) {
      queryParams.add('radius=$radius');
    }

    final queryString = queryParams.isNotEmpty
        ? '?${queryParams.join('&')}'
        : '';

    final result = await _client.request<List<SalonModel>>(
      "GET",
      "/api/v1/salons$queryString",
      auth: false,
      onSuccess: (data) {
        final List list = data is List
            ? data
            : (data is Map && data['data'] is List
                ? data['data'] as List
                : (data is Map && data['items'] is List
                    ? data['items'] as List
                    : []));
        return list
            .map((e) => SalonModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );

    if (result is Success<List<SalonModel>> && isAllFetch) {
      _cachedSalons = List<SalonModel>.from(result.data);
    }
    return result;
  }

  Future<ApiResult<void>> toggleFavorite(
    String salonId,
    UserModel? currentUser,
    Function(UserModel) onUserUpdated,
  ) async {
    if (currentUser == null) return const Failure("User session not found.");

    final result = await _client.request(
      "POST",
      "/api/v1/users/toggle-favorite",
      auth: true,
      body: {"salonId": salonId},
      onSuccess: (data) => UserModel.fromJson(data),
    );

    if (result is Success<UserModel>) {
      onUserUpdated(result.data);
      return const Success(null);
    }
    return Failure(
      result is Failure
          ? (result as Failure).message
          : "Failed to toggle favorite",
    );
  }

  void clearCache() {
    _cachedSalons = null;
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
    final result = await _client.request<void>(
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
    if (result is Success) {
      clearCache();
    }
    return result;
  }
}
