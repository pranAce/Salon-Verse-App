import 'package:salonverse/core/utils/app_logger.dart';

class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String salonId;
  final String salonName;
  final String salonAddress;
  final String salonImageUrl;
  final String serviceId;
  final String serviceName;
  final double servicePrice;
  final String stylistId;
  final String stylistName;
  final String date;
  final String timeSlot;
  final String paymentMethod;
  final String paymentStatus;
  final String status;
  final int queuePosition;
  final String createdAt;
  final bool reviewed;
  final bool isHomeService;
  final String homeAddress;
  final String contactNumber;

  BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.salonId,
    required this.salonName,
    required this.salonAddress,
    required this.salonImageUrl,
    required this.serviceId,
    required this.serviceName,
    required this.servicePrice,
    required this.stylistId,
    required this.stylistName,
    required this.date,
    required this.timeSlot,
    required this.paymentMethod,
    this.paymentStatus = 'Pending',
    this.status = 'in_queue',
    this.queuePosition = 0,
    required this.createdAt,
    this.reviewed = false,
    this.isHomeService = false,
    this.homeAddress = '',
    this.contactNumber = '',
  });

  BookingModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? salonId,
    String? salonName,
    String? salonAddress,
    String? salonImageUrl,
    String? serviceId,
    String? serviceName,
    double? servicePrice,
    String? stylistId,
    String? stylistName,
    String? date,
    String? timeSlot,
    String? paymentMethod,
    String? paymentStatus,
    String? status,
    int? queuePosition,
    String? createdAt,
    bool? reviewed,
    bool? isHomeService,
    String? homeAddress,
    String? contactNumber,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      salonId: salonId ?? this.salonId,
      salonName: salonName ?? this.salonName,
      salonAddress: salonAddress ?? this.salonAddress,
      salonImageUrl: salonImageUrl ?? this.salonImageUrl,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      servicePrice: servicePrice ?? this.servicePrice,
      stylistId: stylistId ?? this.stylistId,
      stylistName: stylistName ?? this.stylistName,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      queuePosition: queuePosition ?? this.queuePosition,
      createdAt: createdAt ?? this.createdAt,
      reviewed: reviewed ?? this.reviewed,
      isHomeService: isHomeService ?? this.isHomeService,
      homeAddress: homeAddress ?? this.homeAddress,
      contactNumber: contactNumber ?? this.contactNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'salonId': salonId,
      'salonName': salonName,
      'salonAddress': salonAddress,
      'salonImageUrl': salonImageUrl,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'servicePrice': servicePrice,
      'stylistId': stylistId,
      'stylistName': stylistName,
      'date': date,
      'timeSlot': timeSlot,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'status': status,
      'queuePosition': queuePosition,
      'createdAt': createdAt,
      'reviewed': reviewed,
      'isHomeService': isHomeService,
      'homeAddress': homeAddress,
      'contactNumber': contactNumber,
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    String extractId(dynamic field, [String fallbackKey = '']) {
      if (field is Map) {
        return (field['_id'] ?? field['id'] ?? '').toString();
      }
      if (field != null) return field.toString();
      return json[fallbackKey]?.toString() ?? '';
    }

    String extractName(
      dynamic field,
      String fallbackKey, [
      String nestedNameKey = 'name',
    ]) {
      if (field is Map && field[nestedNameKey] != null) {
        return field[nestedNameKey].toString();
      }
      return json[fallbackKey]?.toString() ?? '';
    }

    final cust = json['customer'] ?? json['user'];
    final sal = json['salon'];
    final srv = json['service'];
    final sty = json['stylist'];

    final bookingId = (json['id'] ?? json['_id'])?.toString() ?? '';
    final model = BookingModel(
      id: bookingId,
      userId: extractId(cust, 'userId'),
      userName: extractName(cust, 'userName'),
      salonId: extractId(sal, 'salonId'),
      salonName: extractName(sal, 'salonName'),
      salonAddress: sal is Map && sal['address'] != null
          ? sal['address'].toString()
          : (json['salonAddress'] ?? ''),
      salonImageUrl:
          sal is Map && (sal['coverImage'] != null || sal['logo'] != null)
          ? (sal['coverImage'] ?? sal['logo'] ?? '').toString()
          : (json['salonImageUrl'] ?? ''),
      serviceId: extractId(srv, 'serviceId'),
      serviceName: extractName(srv, 'serviceName'),
      servicePrice: srv is Map && srv['price'] != null
          ? (srv['price'] as num).toDouble()
          : ((json['servicePrice'] as num?)?.toDouble() ?? 0.0),
      stylistId: extractId(sty, 'stylistId'),
      stylistName: extractName(sty, 'stylistName'),
      date: json['date'] != null ? json['date'].toString().split('T')[0] : '',
      timeSlot:
          json['timeSlot'] ??
          (json['startTime'] != null
              ? '${json['startTime']} - ${json['endTime']}'
              : ''),
      paymentMethod: json['paymentMethod'] ?? 'Cash',
      paymentStatus: json['paymentStatus'] ?? 'Pending',
      status: json['status'] ?? 'in_queue',
      queuePosition: (json['queuePosition'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
      reviewed: json['reviewed'] as bool? ?? false,
      isHomeService:
          json['isHomeService'] as bool? ?? (json['bookingType'] == 'home'),
      homeAddress: json['homeAddress'] ?? '',
      contactNumber:
          (json['contactNumber'] ?? json['contactPhone'])?.toString() ?? '',
    );
    AppLogger.logModelParse('BookingModel', true, 'id: $bookingId, status: ${model.status}');
    return model;
  }
}
