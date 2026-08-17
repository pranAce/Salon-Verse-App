import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/network/base_client.dart';
import 'package:salonverse/models/user_model.dart';
import 'package:salonverse/services/salon_service.dart';

class AuthService {
  final BaseClient _client = BaseClient.instance;
  static const String _tokenKey = 'backend_access_token';

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  final ValueNotifier<UserModel?> currentUserNotifier =
      ValueNotifier<UserModel?>(null);
  String? _token;

  String? get token => _token;
  bool get isMockMode => false;

  String formatError(dynamic e) {
    return e.toString().replaceAll('Exception: ', '');
  }

  void _setUser(UserModel? user) {
    _currentUser = user;
    currentUserNotifier.value = user;
  }

  Future<ApiResult<UserModel>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? referralCode,
    String? dateOfBirth,
  }) async {
    final result = await _client.request(
      "POST",
      "/api/v1/auth/register",
      body: {
        "name": name,
        "email": email,
        "password": password,
        "phone": phone,
        if (referralCode != null && referralCode.isNotEmpty)
          "referralCode": referralCode.trim().toUpperCase(),
        if (dateOfBirth != null && dateOfBirth.isNotEmpty)
          "dateOfBirth": dateOfBirth,
      },
      onSuccess: (data) => data as Map<String, dynamic>,
    );

    if (result is Success<Map<String, dynamic>>) {
      _token = result.data['accessToken'];
      _setUser(UserModel.fromJson(result.data['user']));
      if (_token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _token!);
      }
      return Success(_currentUser!);
    }
    return Failure((result as Failure).message);
  }

  Future<ApiResult<UserModel>> login({
    required String email,
    required String password,
  }) async {
    final result = await _client.request(
      "POST",
      "/api/v1/auth/login",
      body: {"email": email, "password": password},
      onSuccess: (data) => data as Map<String, dynamic>,
    );

    if (result is Success<Map<String, dynamic>>) {
      _token = result.data['accessToken'];
      _setUser(UserModel.fromJson(result.data['user']));
      if (_token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, _token!);
      }
      return Success(_currentUser!);
    }
    return Failure((result as Failure).message);
  }

  Future<bool> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
      if (_token == null || _token!.isEmpty) return false;

      final result = await _client.request(
        "GET",
        "/api/v1/users/me",
        auth: true,
        onSuccess: (data) => UserModel.fromJson(data),
      );

      if (result is Success<UserModel>) {
        _setUser(result.data);
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (_token != null) {
        await _client.request(
          "POST",
          "/api/v1/auth/logout",
          auth: true,
          onSuccess: (_) {},
        );
      }
    } catch (_) {}
    _setUser(null);
    _token = null;
    SalonService().clearCache();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<ApiResult<void>> resetPassword(String email) => _client.request(
    "POST",
    "/api/v1/users/forgot-password",
    body: {"email": email},
    onSuccess: (_) {},
  );

  Future<ApiResult<UserModel>> updateProfile({
    String? name,
    String? phone,
    String? dateOfBirth,
    Map<String, dynamic>? homeLocation,
  }) async {
    if (_token == null) return const Failure("Not logged in");

    final body = <String, dynamic>{};
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (phone != null && phone.isNotEmpty) body['phone'] = phone;
    if (dateOfBirth != null && dateOfBirth.isNotEmpty) body['dateOfBirth'] = dateOfBirth;
    if (homeLocation != null) body['homeLocation'] = homeLocation;

    final result = await _client.request(
      "PUT",
      "/api/v1/users/me",
      auth: true,
      body: body,
      onSuccess: (data) => UserModel.fromJson(data),
    );

    if (result is Success<UserModel>) {
      _setUser(result.data);
    }
    return result;
  }

  void syncCurrentUser(UserModel? user) {
    _setUser(user);
  }
}
