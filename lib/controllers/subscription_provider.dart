import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:salonverse/models/subscription_model.dart';
import 'package:salonverse/services/subscription_service.dart';
import 'package:salonverse/services/socket_service.dart';
import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/utils/app_logger.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService _service = SubscriptionService();

  SubscriptionModel? _subscription;
  List<SubscriptionPaymentModel> _payments = [];
  List<SubscriptionHistoryModel> _history = [];
  Map<String, dynamic> _planConfig = {};
  List<String> _allowedFeatures = [];
  List<String> _restrictedFeatures = [];

  bool _isLoading = false;
  String? _error;

  StreamSubscription? _socketSub;

  SubscriptionModel? get subscription => _subscription;
  List<SubscriptionPaymentModel> get payments => _payments;
  List<SubscriptionHistoryModel> get history => _history;
  Map<String, dynamic> get planConfig => _planConfig;
  List<String> get allowedFeatures => _allowedFeatures;
  List<String> get restrictedFeatures => _restrictedFeatures;

  bool get isLoading => _isLoading;
  String? get error => _error;

  SubscriptionProvider() {
    _initSocketListener();
  }

  void _initSocketListener() {
    _socketSub = SocketService.instance.onSubscriptionUpdated.listen((data) {
      final subMap = data['subscription'];
      if (subMap is Map<String, dynamic>) {
        _subscription = SubscriptionModel.fromJson(subMap);
        AppLogger.logState('Subscription', 'Socket -> SubscriptionUpdated: ${subMap['plan']}');
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    super.dispose();
  }

  Future<void> fetchCurrentSubscription([String? salonId]) async {
    _isLoading = true;
    _error = null;
    AppLogger.logState('SubscriptionManage', 'StateChanged -> LOADING');
    notifyListeners();

    final result = await _service.getCurrentSubscription(salonId);

    if (result is Success<SubscriptionDataPayload>) {
      _subscription = result.data.subscription;
      _payments = result.data.payments;
      _history = result.data.history;
      _planConfig = result.data.planConfig;
      _allowedFeatures = result.data.allowedFeatures;
      _restrictedFeatures = result.data.restrictedFeatures;
      _error = null;
      AppLogger.logState('SubscriptionManage', 'StateChanged -> SUCCESS (${_subscription?.plan})');
    } else if (result is Failure) {
      _error = (result as Failure).message;
      AppLogger.logState('SubscriptionManage', 'StateChanged -> ERROR ($_error)');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> submitManualPayment({
    required String salonId,
    required String plan,
    required String paymentMethod,
    String? paymentReference,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.submitManualPayment(
      salonId: salonId,
      plan: plan,
      paymentMethod: paymentMethod,
      paymentReference: paymentReference,
      notes: notes,
      timing: "next_cycle",
    );

    _isLoading = false;

    if (result is Success) {
      await fetchCurrentSubscription(salonId);
      return true;
    } else if (result is Failure) {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
    return false;
  }

  Future<bool> processOnlinePayment({
    required String salonId,
    required String plan,
    required String paymentMethod,
    required String paymentReference,
    String? idempotencyKey,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.processOnlinePayment(
      salonId: salonId,
      plan: plan,
      paymentMethod: paymentMethod,
      paymentReference: paymentReference,
      idempotencyKey: idempotencyKey,
      timing: "next_cycle",
    );

    _isLoading = false;

    if (result is Success) {
      await fetchCurrentSubscription(salonId);
      return true;
    } else if (result is Failure) {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
    return false;
  }

  Future<bool> cancelScheduledChange([String? salonId]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.cancelScheduledChange(salonId);

    _isLoading = false;

    if (result is Success<SubscriptionModel>) {
      _subscription = result.data;
      await fetchCurrentSubscription(salonId);
      return true;
    } else if (result is Failure) {
      _error = (result as Failure).message;
      notifyListeners();
      return false;
    }
    return false;
  }
}
