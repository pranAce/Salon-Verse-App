import 'dart:async';
import 'package:flutter/material.dart';
import 'package:salonverse/features/auth/models/user_model.dart';
import 'package:salonverse/features/home/services/app_service.dart';
import 'package:salonverse/core/network/api_result.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AppService.instance;

  UserModel? get currentUser => _service.currentUser;
  bool get isLoggedIn => currentUser != null;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _autoLoginDone = false;
  bool get autoLoginDone => _autoLoginDone;
  final Completer<void> _autoLoginCompleter = Completer<void>();
  Future<void> get autoLoginFuture => _autoLoginCompleter.future;

  String? _error;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? referralCode,
    String? dateOfBirth,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      referralCode: referralCode,
      dateOfBirth: dateOfBirth,
    );

    _isLoading = false;
    if (result is Success<UserModel>) {
      _service.socket.connect();
      notifyListeners();
      return true;
    } else {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.login(email: email, password: password);

    _isLoading = false;
    if (result is Success<UserModel>) {
      _service.socket.connect();
      notifyListeners();
      return true;
    } else {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
  }

  Future<void> tryAutoLogin() async {
    try {
      final success = await _service.tryAutoLogin();
      if (success) {
        _service.socket.connect();
        notifyListeners();
      }
    } finally {
      _autoLoginDone = true;
      if (!_autoLoginCompleter.isCompleted) {
        _autoLoginCompleter.complete();
      }
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _service.socket.disconnect();
    await _service.logout();
    notifyListeners();
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.resetPassword(email);

    _isLoading = false;
    if (result is Success) {
      notifyListeners();
      return true;
    } else {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? dateOfBirth,
    Map<String, dynamic>? homeLocation,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.updateProfile(
      name: name,
      phone: phone,
      dateOfBirth: dateOfBirth,
      homeLocation: homeLocation,
    );

    _isLoading = false;
    if (result is Success<UserModel>) {
      notifyListeners();
      return true;
    } else {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleFavorite(String salonId) async {
    final result = await _service.toggleFavorite(salonId);
    if (result is Success) {
      notifyListeners();
    }
  }
}
