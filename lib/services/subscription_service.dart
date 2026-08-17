import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/network/base_client.dart';
import 'package:salonverse/models/subscription_model.dart';

class SubscriptionDataPayload {
  final SubscriptionModel subscription;
  final List<SubscriptionPaymentModel> payments;
  final List<SubscriptionHistoryModel> history;
  final Map<String, dynamic> planConfig;
  final List<String> allowedFeatures;
  final List<String> restrictedFeatures;

  SubscriptionDataPayload({
    required this.subscription,
    required this.payments,
    required this.history,
    required this.planConfig,
    required this.allowedFeatures,
    required this.restrictedFeatures,
  });
}

class SubscriptionService {
  final BaseClient _client = BaseClient.instance;

  Future<ApiResult<Map<String, dynamic>>> getSubscriptionPlansCatalog() async {
    return await _client.request<Map<String, dynamic>>(
      "GET",
      "/api/v1/subscriptions/plans",
      auth: false,
      onSuccess: (data) => data is Map<String, dynamic> ? data : {},
    );
  }

  Future<ApiResult<SubscriptionDataPayload>> getCurrentSubscription([String? salonId]) async {
    final path = salonId != null && salonId.isNotEmpty
        ? "/api/v1/subscriptions/current/$salonId"
        : "/api/v1/subscriptions/current";

    return await _client.request<SubscriptionDataPayload>(
      "GET",
      path,
      auth: true,
      onSuccess: (data) {
        final map = data is Map<String, dynamic> ? data : {};
        final subMap = map['subscription'] is Map<String, dynamic> ? map['subscription'] : <String, dynamic>{};
        final paymentsList = map['payments'] is List ? map['payments'] as List : [];
        final historyList = map['history'] is List ? map['history'] as List : [];
        final planConfigMap = map['planConfig'] is Map<String, dynamic> ? map['planConfig'] : <String, dynamic>{};
        final allowedList = map['allowedFeatures'] is List ? (map['allowedFeatures'] as List).cast<String>() : <String>[];
        final restrictedList = map['restrictedFeatures'] is List ? (map['restrictedFeatures'] as List).cast<String>() : <String>[];

        return SubscriptionDataPayload(
          subscription: SubscriptionModel.fromJson(Map<String, dynamic>.from(subMap)),
          payments: paymentsList.map((p) => SubscriptionPaymentModel.fromJson(Map<String, dynamic>.from(p))).toList(),
          history: historyList.map((h) => SubscriptionHistoryModel.fromJson(Map<String, dynamic>.from(h))).toList(),
          planConfig: Map<String, dynamic>.from(planConfigMap),
          allowedFeatures: allowedList,
          restrictedFeatures: restrictedList,
        );
      },
    );
  }

  Future<ApiResult<List<SubscriptionHistoryModel>>> getSubscriptionHistory([String? salonId]) async {
    final path = salonId != null && salonId.isNotEmpty
        ? "/api/v1/subscriptions/history/$salonId"
        : "/api/v1/subscriptions/history";

    return await _client.request<List<SubscriptionHistoryModel>>(
      "GET",
      path,
      auth: true,
      onSuccess: (data) {
        final list = data is List ? data : [];
        return list.map((h) => SubscriptionHistoryModel.fromJson(Map<String, dynamic>.from(h))).toList();
      },
    );
  }

  Future<ApiResult<Map<String, dynamic>>> submitManualPayment({
    required String salonId,
    required String plan,
    required String paymentMethod,
    String? paymentReference,
    String? notes,
    String timing = "next_cycle",
  }) async {
    return await _client.request<Map<String, dynamic>>(
      "POST",
      "/api/v1/subscriptions/manual-payment",
      auth: true,
      body: {
        "salonId": salonId,
        "plan": plan.toLowerCase(),
        "paymentMethod": paymentMethod.toLowerCase(),
        if (paymentReference != null && paymentReference.isNotEmpty) "paymentReference": paymentReference,
        if (notes != null && notes.isNotEmpty) "notes": notes,
        "timing": timing,
      },
      onSuccess: (data) => data is Map<String, dynamic> ? data : {},
    );
  }

  Future<ApiResult<Map<String, dynamic>>> processOnlinePayment({
    required String salonId,
    required String plan,
    required String paymentMethod,
    required String paymentReference,
    String? idempotencyKey,
    String timing = "next_cycle",
  }) async {
    return await _client.request<Map<String, dynamic>>(
      "POST",
      "/api/v1/subscriptions/online-payment",
      auth: true,
      body: {
        "salonId": salonId,
        "plan": plan.toLowerCase(),
        "paymentMethod": paymentMethod.toLowerCase(),
        "paymentReference": paymentReference,
        if (idempotencyKey != null && idempotencyKey.isNotEmpty) "idempotencyKey": idempotencyKey,
        "timing": timing,
      },
      onSuccess: (data) => data is Map<String, dynamic> ? data : {},
    );
  }

  Future<ApiResult<SubscriptionModel>> cancelScheduledChange([String? salonId]) async {
    return await _client.request<SubscriptionModel>(
      "POST",
      "/api/v1/subscriptions/cancel-scheduled",
      auth: true,
      body: {
        if (salonId != null && salonId.isNotEmpty) "salonId": salonId,
      },
      onSuccess: (data) {
        final subMap = data is Map<String, dynamic> ? data : <String, dynamic>{};
        return SubscriptionModel.fromJson(Map<String, dynamic>.from(subMap));
      },
    );
  }
}
