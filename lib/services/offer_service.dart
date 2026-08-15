import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/network/base_client.dart';
import 'package:salonverse/models/offer_model.dart';

class OfferService {
  final BaseClient _client = BaseClient.instance;

  Future<ApiResult<List<OfferModel>>> getOffers() async {
    return _client.request<List<OfferModel>>(
      "GET",
      "/api/v1/offers",
      auth: false,
      onSuccess: (data) {
        final List list = data is List ? data : [];
        return list
            .map((e) => OfferModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
  }

  Future<ApiResult<Map<String, dynamic>>> validateOffer({
    required String code,
    required String salonId,
    required double orderAmount,
    String? category,
  }) async {
    return _client.request<Map<String, dynamic>>(
      "POST",
      "/api/v1/offers/validate",
      auth: false,
      body: {
        'code': code.trim().toUpperCase(),
        'salonId': salonId,
        'orderAmount': orderAmount,
        ...?category != null ? {'category': category} : null,
      },
      onSuccess: (data) => Map<String, dynamic>.from(data),
    );
  }
}
