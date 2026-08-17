import 'dart:async';
import 'package:flutter/material.dart';
import 'package:salonverse/features/booking/models/booking_model.dart';
import 'package:salonverse/features/booking/models/booking_slot_model.dart';
import 'package:salonverse/features/salons/models/salon_model.dart';
import 'package:salonverse/features/home/services/app_service.dart';
import 'package:salonverse/features/notifications/services/socket_service.dart';
import 'package:salonverse/core/network/api_result.dart';

class BookingProvider extends ChangeNotifier {
  final _service = AppService.instance;

  List<BookingModel> _bookings = [];
  List<BookingModel> get bookings => _bookings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingSlots = false;
  bool get isLoadingSlots => _isLoadingSlots;

  String? _error;
  String? get error => _error;

  SalonModel? _selectedSalon;
  ServiceModel? _selectedService;
  StylistModel? _selectedStylist;
  DateTime? _selectedDate;
  String? _selectedTime;
  String _paymentMethod = "Cash";
  bool _isHomeService = false;
  String _homeAddress = "";
  String _contactNumber = "";
  double? _homeLat;
  double? _homeLng;

  SalonModel? get selectedSalon => _selectedSalon;
  ServiceModel? get selectedService => _selectedService;
  StylistModel? get selectedStylist => _selectedStylist;
  DateTime? get selectedDate => _selectedDate;
  String? get selectedTime => _selectedTime;
  String get paymentMethod => _paymentMethod;
  bool get isHomeService => _isHomeService;
  String get homeAddress => _homeAddress;
  String get contactNumber => _contactNumber;
  double? get homeLat => _homeLat;
  double? get homeLng => _homeLng;

  AvailabilityResultModel? _availabilityResult;
  AvailabilityResultModel? get availabilityResult => _availabilityResult;

  List<BookingSlotModel> _availableSlots = [];
  List<BookingSlotModel> get availableSlots => _availableSlots;

  List<BookingSlotModel> _bookedSlots = [];
  List<BookingSlotModel> get bookedSlots => _bookedSlots;

  bool _isSalonClosed = false;
  String? _closureReason;

  List<String> get backendAvailableSlots =>
      _availableSlots.map((s) => s.timeSlot).toList();
  List<String> get backendBookedSlots =>
      _bookedSlots.map((s) => s.timeSlot).toList();

  bool get isSalonClosed => _isSalonClosed;
  String? get closureReason => _closureReason;

  void selectService(ServiceModel service) {
    _selectedService = service;
    notifyListeners();
    fetchDynamicSlots();
  }

  void setHomeService(bool value, {String address = '', String contact = ''}) {
    _isHomeService = value;
    if (address.isNotEmpty) _homeAddress = address;
    if (contact.isNotEmpty) _contactNumber = contact;
    notifyListeners();
    fetchDynamicSlots();
  }

  void setHomeAddress(String address) {
    _homeAddress = address;
    notifyListeners();
  }

  void setHomeCoordinates(double lat, double lng) {
    _homeLat = lat;
    _homeLng = lng;
    notifyListeners();
  }

  void setContactNumber(String contact) {
    _contactNumber = contact;
    notifyListeners();
  }

  void startBookingFlow(SalonModel salon, ServiceModel service) {
    _selectedSalon = salon;
    _selectedService = service;
    _selectedStylist = null; // Default: Any Specialist
    _selectedDate ??= DateTime.now();
    _selectedTime = null;
    _paymentMethod = "Cash";
    _isHomeService = false;
    _homeAddress = "";
    _contactNumber = "";
    _appliedPromoCode = null;
    _discountAmount = 0.0;
    _error = null;
    SocketService.instance.joinSalon(salon.id);
    notifyListeners();
    fetchDynamicSlots();
  }

  void startBookingFlowForSalon(SalonModel salon) {
    _selectedSalon = salon;
    _selectedService = salon.services.isNotEmpty ? salon.services.first : null;
    _selectedStylist = null; // Default: Any Specialist
    _selectedDate ??= DateTime.now();
    _selectedTime = null;
    _paymentMethod = "Cash";
    _isHomeService = false;
    _homeAddress = "";
    _contactNumber = "";
    _appliedPromoCode = null;
    _discountAmount = 0.0;
    _error = null;
    SocketService.instance.joinSalon(salon.id);
    notifyListeners();
    fetchDynamicSlots();
  }

  void selectStylist(StylistModel? stylist) {
    _selectedStylist = stylist;
    _selectedTime = null;
    notifyListeners();
    fetchDynamicSlots();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    _selectedTime = null;
    notifyListeners();
    fetchDynamicSlots();
  }

  void selectTime(String time) {
    _selectedTime = time;
    notifyListeners();
  }

  void selectPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  Future<void> fetchDynamicSlots() async {
    if (_selectedSalon == null) return;

    final date = _selectedDate ?? DateTime.now();
    final dateStr =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    _isLoadingSlots = true;
    _availableSlots = [];
    _bookedSlots = [];
    _availabilityResult = null;
    _error = null;
    notifyListeners();

    final result = await _service.booking.getAvailability(
      salonId: _selectedSalon!.id,
      date: dateStr,
      serviceId: _selectedService?.id,
      stylistId: _selectedStylist?.id,
      bookingType: _isHomeService ? 'home' : 'in_salon',
    );

    _isLoadingSlots = false;
    if (result is Success<Map<String, dynamic>>) {
      final model = AvailabilityResultModel.fromJson(result.data);
      _availabilityResult = model;
      _isSalonClosed = model.isClosed;
      _closureReason = model.closureReason;
      _availableSlots = model.availableSlots;
      _bookedSlots = model.bookedSlots;
      _error = null;
    } else if (result is Failure<Map<String, dynamic>>) {
      _isSalonClosed = false;
      _closureReason = null;
      _availableSlots = [];
      _bookedSlots = [];
      _error = (result as Failure).message;
    }
    notifyListeners();
  }

  Future<void> fetchBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.getBookings();

    _isLoading = false;
    if (result is Success<List<BookingModel>>) {
      _bookings = result.data;
    } else {
      _error = (result as Failure).message;
    }
    notifyListeners();
  }

  Future<BookingModel?> confirmBooking() async {
    if (_selectedSalon == null ||
        _selectedService == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      _error = "Please complete all booking selections.";
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final dateStr =
        "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

    final result = await _service.createBooking(
      salon: _selectedSalon!,
      service: _selectedService!,
      stylist: _selectedStylist,
      date: dateStr,
      timeSlot: _selectedTime!,
      paymentMethod: _paymentMethod,
      isHomeService: _isHomeService,
      homeAddress: _homeAddress,
      contactNumber: _contactNumber,
      latitude: _homeLat,
      longitude: _homeLng,
      promoCode: _appliedPromoCode,
    );

    _isLoading = false;
    if (result is Success<BookingModel>) {
      if (!_bookings.any((b) => b.id == result.data.id)) {
        _bookings.insert(0, result.data);
      }
      notifyListeners();
      return result.data;
    } else {
      _error = (result as Failure).message;
      notifyListeners();
      return null;
    }
  }

  String? _appliedPromoCode;
  double _discountAmount = 0.0;
  String? get appliedPromoCode => _appliedPromoCode;
  double get discountAmount => _discountAmount;

  StreamSubscription? _bookingCreatedSub;
  StreamSubscription? _bookingUpdatedSub;
  StreamSubscription? _availabilityUpdatedSub;

  BookingProvider() {
    _initSocketListeners();
  }

  void _initSocketListeners() {
    _bookingCreatedSub = SocketService.instance.onBookingCreated.listen((data) {
      final booking = BookingModel.fromJson(data['booking'] ?? data);
      if (!_bookings.any((b) => b.id == booking.id)) {
        _bookings.insert(0, booking);
        notifyListeners();
      }
    });

    _bookingUpdatedSub = SocketService.instance.onBookingUpdated.listen((data) {
      final booking = BookingModel.fromJson(data['booking'] ?? data);
      final idx = _bookings.indexWhere((b) => b.id == booking.id);
      if (idx != -1) {
        _bookings[idx] = booking;
        notifyListeners();
      }
    });

    _availabilityUpdatedSub = SocketService.instance.onAvailabilityUpdated.listen((data) {
      final salonId = data['salonId']?.toString();
      if (_selectedSalon != null && _selectedSalon!.id == salonId) {
        fetchDynamicSlots();
      }
    });
  }

  @override
  void dispose() {
    _bookingCreatedSub?.cancel();
    _bookingUpdatedSub?.cancel();
    _availabilityUpdatedSub?.cancel();
    super.dispose();
  }

  Future<bool> applyPromoCodeAsync(String code, double basePrice) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return false;

    if (_selectedSalon != null) {
      final res = await _service.validateOffer(
        code: cleanCode,
        salonId: _selectedSalon!.id,
        orderAmount: basePrice,
        category: _selectedService?.category,
      );

      if (res is Success<Map<String, dynamic>>) {
        final data = res.data;
        _appliedPromoCode = cleanCode;
        _discountAmount = (data['discountAmount'] as num?)?.toDouble() ?? 0.0;
        notifyListeners();
        return true;
      } else if (res is Failure) {
        _error = (res as Failure).message;
        notifyListeners();
        return false;
      }
    }
    return false;
  }

  bool applyPromoCode(String code, double basePrice) {
    applyPromoCodeAsync(code, basePrice);
    return true;
  }

  void removePromoCode() {
    _appliedPromoCode = null;
    _discountAmount = 0.0;
    notifyListeners();
  }

  List<String> getBookedSlotsFor(
    String salonId,
    DateTime date,
    String? stylistId,
  ) {
    final dateStr =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final activeStatuses = ['in_queue', 'serving', 'confirmed', 'pending'];

    final booked = <String>[];
    for (var b in _bookings) {
      if (b.salonId == salonId &&
          b.date == dateStr &&
          activeStatuses.contains(b.status.toLowerCase())) {
        if (stylistId == null ||
            stylistId.isEmpty ||
            b.stylistId == stylistId ||
            b.stylistId == 'any_stylist') {
          booked.add(b.timeSlot);
        }
      }
    }
    return booked;
  }

  Future<bool> rescheduleBooking(
    String bookingId,
    DateTime newDate,
    String newTimeSlot,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final dateStr =
        "${newDate.year}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}";
    final result = await _service.rescheduleBooking(
      bookingId: bookingId,
      date: dateStr,
      timeSlot: newTimeSlot,
    );

    _isLoading = false;
    if (result is Success<BookingModel>) {
      final idx = _bookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) {
        _bookings[idx] = result.data;
      }
      notifyListeners();
      return true;
    } else {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelBooking(String bookingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.cancelBooking(bookingId);

    _isLoading = false;
    if (result is Success<BookingModel>) {
      final idx = _bookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) {
        _bookings[idx] = result.data;
      }
      notifyListeners();
      return true;
    } else {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> recordPayment(
    String bookingId,
    String method,
    double amount,
    String transactionId,
  ) async {
    final res = await _service.recordPayment(
      bookingId: bookingId,
      method: method,
      amount: amount,
      transactionId: transactionId,
    );
    if (res is Success) {
      final idx = _bookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) {
        final b = _bookings[idx];
        _bookings[idx] = b.copyWith(
          paymentMethod: method,
          paymentStatus: 'Completed',
        );
      }
      notifyListeners();
      return true;
    }
    return false;
  }

  Stream<BookingModel?> streamQueueStatus(String bookingId) {
    return _service.streamQueueStatus(bookingId);
  }
}
