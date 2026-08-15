import 'package:flutter_test/flutter_test.dart';
import 'package:salonverse/models/user_model.dart';
import 'package:salonverse/models/salon_model.dart';
import 'package:salonverse/models/booking_model.dart';
import 'package:salonverse/models/staff_model.dart';
import 'package:salonverse/core/constants/app_constants.dart';
import 'package:salonverse/core/network/api_result.dart';

void main() {
  group('Model Serialization & Business Logic Tests', () {
    test('UserModel parse and role helper test', () {
      final user = UserModel.fromJson({
        'id': 'user_123',
        'name': 'Test User',
        'email': 'test@example.com',
        'role': 'user',
        'favoriteSalons': ['salon_1'],
        'permissions': ['*'],
      });

      expect(user.id, 'user_123');
      expect(user.isCustomer, isTrue);
      expect(user.isSalonRole, isFalse);
      expect(user.hasPermission('anything'), isTrue);
      expect(user.favoriteSalons.contains('salon_1'), isTrue);
    });

    test('StaffModel parse and schedule test', () {
      final staff = StaffModel.fromJson({
        '_id': 'staff_999',
        'name': 'Senior Stylist',
        'email': 'staff@salon.com',
        'salon': 'salon_1',
        'assignedServices': ['haircut', 'coloring'],
        'status': 'active',
      });

      expect(staff.id, 'staff_999');
      expect(staff.name, 'Senior Stylist');
      expect(staff.isActive, isTrue);
      expect(staff.assignedServices.length, 2);
    });

    test('SalonModel coordinates and services parsing', () {
      final salon = SalonModel.fromJson({
        '_id': 'salon_001',
        'name': 'Luxury Salon',
        'location': {
          'type': 'Point',
          'coordinates': [85.3240, 27.7172],
        },
        'rating': 4.8,
        'services': [
          {
            '_id': 'srv_1',
            'name': 'Haircut',
            'price': 500,
            'durationMinutes': 30,
            'category': 'Hair',
          },
        ],
      });

      expect(salon.id, 'salon_001');
      expect(salon.longitude, 85.3240);
      expect(salon.latitude, 27.7172);
      expect(salon.services.length, 1);
      expect(salon.services.first.price, 500.0);
    });

    test('BookingModel fromJson and queue status', () {
      final booking = BookingModel.fromJson({
        '_id': 'bk_100',
        'user': {'_id': 'u1', 'name': 'John'},
        'salon': {'_id': 's1', 'name': 'Salon 1', 'address': 'Kathmandu'},
        'service': {'_id': 'srv1', 'name': 'Shave', 'price': 300},
        'status': 'in_queue',
        'queuePosition': 2,
        'paymentMethod': 'Cash',
      });

      expect(booking.id, 'bk_100');
      expect(booking.userName, 'John');
      expect(booking.servicePrice, 300.0);
      expect(booking.status, 'in_queue');
      expect(booking.queuePosition, 2);
    });

    test('ApiResult Success and Failure types', () {
      const success = Success<String>('ok');
      const failure = Failure<String>('error message', statusCode: 404);

      expect(success.data, 'ok');
      expect(failure.message, 'error message');
      expect(failure.statusCode, 404);
    });

    test('KConstants default values', () {
      expect(KConstants.onboardingSeenKey, 'onboarding_seen');
      expect(KConstants.themeModeKey, 'theme_mode');
      expect(KConstants.defaultMockMode, isFalse);
    });
  });
}
