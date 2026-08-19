import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:salonverse/core/network/api_result.dart';
import 'package:salonverse/features/loyalty/models/loyalty_model.dart';
import 'package:salonverse/features/loyalty/services/loyalty_service.dart';
import 'package:salonverse/features/notifications/services/socket_service.dart';

class LoyaltyProvider extends ChangeNotifier {
  final LoyaltyService _service = LoyaltyService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasLoadedData = false;
  bool get hasLoadedData => _hasLoadedData;

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

  List<LoyaltyTierModel> _allTiers = [];
  List<LoyaltyTierModel> get allTiers => _allTiers;

  List<LoyaltyRuleModel> _rules = [];
  List<LoyaltyRuleModel> get rules => _rules;

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

  bool _justLeveledUp = false;
  bool get justLeveledUp => _justLeveledUp;
  String? _newlyAchievedTier;
  String? get newlyAchievedTier => _newlyAchievedTier;

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

  void clearLevelUpFlag() {
    _justLeveledUp = false;
    _newlyAchievedTier = null;
    notifyListeners();
  }

  Future<void> loadLoyaltyData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final previousTier = _profile?.currentTier;

      final results = await Future.wait([
        _service.getProfile(),
        _service.getRewards(),
        _service.getMyVouchers(),
        _service.getActivity(),
        _service.getReferralStatus(),
        _service.getSmartRebook(),
        _service.getRules(),
        _service.getTiers(),
      ]);

      final profResult = results[0] as ApiResult<Map<String, dynamic>>;
      final rResult = results[1] as ApiResult<List<LoyaltyRewardModel>>;
      final vResult = results[2] as ApiResult<List<RewardRedemptionModel>>;
      final actResult = results[3] as ApiResult<List<LoyaltyTransactionModel>>;
      final refResult = results[4] as ApiResult<Map<String, dynamic>>;
      final rebResult = results[5] as ApiResult<SmartRebookModel>;
      final rulesResult = results[6] as ApiResult<List<LoyaltyRuleModel>>;
      final tiersResult = results[7] as ApiResult<List<LoyaltyTierModel>>;

      if (profResult is Success<Map<String, dynamic>>) {
        final data = profResult.data;
        if (data['profile'] != null) {
          _profile = LoyaltyProfileModel.fromJson(
            Map<String, dynamic>.from(data['profile']),
          );
        }
        if (data['currentTierDetails'] != null) {
          _currentTierDetails = LoyaltyTierModel.fromJson(
            Map<String, dynamic>.from(data['currentTierDetails']),
          );
        }
        if (data['nextTierDetails'] != null) {
          _nextTierDetails = LoyaltyTierModel.fromJson(
            Map<String, dynamic>.from(data['nextTierDetails']),
          );
        } else {
          _nextTierDetails = null;
        }
        _creditsNeededForNext =
            (data['creditsNeededForNext'] as num?)?.toInt() ?? 0;
        _progressRatio = (data['progressRatio'] as num?)?.toDouble() ?? 0.0;
        if (data['rules'] != null && data['rules'] is List) {
          _rules = (data['rules'] as List)
              .map(
                (r) => LoyaltyRuleModel.fromJson(Map<String, dynamic>.from(r)),
              )
              .toList();
        }

        final newTier = _profile?.currentTier;
        if (_hasLoadedData &&
            previousTier != null &&
            newTier != null &&
            previousTier != newTier) {
          _justLeveledUp = true;
          _newlyAchievedTier =
              _currentTierDetails?.name ?? newTier.toUpperCase();
        }
      } else if (profResult is Failure<Map<String, dynamic>>) {
        _error = profResult.message;
      }

      if (rResult is Success<List<LoyaltyRewardModel>>) {
        _rewards = rResult.data;
      }

      if (vResult is Success<List<RewardRedemptionModel>>) {
        _vouchers = vResult.data;
      }

      if (actResult is Success<List<LoyaltyTransactionModel>>) {
        _activity = actResult.data;
      }

      if (refResult is Success<Map<String, dynamic>>) {
        _referralCode = refResult.data['referralCode'] ?? '';
        _completedReferrals =
            (refResult.data['completedCount'] as num?)?.toInt() ?? 0;
      }

      if (rebResult is Success<SmartRebookModel>) {
        _smartRebook = rebResult.data;
      }

      if (_rules.isEmpty && rulesResult is Success<List<LoyaltyRuleModel>>) {
        _rules = rulesResult.data;
      }

      if (tiersResult is Success<List<LoyaltyTierModel>>) {
        _allTiers = tiersResult.data;
      }

      _hasLoadedData = true;
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _service.applyReferralCode(code);
    _isLoading = false;

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
