/// Represents a staff member within a salon.
/// Staff are also users (with role 'salon_staff') but have
/// additional salon-specific fields like assigned services and schedule.
class StaffModel {
  final String id;
  final String name;
  final String email;
  final String? number;
  final String salonId;
  final List<String> assignedServices;
  final Map<String, DaySchedule> schedule;
  final String status; // active, disabled
  final String? createdAt;
  final String? createdBy;

  StaffModel({
    required this.id,
    required this.name,
    required this.email,
    this.number,
    required this.salonId,
    this.assignedServices = const [],
    this.schedule = const {},
    this.status = 'active',
    this.createdAt,
    this.createdBy,
  });

  bool get isActive => status == 'active';
  bool get isDisabled => status == 'disabled';

  StaffModel copyWith({
    String? id,
    String? name,
    String? email,
    String? number,
    String? salonId,
    List<String>? assignedServices,
    Map<String, DaySchedule>? schedule,
    String? status,
    String? createdAt,
    String? createdBy,
  }) {
    return StaffModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      number: number ?? this.number,
      salonId: salonId ?? this.salonId,
      assignedServices: assignedServices ?? this.assignedServices,
      schedule: schedule ?? this.schedule,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'number': number,
      'salonId': salonId,
      'assignedServices': assignedServices,
      'schedule': schedule.map((k, v) => MapEntry(k, v.toJson())),
      'status': status,
      'createdAt': createdAt,
      'createdBy': createdBy,
    };
  }

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    final scheduleRaw = json['schedule'] as Map<String, dynamic>? ?? {};
    final schedule = scheduleRaw.map(
      (k, v) => MapEntry(k, DaySchedule.fromJson(Map<String, dynamic>.from(v))),
    );

    return StaffModel(
      id: (json['id'] ?? json['_id'] ?? json['uid'])?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      number: (json['phone'] ?? json['number'])?.toString(),
      salonId: (json['assignedSalons'] as List?)?.isNotEmpty == true
          ? (json['assignedSalons'] as List).first.toString()
          : (json['salon'] is Map ? json['salon']['_id']?.toString() : json['salon']?.toString()) ?? json['salonId'] ?? '',
      assignedServices: List<String>.from(json['assignedServices'] ?? []),
      schedule: schedule,
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'],
      createdBy: json['createdBy'],
    );
  }
}

/// Represents the working hours for a single day.
class DaySchedule {
  final String open;
  final String close;
  final bool isClosed;

  DaySchedule({
    this.open = '10:00',
    this.close = '18:00',
    this.isClosed = false,
  });

  Map<String, dynamic> toJson() => {
        'open': open,
        'close': close,
        'isClosed': isClosed,
      };

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      open: json['open'] ?? '10:00',
      close: json['close'] ?? '18:00',
      isClosed: json['isClosed'] as bool? ?? false,
    );
  }
}
