import 'package:flutter/material.dart';
import 'package:salonverse/models/staff_model.dart';
import 'package:salonverse/models/target_model.dart';
import 'package:salonverse/services/admin_api_service.dart';
import 'package:salonverse/services/app_service.dart';
import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/utils/app_logger.dart';

class SalonWorkspaceProvider extends ChangeNotifier {
  final _apiService = AdminApiService.instance;
  final _appService = AppService.instance;

  List<StaffModel> _staffList = [];
  List<StaffModel> get staffList => _staffList;

  List<TargetModel> _targets = [];
  List<TargetModel> get targets => _targets;

  Map<String, dynamic>? _dashboardMetrics;
  Map<String, dynamic>? get dashboardMetrics => _dashboardMetrics;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> fetchDashboardMetrics() async {
    _isLoading = true;
    _error = null;
    AppLogger.logState('SalonAdminDashboard', 'StateChanged -> LOADING');
    notifyListeners();

    final result = await _apiService.getDashboardMetrics();
    _isLoading = false;

    if (result is Success<Map<String, dynamic>>) {
      _dashboardMetrics = result.data;
      AppLogger.logState('SalonAdminDashboard', 'StateChanged -> SUCCESS');
      notifyListeners();
      return true;
    } else {
      _error = (result as Failure).message;
      AppLogger.logState('SalonAdminDashboard', 'StateChanged -> ERROR ($_error)');
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchStaff(String salonId) async {
    _isLoading = true;
    _error = null;
    AppLogger.logState('SalonAdminStaff', 'StateChanged -> LOADING (Salon: $salonId)');
    notifyListeners();

    final result = await _apiService.getStaffList(salonId: salonId);
    _isLoading = false;

    if (result is Success<List<dynamic>>) {
      _staffList = result.data
          .map((json) => StaffModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      AppLogger.logState('SalonAdminStaff', 'StateChanged -> SUCCESS (${_staffList.length} staff)');
      notifyListeners();
      return true;
    } else {
      _error = (result as Failure).message;
      AppLogger.logState('SalonAdminStaff', 'StateChanged -> ERROR ($_error)');
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchTargets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _appService.getTargets();
    _isLoading = false;

    if (result is Success<List<TargetModel>>) {
      _targets = result.data;
      notifyListeners();
      return true;
    } else {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createTarget({
    required String title,
    required String targetType,
    required String startDate,
    required String endDate,
    required double targetAmount,
    String? salonId,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _appService.createTarget(
      title: title,
      targetType: targetType,
      startDate: startDate,
      endDate: endDate,
      targetAmount: targetAmount,
      salonId: salonId,
      notes: notes,
    );

    _isLoading = false;
    if (result is Success<TargetModel>) {
      await fetchTargets();
      return true;
    } else {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTarget({
    required String id,
    String? title,
    double? targetAmount,
    String? startDate,
    String? endDate,
    String? notes,
    String? status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _appService.updateTarget(
      id: id,
      title: title,
      targetAmount: targetAmount,
      startDate: startDate,
      endDate: endDate,
      notes: notes,
      status: status,
    );

    _isLoading = false;
    if (result is Success<TargetModel>) {
      await fetchTargets();
      return true;
    } else {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTarget(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _appService.deleteTarget(id);

    _isLoading = false;
    if (result is Success<void>) {
      await fetchTargets();
      return true;
    } else {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createStaff({
    required String salonId,
    required String email,
    required String password,
    required String name,
    String? phone,
    List<String> assignedServices = const [],
    Map<String, dynamic> schedule = const {},
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.createStaff(
      salonId: salonId,
      email: email,
      password: password,
      name: name,
      phone: phone,
      assignedServices: assignedServices,
      schedule: schedule,
    );

    _isLoading = false;
    if (result is Success<Map<String, dynamic>>) {
      await fetchStaff(salonId);
      return true;
    } else {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStaff({
    required String salonId,
    required String staffId,
    String? name,
    String? phone,
    List<String>? assignedServices,
    Map<String, dynamic>? schedule,
    String? status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.updateStaff(
      salonId: salonId,
      staffId: staffId,
      name: name,
      phone: phone,
      assignedServices: assignedServices,
      schedule: schedule,
      status: status,
    );

    _isLoading = false;
    if (result is Success<void>) {
      await fetchStaff(salonId);
      return true;
    } else {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetStaffPassword({
    required String salonId,
    required String staffId,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.resetStaffPassword(
      salonId: salonId,
      staffId: staffId,
      newPassword: newPassword,
    );

    _isLoading = false;
    if (result is Success<void>) {
      return true;
    } else {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    _error = null;
    final result = await _apiService.updateBookingStatus(
      bookingId: bookingId,
      status: status,
    );

    if (result is Success<void>) {
      return true;
    } else {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveService({
    required String salonId,
    required String id,
    required String name,
    required double price,
    required int durationMinutes,
    required String category,
    required String description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.saveService(
      salonId: salonId,
      id: id,
      name: name,
      price: price,
      durationMinutes: durationMinutes,
      category: category,
      description: description,
    );

    _isLoading = false;
    if (result is Success<void>) {
      notifyListeners();
      return true;
    } else {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteService({
    required String salonId,
    required String serviceId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.deleteService(
      salonId: salonId,
      serviceId: serviceId,
    );

    _isLoading = false;
    if (result is Success<void>) {
      notifyListeners();
      return true;
    } else {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSalonProfile({
    required String salonId,
    required String name,
    required String phone,
    required String address,
    required String city,
    required String description,
    required String priceRange,
    String? imageUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _appService.updateSalon(
      salonId: salonId,
      name: name,
      phone: phone,
      address: address,
      city: city,
      description: description,
      priceRange: priceRange,
      imageUrl: imageUrl,
    );

    _isLoading = false;
    if (result is Success<void>) {
      notifyListeners();
      return true;
    } else {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
  }
}
