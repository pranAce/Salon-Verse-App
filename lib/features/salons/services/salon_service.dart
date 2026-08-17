import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/network/base_client.dart';
import 'package:salonverse/features/salons/models/salon_model.dart';
import 'package:salonverse/features/auth/models/user_model.dart';
import 'package:salonverse/features/salons/models/nearby_service_model.dart';

class SalonService {
  final BaseClient _client = BaseClient.instance;
  List<SalonModel>? _cachedSalons;

  bool get isMockMode => false;

  void clearCache() {
    _cachedSalons = null;
  }

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
      _cachedSalons = result.data;
    }
    return result;
  }

  Future<ApiResult<SalonModel>> getSalonById(String id) async {
    return _client.request<SalonModel>(
      "GET",
      "/api/v1/salons/$id",
      auth: false,
      onSuccess: (data) {
        final map = data is Map<String, dynamic>
            ? data
            : (data is Map && data['data'] is Map
                ? Map<String, dynamic>.from(data['data'] as Map)
                : Map<String, dynamic>.from(data as Map));
        return SalonModel.fromJson(map);
      },
    );
  }

  Future<ApiResult<List<NearbyServiceModel>>> getNearbyServices({
    String? search,
    String? category,
    double? lat,
    double? lng,
    double? radius,
    String? sort,
  }) async {
    final queryParams = <String>[];
    if (search != null && search.trim().isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(search.trim())}');
    }
    if (category != null && category.trim().isNotEmpty && category != 'All') {
      queryParams.add('category=${Uri.encodeComponent(category.trim())}');
    }
    if (lat != null && lng != null) {
      queryParams.add('lat=$lat');
      queryParams.add('lng=$lng');
    }
    if (radius != null && radius > 0) {
      queryParams.add('radius=$radius');
    }
    if (sort != null && sort.isNotEmpty) {
      queryParams.add('sort=${Uri.encodeComponent(sort)}');
    }

    final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';

    return _client.request<List<NearbyServiceModel>>(
      "GET",
      "/api/v1/services/nearby$queryString",
      auth: false,
      onSuccess: (data) {
        final List list = data is List ? data : [];
        return list
            .map((e) => NearbyServiceModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
  }

  Future<ApiResult<void>> toggleFavorite(
    String salonId,
    UserModel? currentUser,
    Function(UserModel) onUserUpdated,
  ) async {
    if (currentUser == null) {
      return const Failure("User not logged in");
    }

    return _client.request<void>(
      "POST",
      "/api/v1/salons/$salonId/favorite",
      auth: true,
      onSuccess: (data) {
        final favorites = List<String>.from(currentUser.favoriteSalons);
        if (favorites.contains(salonId)) {
          favorites.remove(salonId);
        } else {
          favorites.add(salonId);
        }
        final updatedUser = currentUser.copyWith(favoriteSalons: favorites);
        onUserUpdated(updatedUser);
      },
    );
  }
}
