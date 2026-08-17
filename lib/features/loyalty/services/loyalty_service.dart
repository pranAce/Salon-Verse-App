import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/network/base_client.dart';
import 'package:salonverse/features/loyalty/models/loyalty_model.dart';

class LoyaltyService {
  final BaseClient _client = BaseClient.instance;

  Future<ApiResult<Map<String, dynamic>>> getProfile() async {
    return _client.request<Map<String, dynamic>>(
      "GET",
      "/api/v1/loyalty/profile",
      auth: true,
      onSuccess: (data) => Map<String, dynamic>.from(data),
    );
  }

  Future<ApiResult<List<LoyaltyRuleModel>>> getRules() async {
    return _client.request<List<LoyaltyRuleModel>>(
      "GET",
      "/api/v1/loyalty/rules",
      auth: true,
      onSuccess: (data) {
        final List list = data is List
            ? data
            : (data is Map && data['data'] is List
                ? data['data'] as List
                : (data is Map && data['items'] is List
                    ? data['items'] as List
                    : []));
        return list.map((e) => LoyaltyRuleModel.fromJson(Map<String, dynamic>.from(e))).toList();
      },
    );
  }

  Future<ApiResult<List<LoyaltyTierModel>>> getTiers() async {
    return _client.request<List<LoyaltyTierModel>>(
      "GET",
      "/api/v1/loyalty/tiers",
      auth: true,
      onSuccess: (data) {
        final List list = data is List
            ? data
            : (data is Map && data['data'] is List
                ? data['data'] as List
                : (data is Map && data['items'] is List
                    ? data['items'] as List
                    : []));
        return list.map((e) => LoyaltyTierModel.fromJson(Map<String, dynamic>.from(e))).toList();
      },
    );
  }

  Future<ApiResult<List<LoyaltyRewardModel>>> getRewards() async {
    return _client.request<List<LoyaltyRewardModel>>(
      "GET",
      "/api/v1/loyalty/rewards",
      auth: true,
      onSuccess: (data) {
        final List list = data is List
            ? data
            : (data is Map && data['data'] is List
                ? data['data'] as List
                : (data is Map && data['items'] is List
                    ? data['items'] as List
                    : []));
        return list.map((e) => LoyaltyRewardModel.fromJson(Map<String, dynamic>.from(e))).toList();
      },
    );
  }

  Future<ApiResult<List<RewardRedemptionModel>>> getMyVouchers() async {
    return _client.request<List<RewardRedemptionModel>>(
      "GET",
      "/api/v1/loyalty/my-vouchers",
      auth: true,
      onSuccess: (data) {
        final List list = data is List
            ? data
            : (data is Map && data['data'] is List
                ? data['data'] as List
                : (data is Map && data['items'] is List
                    ? data['items'] as List
                    : []));
        return list.map((e) => RewardRedemptionModel.fromJson(Map<String, dynamic>.from(e))).toList();
      },
    );
  }

  Future<ApiResult<RewardRedemptionModel>> claimReward(String rewardId) async {
    return _client.request<RewardRedemptionModel>(
      "POST",
      "/api/v1/loyalty/rewards/$rewardId/claim",
      auth: true,
      onSuccess: (data) => RewardRedemptionModel.fromJson(Map<String, dynamic>.from(data)),
    );
  }

  Future<ApiResult<List<LoyaltyTransactionModel>>> getActivity() async {
    return _client.request<List<LoyaltyTransactionModel>>(
      "GET",
      "/api/v1/loyalty/activity",
      auth: true,
      onSuccess: (data) {
        final List list = data is List
            ? data
            : (data is Map && data['data'] is List
                ? data['data'] as List
                : (data is Map && data['items'] is List
                    ? data['items'] as List
                    : []));
        return list.map((e) => LoyaltyTransactionModel.fromJson(Map<String, dynamic>.from(e))).toList();
      },
    );
  }

  Future<ApiResult<Map<String, dynamic>>> getReferralStatus() async {
    return _client.request<Map<String, dynamic>>(
      "GET",
      "/api/v1/loyalty/referral",
      auth: true,
      onSuccess: (data) => Map<String, dynamic>.from(data),
    );
  }

  Future<ApiResult<void>> applyReferralCode(String code) async {
    return _client.request<void>(
      "POST",
      "/api/v1/loyalty/referral/apply",
      auth: true,
      body: {'referralCode': code.trim().toUpperCase()},
      onSuccess: (_) {},
    );
  }


  Future<ApiResult<SmartRebookModel>> getSmartRebook() async {
    return _client.request<SmartRebookModel>(
      "GET",
      "/api/v1/loyalty/smart-rebook",
      auth: true,
      onSuccess: (data) => SmartRebookModel.fromJson(Map<String, dynamic>.from(data)),
    );
  }
}
