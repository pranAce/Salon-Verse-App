import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/network/base_client.dart';
import 'package:salonverse/features/salons/models/review_model.dart';

class ReviewService {
  final BaseClient _client = BaseClient.instance;

  Future<ApiResult<List<ReviewModel>>> getReviewsForSalon(
    String salonId,
  ) async {
    return _client.request<List<ReviewModel>>(
      "GET",
      "/api/v1/reviews/salon/$salonId",
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
            .map((e) => ReviewModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
  }

  Future<ApiResult<ReviewModel>> submitReview({
    required String salonId,
    required double rating,
    required String comment,
    String? bookingId,
  }) async {
    final body = <String, dynamic>{
      'salonId': salonId,
      'rating': rating,
      'comment': comment,
    };
    if (bookingId != null) body['bookingId'] = bookingId;

    return _client.request<ReviewModel>(
      "POST",
      "/api/v1/reviews",
      auth: true,
      body: body,
      onSuccess: (data) =>
          ReviewModel.fromJson(Map<String, dynamic>.from(data)),
    );
  }
}
