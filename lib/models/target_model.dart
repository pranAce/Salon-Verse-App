class StaffContributionModel {
  final String id;
  final String name;
  final double revenue;
  final int contributionPercent;

  StaffContributionModel({
    required this.id,
    required this.name,
    required this.revenue,
    required this.contributionPercent,
  });

  factory StaffContributionModel.fromJson(Map<String, dynamic> json) {
    return StaffContributionModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      name: json['name'] ?? 'Staff',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      contributionPercent: (json['contributionPercent'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'revenue': revenue,
      'contributionPercent': contributionPercent,
    };
  }
}

class TargetModel {
  final String id;
  final String salonId;
  final String title;
  final String targetType; // monthly, weekly, custom
  final String startDate;
  final String endDate;
  final double targetAmount;
  final double achievedRevenue;
  final double remainingRevenue;
  final int progressPercent;
  final int daysRemaining;
  final double requiredDailyRevenue;
  final String status; // on_track, at_risk, achieved, exceeded, archived
  final String notes;
  final List<StaffContributionModel> staffContributions;

  TargetModel({
    required this.id,
    required this.salonId,
    required this.title,
    this.targetType = 'monthly',
    required this.startDate,
    required this.endDate,
    required this.targetAmount,
    this.achievedRevenue = 0.0,
    this.remainingRevenue = 0.0,
    this.progressPercent = 0,
    this.daysRemaining = 0,
    this.requiredDailyRevenue = 0.0,
    this.status = 'on_track',
    this.notes = '',
    this.staffContributions = const [],
  });

  factory TargetModel.fromJson(Map<String, dynamic> json) {
    final sal = json['salon'];
    String sId = '';
    if (sal is Map) {
      sId = (sal['_id'] ?? sal['id'] ?? '').toString();
    } else if (sal != null) {
      sId = sal.toString();
    }

    final staffList = (json['staffContributions'] as List? ?? [])
        .map((e) => StaffContributionModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    return TargetModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      salonId: sId.isNotEmpty ? sId : (json['salonId']?.toString() ?? ''),
      title: json['title'] ?? 'Sales Target',
      targetType: json['targetType'] ?? 'monthly',
      startDate: json['startDate']?.toString().split('T')[0] ?? '',
      endDate: json['endDate']?.toString().split('T')[0] ?? '',
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 0.0,
      achievedRevenue: (json['achievedRevenue'] as num?)?.toDouble() ?? 0.0,
      remainingRevenue: (json['remainingRevenue'] as num?)?.toDouble() ?? 0.0,
      progressPercent: (json['progressPercent'] as num?)?.toInt() ?? 0,
      daysRemaining: (json['daysRemaining'] as num?)?.toInt() ?? 0,
      requiredDailyRevenue: (json['requiredDailyRevenue'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'on_track',
      notes: json['notes'] ?? '',
      staffContributions: staffList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salonId': salonId,
      'title': title,
      'targetType': targetType,
      'startDate': startDate,
      'endDate': endDate,
      'targetAmount': targetAmount,
      'achievedRevenue': achievedRevenue,
      'remainingRevenue': remainingRevenue,
      'progressPercent': progressPercent,
      'daysRemaining': daysRemaining,
      'requiredDailyRevenue': requiredDailyRevenue,
      'status': status,
      'notes': notes,
      'staffContributions': staffContributions.map((e) => e.toJson()).toList(),
    };
  }
}
