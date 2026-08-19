import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/network/base_client.dart';
import 'package:salonverse/features/booking/models/booking_model.dart';
import 'package:salonverse/features/salons/models/salon_model.dart';
import 'package:salonverse/features/auth/models/user_model.dart';

class BookingService {
  final BaseClient _client = BaseClient.instance;

  bool get isMockMode => false;

  Future<ApiResult<Map<String, dynamic>>> getAvailability({
    required String salonId,
    required String date,
    String? serviceId,
    String? stylistId,
    String bookingType = 'in_salon',
  }) async {
    final queryParams = <String, String>{
      'salonId': salonId,
      'date': date,
      'bookingType': bookingType,
    };
    if (serviceId != null && serviceId.isNotEmpty) {
      queryParams['serviceId'] = serviceId;
    }
    if (stylistId != null &&
        stylistId.isNotEmpty &&
        stylistId != 'salon_staff') {
      queryParams['stylistId'] = stylistId;
    }

    final queryString = Uri(queryParameters: queryParams).query;
    return _client.request<Map<String, dynamic>>(
      "GET",
      "/api/v1/bookings/availability?$queryString",
      auth: false,
      onSuccess: (data) => Map<String, dynamic>.from(data),
    );
  }

  Future<ApiResult<List<StylistModel>>> getStylistsBySalon(String salonId, {String? serviceId}) async {
    final queryParams = <String, String>{};
    if (serviceId != null && serviceId.isNotEmpty) {
      queryParams['serviceId'] = serviceId;
    }
    final queryString = queryParams.isNotEmpty ? "?${Uri(queryParameters: queryParams).query}" : "";
    return _client.request<List<StylistModel>>(
      "GET",
      "/api/v1/stylists/salon/$salonId$queryString",
      auth: false,
      onSuccess: (data) {
        final list = data is List ? data : (data is Map && data['data'] is List) ? data['data'] : [];
        return (list as List)
            .map((e) => StylistModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
  }

  Future<ApiResult<BookingModel>> createBooking({
    required UserModel? currentUser,
    required SalonModel salon,
    required ServiceModel service,
    StylistModel? stylist,
    required String date,
    required String timeSlot,
    required String paymentMethod,
    bool isHomeService = false,
    String homeAddress = '',
    String contactNumber = '',
    double? latitude,
    double? longitude,
    String? promoCode,
  }) async {
    if (currentUser == null) return const Failure("Session required.");

    final bodyMap = <String, dynamic>{
      'salonId': salon.id,
      'salonName': salon.name,
      'salonAddress': salon.address,
      'salonImageUrl': salon.imageUrl,
      'serviceId': service.id,
      'serviceName': service.name,
      'servicePrice': service.price,
      'date': date,
      'timeSlot': timeSlot,
      'paymentMethod': paymentMethod,
      'isHomeService': isHomeService,
      'homeAddress': homeAddress,
      'contactNumber': contactNumber,
    };

    if (promoCode != null && promoCode.isNotEmpty) {
      bodyMap['promoCode'] = promoCode;
    }

    if (stylist != null &&
        stylist.id.isNotEmpty &&
        stylist.id != 'salon_staff') {
      bodyMap['stylistId'] = stylist.id;
      bodyMap['stylistName'] = stylist.name;
    }

    if (latitude != null && longitude != null) {
      bodyMap['homeLocation'] = {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      };
    }

    return _client.request<BookingModel>(
      "POST",
      "/api/v1/bookings",
      auth: true,
      body: bodyMap,
      onSuccess: (data) =>
          BookingModel.fromJson(Map<String, dynamic>.from(data)),
    );
  }

  Future<ApiResult<List<BookingModel>>> getBookings(
    UserModel? currentUser,
  ) async {
    if (currentUser == null) return const Failure("Session required.");

    return _client.request<List<BookingModel>>(
      "GET",
      "/api/v1/bookings",
      auth: true,
      onSuccess: (data) {
        final List list = data is List
            ? data
            : (data is Map && data['data'] is List
                ? data['data'] as List
                : (data is Map && data['items'] is List
                    ? data['items'] as List
                    : []));
        return list
            .map((e) => BookingModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
  }

  Stream<BookingModel?> streamQueueStatus(String bookingId) async* {
    while (true) {
      try {
        final result = await _client.request<BookingModel?>(
          "GET",
          "/api/v1/bookings/$bookingId/queue",
          auth: true,
          onSuccess: (data) => data != null
              ? BookingModel.fromJson(Map<String, dynamic>.from(data))
              : null,
        );

        if (result is Success<BookingModel?> && result.data != null) {
          yield result.data;
        }
      } catch (_) {}
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Future<ApiResult<List<BookingModel>>> getCompletedBookingsForSalon(
    String salonId,
  ) async {
    return _client.request<List<BookingModel>>(
      "GET",
      "/api/v1/bookings/salon/$salonId/completed",
      auth: true,
      onSuccess: (data) {
        final List list = data is List ? data : [];
        return list
            .map((e) => BookingModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
  }

  Future<ApiResult<BookingModel>> rescheduleBooking({
    required String bookingId,
    required String date,
    required String timeSlot,
  }) async {
    return _client.request<BookingModel>(
      "PATCH",
      "/api/v1/bookings/$bookingId/status",
      auth: true,
      body: {'date': date, 'timeSlot': timeSlot, 'status': 'confirmed'},
      onSuccess: (data) =>
          BookingModel.fromJson(Map<String, dynamic>.from(data)),
    );
  }

  Future<ApiResult<Map<String, dynamic>>> getCancellationQuote(String bookingId) async {
    return _client.request<Map<String, dynamic>>(
      "GET",
      "/api/v1/bookings/$bookingId/cancellation-quote",
      auth: true,
      onSuccess: (data) => Map<String, dynamic>.from(data),
    );
  }

  Future<ApiResult<BookingModel>> cancelBooking(String bookingId, {String? cancelReason}) async {
    return _client.request<BookingModel>(
      "POST",
      "/api/v1/bookings/$bookingId/cancel",
      auth: true,
      body: {'cancelReason': cancelReason ?? ''},
      onSuccess: (data) =>
          BookingModel.fromJson(Map<String, dynamic>.from(data)),
    );
  }

  Future<ApiResult<void>> recordPayment({
    required String bookingId,
    required String method,
    required double amount,
    required String transactionId,
  }) async {
    return _client.request<void>(
      "POST",
      "/api/v1/payments",
      auth: true,
      body: {
        'bookingId': bookingId,
        'method': method.toLowerCase(),
        'amount': amount,
        'transactionId': transactionId,
      },
      onSuccess: (_) {},
    );
  }
}
