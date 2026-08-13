import 'package:flutter/material.dart';
import 'package:salonverse/models/booking_model.dart';
import 'package:salonverse/models/salon_model.dart';
import 'package:salonverse/services/app_service.dart';
import 'package:salonverse/services/api_result.dart';

class BookingProvider extends ChangeNotifier {
  final _service = AppService.instance;

  List<BookingModel> _bookings = [];
  List<BookingModel> get bookings => _bookings;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Active Booking Flow Selection Cache
  SalonModel? _selectedSalon;
  ServiceModel? _selectedService;
  StylistModel? _selectedStylist;
  DateTime? _selectedDate;
  String? _selectedTime;
  String _paymentMethod = "Cash"; // Cash, eSewa, Khalti, Card
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

  void selectService(ServiceModel service) {
    _selectedService = service;
    if (_selectedSalon != null && _selectedSalon!.stylists.isNotEmpty) {
      if (_selectedStylist == null || !_selectedSalon!.stylists.any((s) => s.id == _selectedStylist!.id)) {
        _selectedStylist = _selectedSalon!.stylists.first;
      }
    }
    notifyListeners();
  }

  void setHomeService(bool value, {String address = '', String contact = ''}) {
    _isHomeService = value;
    if (address.isNotEmpty) _homeAddress = address;
    if (contact.isNotEmpty) _contactNumber = contact;
    notifyListeners();
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
    _selectedStylist = salon.stylists.isNotEmpty ? salon.stylists.first : null;
    _selectedDate ??= DateTime.now();
    _selectedTime = null;
    _paymentMethod = "Cash";
    _isHomeService = false;
    _homeAddress = "";
    _contactNumber = "";
    notifyListeners();
  }

  void startBookingFlowForSalon(SalonModel salon) {
    _selectedSalon = salon;
    _selectedService = salon.services.isNotEmpty ? salon.services.first : null;
    _selectedStylist = salon.stylists.isNotEmpty ? salon.stylists.first : null;
    _selectedDate ??= DateTime.now();
    _selectedTime = null;
    _paymentMethod = "Cash";
    _isHomeService = false;
    _homeAddress = "";
    _contactNumber = "";
    notifyListeners();
  }

  void selectStylist(StylistModel stylist) {
    _selectedStylist = stylist;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void selectTime(String time) {
    _selectedTime = time;
    notifyListeners();
  }

  void selectPaymentMethod(String method) {
    _paymentMethod = method;
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

    final targetStylist = _selectedStylist ?? StylistModel(
      id: "salon_staff",
      name: "Salon Staff",
      imageUrl: "",
      specialty: _selectedService!.name,
      rating: 5.0,
    );

    _isLoading = true;
    _error = null;
    notifyListeners();

    final dateStr = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

    final result = await _service.createBooking(
      salon: _selectedSalon!,
      service: _selectedService!,
      stylist: targetStylist,
      date: dateStr,
      timeSlot: _selectedTime!,
      paymentMethod: _paymentMethod,
      isHomeService: _isHomeService,
      homeAddress: _homeAddress,
      contactNumber: _contactNumber,
      latitude: _homeLat,
      longitude: _homeLng,
    );

    _isLoading = false;
    if (result is Success<BookingModel>) {
      if (!_bookings.any((b) => b.id == result.data.id)) {
        _bookings.insert(0, result.data); // Add to local list
      }
      notifyListeners();
      return result.data;
    } else {
      _error = (result as Failure).message;
      notifyListeners();
      return null;
    }
  }

  Stream<BookingModel?> streamQueueStatus(String bookingId) {
    return _service.streamQueueStatus(bookingId);
  }
}
