import 'package:salonverse/models/user_model.dart';
import 'package:salonverse/models/salon_model.dart';
import 'package:salonverse/models/booking_model.dart';
import 'package:salonverse/models/support_ticket_model.dart';
import 'package:salonverse/models/review_model.dart';
import 'package:salonverse/models/notification_model.dart';
import 'package:salonverse/models/target_model.dart';
import 'package:salonverse/services/api_result.dart';

// Split Service Imports
import 'package:salonverse/services/auth_service.dart';
import 'package:salonverse/services/salon_service.dart';
import 'package:salonverse/services/booking_service.dart';
import 'package:salonverse/services/support_service.dart';
import 'package:salonverse/services/review_service.dart';
import 'package:salonverse/services/notification_service.dart';
import 'package:salonverse/services/target_service.dart';

class AppService {
  static final AppService _instance = AppService._();
  static AppService get instance => _instance;
  AppService._();

  // Focused Service Delegators
  final auth = AuthService();
  final salon = SalonService();
  final booking = BookingService();
  final support = SupportService();
  final review = ReviewService();
  final notification = NotificationService();
  final target = TargetService();

  UserModel? get currentUser => auth.currentUser;
  bool get isMockMode => auth.isMockMode;

  Future<ApiResult<UserModel>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) {
    return auth.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
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
    Map<String, dynamic>? homeLocation,
  }) {
    return auth.updateProfile(name: name, phone: phone, homeLocation: homeLocation);
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

  Future<ApiResult<void>> toggleFavorite(String salonId) {
    return salon.toggleFavorite(salonId, auth.currentUser, (updatedUser) {
      auth.syncCurrentUser(updatedUser);
    });
  }

  Future<ApiResult<BookingModel>> createBooking({
    required SalonModel salon,
    required ServiceModel service,
    required StylistModel stylist,
    required String date,
    required String timeSlot,
    required String paymentMethod,
    bool isHomeService = false,
    String homeAddress = '',
    String contactNumber = '',
    double? latitude,
    double? longitude,
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
    );
  }

  Future<ApiResult<List<BookingModel>>> getBookings() {
    return booking.getBookings(auth.currentUser);
  }

  Future<ApiResult<List<BookingModel>>> getCompletedBookingsForSalon(String salonId) {
    return booking.getCompletedBookingsForSalon(salonId);
  }

  Stream<BookingModel?> streamQueueStatus(String bookingId) {
    return booking.streamQueueStatus(bookingId);
  }

  Future<ApiResult<SupportTicketModel>> createSupportTicket(
      String subject, String message) {
    return support.createSupportTicket(auth.currentUser, subject, message);
  }

  Future<ApiResult<List<SupportTicketModel>>> getSupportTickets() {
    return support.getSupportTickets(auth.currentUser);
  }

  Future<ApiResult<SupportTicketModel>> replyToTicket(
      String ticketId, String message) {
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

  Future<ApiResult<List<TargetModel>>> getTargets() {
    return target.getTargets();
  }

  Future<ApiResult<TargetModel>> createTarget({
    required String title,
    required String targetType,
    required String startDate,
    required String endDate,
    required double targetAmount,
    String? salonId,
    String? notes,
  }) {
    return target.createTarget(
      title: title,
      targetType: targetType,
      startDate: startDate,
      endDate: endDate,
      targetAmount: targetAmount,
      salonId: salonId,
      notes: notes,
    );
  }

  Future<ApiResult<TargetModel>> updateTarget({
    required String id,
    String? title,
    double? targetAmount,
    String? startDate,
    String? endDate,
    String? notes,
    String? status,
  }) {
    return target.updateTarget(
      id: id,
      title: title,
      targetAmount: targetAmount,
      startDate: startDate,
      endDate: endDate,
      notes: notes,
      status: status,
    );
  }

  Future<ApiResult<void>> deleteTarget(String id) {
    return target.deleteTarget(id);
  }
}
