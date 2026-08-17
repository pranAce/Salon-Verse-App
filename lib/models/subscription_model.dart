import 'package:salonverse/core/utils/app_logger.dart';

class SubscriptionModel {
  final String id;
  final String salonId;
  final String plan; // 'basic' | 'premium'
  final double price;
  final double commissionRate;
  final String status; // 'active' | 'pending' | 'past_due' | 'expired' | 'suspended' | 'cancelled'
  final String billingCycle;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool autoRenew;
  final String? nextPlan; // 'basic' | 'premium' | null
  final DateTime? nextPlanEffectiveDate;
  final Map<String, dynamic>? scheduledChange;
  final String? lastPaymentId;
  final int renewalCount;
  final String notes;

  const SubscriptionModel({
    required this.id,
    required this.salonId,
    required this.plan,
    required this.price,
    required this.commissionRate,
    required this.status,
    this.billingCycle = 'monthly',
    this.startDate,
    this.endDate,
    this.autoRenew = true,
    this.nextPlan,
    this.nextPlanEffectiveDate,
    this.scheduledChange,
    this.lastPaymentId,
    this.renewalCount = 0,
    this.notes = '',
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    String extractSalonId(dynamic salonVal) {
      if (salonVal == null) return '';
      if (salonVal is Map) {
        return salonVal['_id']?.toString() ?? salonVal['id']?.toString() ?? '';
      }
      return salonVal.toString();
    }

    DateTime? parseDate(dynamic dateVal) {
      if (dateVal == null) return null;
      if (dateVal is DateTime) return dateVal;
      return DateTime.tryParse(dateVal.toString());
    }

    final idStr = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final model = SubscriptionModel(
      id: idStr,
      salonId: extractSalonId(json['salon']),
      plan: (json['plan']?.toString() ?? 'basic').toLowerCase(),
      price: (json['price'] as num?)?.toDouble() ?? 300.0,
      commissionRate: (json['commissionRate'] as num?)?.toDouble() ?? 0.07,
      status: (json['status']?.toString() ?? 'pending').toLowerCase(),
      billingCycle: json['billingCycle']?.toString() ?? 'monthly',
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      autoRenew: json['autoRenew'] == true,
      nextPlan: json['nextPlan'] != null && json['nextPlan'].toString().isNotEmpty
          ? json['nextPlan'].toString().toLowerCase()
          : null,
      nextPlanEffectiveDate: parseDate(json['nextPlanEffectiveDate']),
      scheduledChange: json['scheduledChange'] is Map<String, dynamic>
          ? json['scheduledChange'] as Map<String, dynamic>
          : null,
      lastPaymentId: json['lastPaymentId']?.toString(),
      renewalCount: (json['renewalCount'] as num?)?.toInt() ?? 0,
      notes: json['notes']?.toString() ?? '',
    );
    AppLogger.logModelParse('SubscriptionModel', true, 'id: $idStr, plan: ${model.plan}');
    return model;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salon': salonId,
      'plan': plan,
      'price': price,
      'commissionRate': commissionRate,
      'status': status,
      'billingCycle': billingCycle,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'autoRenew': autoRenew,
      'nextPlan': nextPlan,
      'nextPlanEffectiveDate': nextPlanEffectiveDate?.toIso8601String(),
      'scheduledChange': scheduledChange,
      'lastPaymentId': lastPaymentId,
      'renewalCount': renewalCount,
      'notes': notes,
    };
  }

  bool get isActive => status.toLowerCase() == 'active';
  bool get hasScheduledChange => nextPlan != null && nextPlan!.isNotEmpty;
  
  String get formattedPlanName => plan.toUpperCase();
  String get formattedCommission => '${(commissionRate * 100).toStringAsFixed(0)}%';
}

class SubscriptionPaymentModel {
  final String id;
  final String subscriptionId;
  final String salonId;
  final String plan;
  final double amount;
  final String currency;
  final DateTime? billingPeriodStart;
  final DateTime? billingPeriodEnd;
  final String paymentMethod;
  final String paymentReference;
  final String status;
  final DateTime? submittedDate;
  final DateTime? verificationDate;
  final String notes;

  const SubscriptionPaymentModel({
    required this.id,
    required this.subscriptionId,
    required this.salonId,
    required this.plan,
    required this.amount,
    this.currency = 'NPR',
    this.billingPeriodStart,
    this.billingPeriodEnd,
    required this.paymentMethod,
    required this.paymentReference,
    required this.status,
    this.submittedDate,
    this.verificationDate,
    this.notes = '',
  });

  factory SubscriptionPaymentModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic d) => d != null ? DateTime.tryParse(d.toString()) : null;
    return SubscriptionPaymentModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      subscriptionId: json['subscription'] is Map
          ? json['subscription']['_id']?.toString() ?? ''
          : json['subscription']?.toString() ?? '',
      salonId: json['salon'] is Map
          ? json['salon']['_id']?.toString() ?? ''
          : json['salon']?.toString() ?? '',
      plan: json['plan']?.toString() ?? 'basic',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'NPR',
      billingPeriodStart: parseDate(json['billingPeriodStart']),
      billingPeriodEnd: parseDate(json['billingPeriodEnd']),
      paymentMethod: json['paymentMethod']?.toString() ?? 'cash',
      paymentReference: json['paymentReference']?.toString() ?? '',
      status: (json['status']?.toString() ?? 'pending').toLowerCase(),
      submittedDate: parseDate(json['submittedDate']),
      verificationDate: parseDate(json['verificationDate']),
      notes: json['notes']?.toString() ?? '',
    );
  }
}

class SubscriptionHistoryModel {
  final String id;
  final String subscriptionId;
  final String salonId;
  final String plan;
  final double price;
  final double commissionRate;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String changeType;
  final String notes;
  final DateTime? createdAt;

  const SubscriptionHistoryModel({
    required this.id,
    required this.subscriptionId,
    required this.salonId,
    required this.plan,
    required this.price,
    required this.commissionRate,
    required this.status,
    this.startDate,
    this.endDate,
    required this.changeType,
    this.notes = '',
    this.createdAt,
  });

  factory SubscriptionHistoryModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic d) => d != null ? DateTime.tryParse(d.toString()) : null;
    return SubscriptionHistoryModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      subscriptionId: json['subscription']?.toString() ?? '',
      salonId: json['salon']?.toString() ?? '',
      plan: json['plan']?.toString() ?? 'basic',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      commissionRate: (json['commissionRate'] as num?)?.toDouble() ?? 0.07,
      status: json['status']?.toString() ?? '',
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      changeType: json['changeType']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      createdAt: parseDate(json['createdAt']),
    );
  }
}
