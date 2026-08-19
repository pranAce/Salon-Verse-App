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
  final double totalAmount;
  final double bookingFeeAmount;
  final double amountPaid;
  final double remainingAmount;
  final String cancellationCutoff;
  final double refundAmount;
  final String refundStatus;
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

  double get finalAmount => totalAmount > 0 ? totalAmount : servicePrice;
  String get salonImage => salonImageUrl;

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
    double? totalAmount,
    double? bookingFeeAmount,
    double? amountPaid,
    double? remainingAmount,
    this.cancellationCutoff = '',
    this.refundAmount = 0.0,
    this.refundStatus = 'none',
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
  })  : totalAmount = totalAmount ?? servicePrice,
        bookingFeeAmount = bookingFeeAmount ??
            (paymentMethod.toLowerCase() == 'cash'
                ? (servicePrice * 0.10)
                : servicePrice),
        amountPaid = amountPaid ??
            (paymentMethod.toLowerCase() == 'cash'
                ? (servicePrice * 0.10)
                : servicePrice),
        remainingAmount = remainingAmount ??
            (paymentMethod.toLowerCase() == 'cash'
                ? (servicePrice * 0.90)
                : 0.0);

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
    double? totalAmount,
    double? bookingFeeAmount,
    double? amountPaid,
    double? remainingAmount,
    String? cancellationCutoff,
    double? refundAmount,
    String? refundStatus,
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
      totalAmount: totalAmount ?? this.totalAmount,
      bookingFeeAmount: bookingFeeAmount ?? this.bookingFeeAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      cancellationCutoff: cancellationCutoff ?? this.cancellationCutoff,
      refundAmount: refundAmount ?? this.refundAmount,
      refundStatus: refundStatus ?? this.refundStatus,
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
      'totalAmount': totalAmount,
      'bookingFeeAmount': bookingFeeAmount,
      'amountPaid': amountPaid,
      'remainingAmount': remainingAmount,
      'cancellationCutoff': cancellationCutoff,
      'refundAmount': refundAmount,
      'refundStatus': refundStatus,
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
    final sPrice = srv is Map && srv['price'] != null
        ? (srv['price'] as num).toDouble()
        : ((json['servicePrice'] as num?)?.toDouble() ?? 0.0);
    final totAmt = (json['totalAmount'] as num?)?.toDouble() ?? sPrice;
    final pMethod = json['paymentMethod']?.toString() ?? 'cash';
    final isCash = pMethod.toLowerCase() == 'cash';
    final bFee = (json['bookingFeeAmount'] as num?)?.toDouble() ?? (isCash ? (totAmt * 0.10) : totAmt);
    final amtPaid = (json['amountPaid'] as num?)?.toDouble() ?? bFee;
    final remAmt = (json['remainingAmount'] as num?)?.toDouble() ?? (isCash ? (totAmt - amtPaid) : 0.0);

    return BookingModel(
      id: bookingId,
      userId: extractId(cust, 'userId'),
      userName: extractName(cust, 'userName'),
      salonId: extractId(sal, 'salonId'),
      salonName: extractName(sal, 'salonName'),
      salonAddress: sal is Map && sal['address'] != null
          ? sal['address'].toString()
          : (json['salonAddress'] ?? ''),
      salonImageUrl: sal is Map && (sal['coverImage'] != null || sal['logo'] != null)
          ? (sal['coverImage'] ?? sal['logo'] ?? '').toString().trim()
          : (json['salonImageUrl'] ?? '').toString().trim(),
      serviceId: extractId(srv, 'serviceId'),
      serviceName: extractName(srv, 'serviceName'),
      servicePrice: sPrice,
      totalAmount: totAmt,
      bookingFeeAmount: bFee,
      amountPaid: amtPaid,
      remainingAmount: remAmt,
      cancellationCutoff: json['cancellationCutoff']?.toString() ?? '',
      refundAmount: (json['refundAmount'] as num?)?.toDouble() ?? 0.0,
      refundStatus: json['refundStatus']?.toString() ?? 'none',
      stylistId: extractId(sty, 'stylistId'),
      stylistName: extractName(sty, 'stylistName'),
      date: json['date'] != null ? json['date'].toString().split('T')[0] : '',
      timeSlot: json['timeSlot'] ??
          (json['startTime'] != null
              ? '${json['startTime']} - ${json['endTime']}'
              : ''),
      paymentMethod: pMethod,
      paymentStatus: json['paymentStatus'] ?? 'Pending',
      status: json['status'] ?? 'in_queue',
      queuePosition: (json['queuePosition'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt']?.toString() ?? '',
      reviewed: json['reviewed'] as bool? ?? false,
      isHomeService: json['isHomeService'] as bool? ?? (json['bookingType'] == 'home'),
      homeAddress: json['homeAddress'] ?? '',
      contactNumber: (json['contactNumber'] ?? json['contactPhone'])?.toString() ?? '',
    );
  }
}
