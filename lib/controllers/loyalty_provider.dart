import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/core/utils/app_logger.dart';
import 'package:salonverse/models/loyalty_model.dart';
import 'package:salonverse/services/loyalty_service.dart';
import 'package:salonverse/services/socket_service.dart';

class LoyaltyProvider extends ChangeNotifier {
  final LoyaltyService _service = LoyaltyService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  LoyaltyProfileModel? _profile;
  LoyaltyProfileModel? get profile => _profile;

  LoyaltyTierModel? _currentTierDetails;
  LoyaltyTierModel? get currentTierDetails => _currentTierDetails;

  LoyaltyTierModel? _nextTierDetails;
  LoyaltyTierModel? get nextTierDetails => _nextTierDetails;

  int _creditsNeededForNext = 0;
  int get creditsNeededForNext => _creditsNeededForNext;

  double _progressRatio = 0.0;
  double get progressRatio => _progressRatio;

  List<LoyaltyRewardModel> _rewards = [];
  List<LoyaltyRewardModel> get rewards => _rewards;

  List<RewardRedemptionModel> _vouchers = [];
  List<RewardRedemptionModel> get vouchers => _vouchers;

  List<LoyaltyTransactionModel> _activity = [];
  List<LoyaltyTransactionModel> get activity => _activity;

  String _referralCode = '';
  String get referralCode => _referralCode;

  int _completedReferrals = 0;
  int get completedReferrals => _completedReferrals;

  SmartRebookModel? _smartRebook;
  SmartRebookModel? get smartRebook => _smartRebook;

  StreamSubscription? _balanceSub;
  StreamSubscription? _tierSub;

  LoyaltyProvider() {
    _initSocketListeners();
  }

  void _initSocketListeners() {
    _balanceSub = SocketService.instance.onLoyaltyBalanceUpdated.listen((_) {
      loadLoyaltyData();
    });
    _tierSub = SocketService.instance.onLoyaltyTierUpdated.listen((_) {
      loadLoyaltyData();
    });
  }

  @override
  void dispose() {
    _balanceSub?.cancel();
    _tierSub?.cancel();
    super.dispose();
  }

  Future<void> loadLoyaltyData() async {
    _isLoading = true;
    _error = null;
    AppLogger.logState('LoyaltyPage', 'StateChanged -> LOADING');
    notifyListeners();

    try {
      final profResult = await _service.getProfile();
      if (profResult is Success<Map<String, dynamic>>) {
        final data = profResult.data;
        _profile = LoyaltyProfileModel.fromJson(data['profile']);
        if (data['currentTierDetails'] != null) {
          _currentTierDetails = LoyaltyTierModel.fromJson(data['currentTierDetails']);
        }
        if (data['nextTierDetails'] != null) {
          _nextTierDetails = LoyaltyTierModel.fromJson(data['nextTierDetails']);
        }
        _creditsNeededForNext = (data['creditsNeededForNext'] as num?)?.toInt() ?? 0;
        _progressRatio = (data['progressRatio'] as num?)?.toDouble() ?? 0.0;
      } else if (profResult is Failure<Map<String, dynamic>>) {
        _error = profResult.message;
      }

      final rResult = await _service.getRewards();
      if (rResult is Success<List<LoyaltyRewardModel>>) {
        _rewards = rResult.data;
      }

      final vResult = await _service.getMyVouchers();
      if (vResult is Success<List<RewardRedemptionModel>>) {
        _vouchers = vResult.data;
      }

      final actResult = await _service.getActivity();
      if (actResult is Success<List<LoyaltyTransactionModel>>) {
        _activity = actResult.data;
      }

      final refResult = await _service.getReferralStatus();
      if (refResult is Success<Map<String, dynamic>>) {
        _referralCode = refResult.data['referralCode'] ?? '';
        _completedReferrals = (refResult.data['completedCount'] as num?)?.toInt() ?? 0;
      }

      final rebResult = await _service.getSmartRebook();
      if (rebResult is Success<SmartRebookModel>) {
        _smartRebook = rebResult.data;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> claimReward(String rewardId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _service.claimReward(rewardId);
    _isLoading = false;

    if (result is Success<RewardRedemptionModel>) {
      await loadLoyaltyData();
      return true;
    } else if (result is Failure<RewardRedemptionModel>) {
      _error = result.message;
      notifyListeners();
      return false;
    }
    return false;
  }

  Future<bool> applyReferralCode(String code) async {
    final result = await _service.applyReferralCode(code);
    if (result is Success<void>) {
      await loadLoyaltyData();
      return true;
    } else if (result is Failure<void>) {
      _error = result.message;
      notifyListeners();
      return false;
    }
    return false;
  }
}
