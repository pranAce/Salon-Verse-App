class BookingSlotModel {
  final String startTime;
  final String endTime;
  final String timeSlot;
  final int startMinutes;
  final int endMinutes;
  final String period;
  final bool available;
  final String? assignedStylistId;

  bool get isAvailable => available;

  BookingSlotModel({
    required this.startTime,
    required this.endTime,
    required this.timeSlot,
    required this.startMinutes,
    required this.endMinutes,
    required this.period,
    required this.available,
    this.assignedStylistId,
  });

  factory BookingSlotModel.fromJson(Map<String, dynamic> json) {
    return BookingSlotModel(
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      timeSlot:
          json['timeSlot']?.toString() ?? json['timeRange']?.toString() ?? '',
      startMinutes: (json['startMinutes'] as num?)?.toInt() ?? 0,
      endMinutes: (json['endMinutes'] as num?)?.toInt() ?? 0,
      period: json['period']?.toString() ?? 'morning',
      available: json['available'] == true,
      assignedStylistId: json['assignedStylistId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'startTime': startTime,
    'endTime': endTime,
    'timeSlot': timeSlot,
    'startMinutes': startMinutes,
    'endMinutes': endMinutes,
    'period': period,
    'available': available,
    'assignedStylistId': assignedStylistId,
  };
}

class AvailabilityResultModel {
  final String salonId;
  final String? serviceId;
  final String? stylistId;
  final String date;
  final String dayOfWeek;
  final String timezone;
  final bool isClosed;
  final String? closureReason;
  final int serviceDurationMinutes;
  final List<BookingSlotModel> availableSlots;
  final List<BookingSlotModel> bookedSlots;
  final List<BookingSlotModel> allSlots;
  final int totalAvailableCount;

  AvailabilityResultModel({
    required this.salonId,
    this.serviceId,
    this.stylistId,
    required this.date,
    required this.dayOfWeek,
    required this.timezone,
    required this.isClosed,
    this.closureReason,
    required this.serviceDurationMinutes,
    required this.availableSlots,
    required this.bookedSlots,
    required this.allSlots,
    required this.totalAvailableCount,
  });

  factory AvailabilityResultModel.fromJson(Map<String, dynamic> json) {
    final rawAvailable = (json['availableSlots'] as List? ?? []);
    final rawBooked = (json['bookedSlots'] as List? ?? []);
    final rawAll = (json['slots'] as List? ?? []);

    List<BookingSlotModel> parseSlotList(
      List list, {
      required bool forceAvailable,
    }) {
      return list.map((item) {
        if (item is Map<String, dynamic>) {
          return BookingSlotModel.fromJson(item);
        } else if (item is Map) {
          return BookingSlotModel.fromJson(Map<String, dynamic>.from(item));
        } else {
          final timeStr = item.toString();
          return BookingSlotModel(
            startTime: timeStr,
            endTime: '',
            timeSlot: timeStr,
            startMinutes: 0,
            endMinutes: 0,
            period: timeStr.contains('PM') ? 'afternoon' : 'morning',
            available: forceAvailable,
          );
        }
      }).toList();
    }

    final availableParsed = parseSlotList(rawAvailable, forceAvailable: true);
    final bookedParsed = parseSlotList(rawBooked, forceAvailable: false);
    final allParsed = rawAll.isNotEmpty
        ? parseSlotList(rawAll, forceAvailable: true)
        : [...availableParsed, ...bookedParsed];

    return AvailabilityResultModel(
      salonId: json['salonId']?.toString() ?? '',
      serviceId: json['serviceId']?.toString(),
      stylistId: json['stylistId']?.toString(),
      date: json['date']?.toString() ?? '',
      dayOfWeek: json['dayOfWeek']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? 'Asia/Kathmandu',
      isClosed: json['isClosed'] == true,
      closureReason: json['closureReason']?.toString(),
      serviceDurationMinutes:
          (json['serviceDurationMinutes'] as num?)?.toInt() ?? 30,
      availableSlots: availableParsed,
      bookedSlots: bookedParsed,
      allSlots: allParsed,
      totalAvailableCount:
          (json['totalAvailableCount'] as num?)?.toInt() ??
          availableParsed.length,
    );
  }
}
