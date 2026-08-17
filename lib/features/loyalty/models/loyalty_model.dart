
class LoyaltyProfileModel {
  final String id;
  final String user;
  final String currentTier;
  final int loyaltyCredits;
  final int lifetimeCreditsEarned;
  final int lifetimeCreditsRedeemed;
  final String referralCode;
  final String? referredBy;
  final bool isSuspended;

  LoyaltyProfileModel({
    required this.id,
    required this.user,
    required this.currentTier,
    required this.loyaltyCredits,
    required this.lifetimeCreditsEarned,
    required this.lifetimeCreditsRedeemed,
    required this.referralCode,
    this.referredBy,
    required this.isSuspended,
  });

  factory LoyaltyProfileModel.fromJson(Map<String, dynamic> json) {
    final idStr = (json['_id'] ?? json['id'] ?? '').toString();
    final model = LoyaltyProfileModel(
      id: idStr,
      user: json['user'] is Map ? (json['user']['_id'] ?? '').toString() : (json['user'] ?? '').toString(),
      currentTier: (json['currentTier'] ?? 'glow').toString(),
      loyaltyCredits: (json['loyaltyCredits'] as num?)?.toInt() ?? 0,
      lifetimeCreditsEarned: (json['lifetimeCreditsEarned'] as num?)?.toInt() ?? 0,
      lifetimeCreditsRedeemed: (json['lifetimeCreditsRedeemed'] as num?)?.toInt() ?? 0,
      referralCode: (json['referralCode'] ?? '').toString(),
      referredBy: json['referredBy']?.toString(),
      isSuspended: json['isSuspended'] == true,
    );
    return model;
  }
}

class LoyaltyRuleModel {
  final String id;
  final String ruleKey;
  final String name;
  final String description;
  final int creditsToAward;
  final bool isActive;

  LoyaltyRuleModel({
    required this.id,
    required this.ruleKey,
    required this.name,
    required this.description,
    required this.creditsToAward,
    required this.isActive,
  });

  factory LoyaltyRuleModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyRuleModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      ruleKey: (json['ruleKey'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      creditsToAward: (json['creditsToAward'] as num?)?.toInt() ?? 1,
      isActive: json['isActive'] == true,
    );
  }
}

class LoyaltyTierModel {
  final String id;
  final String tierKey;
  final String name;
  final String icon;
  final String description;
  final int minCredits;
  final int? maxCredits;
  final double earningMultiplier;
  final List<String> benefits;
  final int birthdayRewardValue;

  LoyaltyTierModel({
    required this.id,
    required this.tierKey,
    required this.name,
    required this.icon,
    required this.description,
    required this.minCredits,
    this.maxCredits,
    required this.earningMultiplier,
    required this.benefits,
    required this.birthdayRewardValue,
  });

  factory LoyaltyTierModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyTierModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      tierKey: (json['tierKey'] ?? 'glow').toString(),
      name: (json['name'] ?? 'GLOW').toString(),
      icon: (json['icon'] ?? 'auto_awesome').toString(),
      description: (json['description'] ?? '').toString(),
      minCredits: (json['minCredits'] as num?)?.toInt() ?? 0,
      maxCredits: (json['maxCredits'] as num?)?.toInt(),
      earningMultiplier: (json['earningMultiplier'] as num?)?.toDouble() ?? 1.0,
      benefits: (json['benefits'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      birthdayRewardValue: (json['birthdayRewardValue'] as num?)?.toInt() ?? 200,
    );
  }
}

class LoyaltyRewardModel {
  final String id;
  final String title;
  final String description;
  final String rewardType;
  final String requiredTier;
  final int creditsRequired;
  final double discountValue;
  final double minOrderAmount;

  LoyaltyRewardModel({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardType,
    required this.requiredTier,
    required this.creditsRequired,
    required this.discountValue,
    required this.minOrderAmount,
  });

  factory LoyaltyRewardModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyRewardModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      rewardType: (json['rewardType'] ?? 'discount_fixed').toString(),
      requiredTier: (json['requiredTier'] ?? 'all').toString(),
      creditsRequired: (json['creditsRequired'] as num?)?.toInt() ?? 0,
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RewardRedemptionModel {
  final String id;
  final String claimCode;
  final String status;
  final int creditsSpent;
  final String claimedAt;
  final String validUntil;
  final LoyaltyRewardModel? reward;

  RewardRedemptionModel({
    required this.id,
    required this.claimCode,
    required this.status,
    required this.creditsSpent,
    required this.claimedAt,
    required this.validUntil,
    this.reward,
  });

  factory RewardRedemptionModel.fromJson(Map<String, dynamic> json) {
    return RewardRedemptionModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      claimCode: (json['claimCode'] ?? '').toString(),
      status: (json['status'] ?? 'claimed').toString(),
      creditsSpent: (json['creditsSpent'] as num?)?.toInt() ?? 0,
      claimedAt: (json['claimedAt'] ?? '').toString(),
      validUntil: (json['validUntil'] ?? '').toString(),
      reward: json['reward'] != null && json['reward'] is Map<String, dynamic>
          ? LoyaltyRewardModel.fromJson(Map<String, dynamic>.from(json['reward']))
          : null,
    );
  }
}

class LoyaltyTransactionModel {
  final String id;
  final int amount;
  final String type;
  final String source;
  final String description;
  final int balanceBefore;
  final int balanceAfter;
  final String createdAt;

  LoyaltyTransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.source,
    required this.description,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.createdAt,
  });

  factory LoyaltyTransactionModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyTransactionModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      type: (json['type'] ?? 'LOYALTY_EARNED').toString(),
      source: (json['source'] ?? 'booking').toString(),
      description: (json['description'] ?? '').toString(),
      balanceBefore: (json['balanceBefore'] as num?)?.toInt() ?? 0,
      balanceAfter: (json['balanceAfter'] as num?)?.toInt() ?? 0,
      createdAt: (json['createdAt'] ?? '').toString(),
    );
  }
}

class SmartRebookModel {
  final bool hasRecommendation;
  final String? salonId;
  final String? salonName;
  final String? salonAddress;
  final String? serviceId;
  final String? serviceName;
  final double? servicePrice;
  final String? stylistId;
  final String? stylistName;
  final String? message;

  SmartRebookModel({
    required this.hasRecommendation,
    this.salonId,
    this.salonName,
    this.salonAddress,
    this.serviceId,
    this.serviceName,
    this.servicePrice,
    this.stylistId,
    this.stylistName,
    this.message,
  });

  factory SmartRebookModel.fromJson(Map<String, dynamic> json) {
    final rec = json['recommendation'];
    if (json['hasRecommendation'] == true && rec != null && rec is Map<String, dynamic>) {
      return SmartRebookModel(
        hasRecommendation: true,
        salonId: rec['salonId']?.toString(),
        salonName: rec['salonName']?.toString(),
        salonAddress: rec['salonAddress']?.toString(),
        serviceId: rec['serviceId']?.toString(),
        serviceName: rec['serviceName']?.toString(),
        servicePrice: (rec['servicePrice'] as num?)?.toDouble(),
        stylistId: rec['stylistId']?.toString(),
        stylistName: rec['stylistName']?.toString(),
        message: rec['message']?.toString(),
      );
    }
    return SmartRebookModel(hasRecommendation: false);
  }
}
