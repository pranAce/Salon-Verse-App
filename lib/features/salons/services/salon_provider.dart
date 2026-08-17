import 'dart:async';
import 'package:flutter/material.dart';
import 'package:salonverse/features/salons/models/salon_model.dart';
import 'package:salonverse/features/salons/models/nearby_service_model.dart';
import 'package:salonverse/features/home/services/app_service.dart';
import 'package:salonverse/core/network/api_result.dart';

class SalonProvider extends ChangeNotifier {
  final _service = AppService.instance;
  Timer? _debounceTimer;

  List<SalonModel> _allSalons = [];
  List<SalonModel> get allSalons => _allSalons;

  List<SalonModel> _salons = [];
  List<SalonModel> get salons => _salons;

  List<NearbyServiceModel> _nearbyServices = [];
  List<NearbyServiceModel> get nearbyServices => _nearbyServices;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isNearbyLoading = false;
  bool get isNearbyLoading => _isNearbyLoading;

  String? _error;
  String? get error => _error;

  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  String _selectedCategory = "All";
  String get selectedCategory => _selectedCategory;

  String _selectedSort = "recommended";
  String get selectedSort => _selectedSort;

  double? _userLat;
  double? get userLat => _userLat;
  double? _userLng;
  double? get userLng => _userLng;
  double? _userRadius;

  List<SalonModel> get featuredSalons =>
      _allSalons.where((salon) => salon.isFeatured).toList();

  Future<void> fetchSalons({
    String? query,
    String? category,
    double? lat,
    double? lng,
    double? radius,
    bool silent = false,
    bool forceRefresh = false,
  }) async {
    if (query != null) _searchQuery = query;
    if (category != null) _selectedCategory = category;
    if (lat != null) _userLat = lat;
    if (lng != null) _userLng = lng;
    if (radius != null) _userRadius = radius;

    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    final result = await _service.getSalons(
      query: _searchQuery,
      category: _selectedCategory,
      lat: _userLat,
      lng: _userLng,
      radius: _userRadius,
      forceRefresh: forceRefresh,
    );

    _isLoading = false;
    if (result is Success<List<SalonModel>>) {
      _salons = result.data;
      if (_selectedCategory == "All" && _searchQuery.isEmpty) {
        _allSalons = List<SalonModel>.from(result.data);
      }
    } else {
      _error = (result as Failure).message;
    }
    notifyListeners();
  }

  Future<void> fetchNearbyServices({
    String? search,
    String? category,
    double? lat,
    double? lng,
    double? radius,
    String? sort,
    bool silent = false,
  }) async {
    if (search != null) _searchQuery = search;
    if (category != null) _selectedCategory = category;
    if (lat != null) _userLat = lat;
    if (lng != null) _userLng = lng;
    if (radius != null) _userRadius = radius;
    if (sort != null) _selectedSort = sort;

    if (!silent) {
      _isNearbyLoading = true;
      notifyListeners();
    }

    final result = await _service.getNearbyServices(
      search: _searchQuery,
      category: _selectedCategory,
      lat: _userLat,
      lng: _userLng,
      radius: _userRadius,
      sort: _selectedSort,
    );

    _isNearbyLoading = false;
    if (result is Success<List<NearbyServiceModel>>) {
      _nearbyServices = result.data;
    }
    notifyListeners();
  }

  void setSortOption(String sort) {
    _selectedSort = sort;
    fetchNearbyServices(sort: sort, silent: false);
  }

  void updateSearchQuery(String query, {double? lat, double? lng}) {
    _searchQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      fetchSalons(
        query: query,
        lat: lat ?? _userLat,
        lng: lng ?? _userLng,
        silent: true,
      );
      fetchNearbyServices(
        search: query,
        lat: lat ?? _userLat,
        lng: lng ?? _userLng,
        silent: true,
      );
    });
  }

  void clearSearch() {
    _searchQuery = "";
    fetchSalons(query: "", silent: true);
    fetchNearbyServices(search: "", silent: true);
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    fetchSalons(category: category, silent: false);
    fetchNearbyServices(category: category, silent: false);
  }

  List<SalonModel> getFavoriteSalons(List<String> favoriteIds) {
    return _allSalons.where((salon) => favoriteIds.contains(salon.id)).toList();
  }

  Future<void> toggleFavorite(String salonId) async {
    final result = await _service.toggleFavorite(salonId);
    if (result is Success) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
