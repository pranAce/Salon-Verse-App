import 'package:salonverse/features/auth/models/user_model.dart';
import 'package:salonverse/features/salons/models/salon_model.dart';
import 'package:salonverse/features/booking/models/booking_model.dart';
import 'package:salonverse/features/support/models/support_ticket_model.dart';
import 'package:salonverse/features/salons/models/review_model.dart';
import 'package:salonverse/features/notifications/models/notification_model.dart';
import 'package:salonverse/features/salons/models/nearby_service_model.dart';
import 'package:salonverse/core/network/api_result.dart';

import 'package:salonverse/features/auth/services/auth_service.dart';
import 'package:salonverse/features/salons/services/salon_service.dart';
import 'package:salonverse/features/booking/services/booking_service.dart';
import 'package:salonverse/features/support/services/support_service.dart';
import 'package:salonverse/features/salons/services/review_service.dart';
import 'package:salonverse/features/notifications/services/notification_service.dart';
import 'package:salonverse/features/loyalty/services/offer_service.dart';
import 'package:salonverse/features/notifications/services/socket_service.dart';
import 'package:salonverse/features/loyalty/models/offer_model.dart';

class AppService {
  static final AppService _instance = AppService._();
  static AppService get instance => _instance;
  AppService._();

  final auth = AuthService();
  final salon = SalonService();
  final booking = BookingService();
  final support = SupportService();
  final review = ReviewService();
  final notification = NotificationService();
  final offer = OfferService();
  final socket = SocketService.instance;

  UserModel? get currentUser => auth.currentUser;
  bool get isMockMode => auth.isMockMode;

  Future<ApiResult<UserModel>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? referralCode,
    String? dateOfBirth,
  }) {
    return auth.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      referralCode: referralCode,
      dateOfBirth: dateOfBirth,
    );
  }

  Future<ApiResult<UserModel>> login({
    required String email,
    required String password,
  }) {
    return auth.login(email: email, password: password);
  }

  Future<bool> tryAutoLogin() {
    return auth.tryAutoLogin();
  }

  Future<void> logout() {
    return auth.logout();
  }

  Future<ApiResult<void>> resetPassword(String email) {
    return auth.resetPassword(email);
  }

  Future<ApiResult<UserModel>> updateProfile({
    String? name,
    String? phone,
    String? dateOfBirth,
    Map<String, dynamic>? homeLocation,
  }) {
    return auth.updateProfile(
      name: name,
      phone: phone,
      dateOfBirth: dateOfBirth,
      homeLocation: homeLocation,
    );
  }

  Future<ApiResult<List<SalonModel>>> getSalons({
    String? query,
    String? category,
    double? lat,
    double? lng,
    double? radius,
    bool forceRefresh = false,
  }) {
    return salon.getSalons(
      query: query,
      category: category,
      lat: lat,
      lng: lng,
      radius: radius,
      forceRefresh: forceRefresh,
    );
  }

  Future<ApiResult<List<NearbyServiceModel>>> getNearbyServices({
    String? search,
    String? category,
    double? lat,
    double? lng,
    double? radius,
    String? sort,
  }) {
    return salon.getNearbyServices(
      search: search,
      category: category,
      lat: lat,
      lng: lng,
      radius: radius,
      sort: sort,
    );
  }

  Future<ApiResult<void>> toggleFavorite(String salonId) {
    return salon.toggleFavorite(salonId, auth.currentUser, (updatedUser) {
      auth.syncCurrentUser(updatedUser);
    });
  }

  Future<ApiResult<Map<String, dynamic>>> getAvailability({
    required String salonId,
    required String date,
    String? serviceId,
    String? stylistId,
    String bookingType = 'in_salon',
  }) {
    return booking.getAvailability(
      salonId: salonId,
      date: date,
      serviceId: serviceId,
      stylistId: stylistId,
      bookingType: bookingType,
    );
  }

  Future<ApiResult<List<OfferModel>>> getOffers() {
    return offer.getOffers();
  }

  Future<ApiResult<Map<String, dynamic>>> validateOffer({
    required String code,
    required String salonId,
    required double orderAmount,
    String? category,
  }) {
    return offer.validateOffer(
      code: code,
      salonId: salonId,
      orderAmount: orderAmount,
      category: category,
    );
  }

  Future<ApiResult<BookingModel>> createBooking({
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
  }) {
    return booking.createBooking(
      currentUser: auth.currentUser,
      salon: salon,
      service: service,
      stylist: stylist,
      date: date,
      timeSlot: timeSlot,
      paymentMethod: paymentMethod,
      isHomeService: isHomeService,
      homeAddress: homeAddress,
      contactNumber: contactNumber,
      latitude: latitude,
      longitude: longitude,
      promoCode: promoCode,
    );
  }

  Future<ApiResult<List<BookingModel>>> getBookings() {
    return booking.getBookings(auth.currentUser);
  }

  Future<ApiResult<List<BookingModel>>> getCompletedBookingsForSalon(
    String salonId,
  ) {
    return booking.getCompletedBookingsForSalon(salonId);
  }

  Stream<BookingModel?> streamQueueStatus(String bookingId) {
    return booking.streamQueueStatus(bookingId);
  }

  Future<ApiResult<SupportTicketModel>> createSupportTicket(
    String subject,
    String message,
  ) {
    return support.createSupportTicket(auth.currentUser, subject, message);
  }

  Future<ApiResult<List<SupportTicketModel>>> getSupportTickets() {
    return support.getSupportTickets(auth.currentUser);
  }

  Future<ApiResult<SupportTicketModel>> replyToTicket(
    String ticketId,
    String message,
  ) {
    return support.replyToTicket(ticketId, message);
  }

  Future<ApiResult<List<ReviewModel>>> getReviewsForSalon(String salonId) {
    return review.getReviewsForSalon(salonId);
  }

  Future<ApiResult<ReviewModel>> submitReview({
    required String salonId,
    required double rating,
    required String comment,
    String? bookingId,
  }) {
    return review.submitReview(
      salonId: salonId,
      rating: rating,
      comment: comment,
      bookingId: bookingId,
    );
  }

  Future<ApiResult<List<NotificationModel>>> getNotifications() {
    return notification.getNotifications();
  }

  Future<ApiResult<void>> markNotificationAsRead(String id) {
    return notification.markAsRead(id);
  }

  Future<ApiResult<BookingModel>> rescheduleBooking({
    required String bookingId,
    required String date,
    required String timeSlot,
  }) {
    return booking.rescheduleBooking(
      bookingId: bookingId,
      date: date,
      timeSlot: timeSlot,
    );
  }

  Future<ApiResult<BookingModel>> cancelBooking(String bookingId) {
    return booking.cancelBooking(bookingId);
  }

  Future<ApiResult<void>> recordPayment({
    required String bookingId,
    required String method,
    required double amount,
    required String transactionId,
  }) {
    return booking.recordPayment(
      bookingId: bookingId,
      method: method,
      amount: amount,
      transactionId: transactionId,
    );
  }
}
