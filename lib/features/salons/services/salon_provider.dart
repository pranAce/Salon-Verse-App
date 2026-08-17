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

  // Filter & Search State
  String _searchQuery = "";
  String get searchQuery => _searchQuery;

  String _selectedCategory = "All";
  String get selectedCategory => _selectedCategory;

  String _selectedSort = "recommended";
  String get selectedSort => _selectedSort;

  String _selectedCity = "All Locations";
  String get selectedCity => _selectedCity;

  double _minPrice = 0.0;
  double get minPrice => _minPrice;

  double _maxPrice = 10000.0;
  double get maxPrice => _maxPrice;

  double _minRating = 0.0;
  double get minRating => _minRating;

  bool _homeServiceOnly = false;
  bool get homeServiceOnly => _homeServiceOnly;

  double? _userLat;
  double? get userLat => _userLat;
  double? _userLng;
  double? get userLng => _userLng;
  double? _userRadius;
  double? get userRadius => _userRadius;

  List<SalonModel> get featuredSalons =>
      _allSalons.where((salon) => salon.isFeatured).toList();

  /// Returns the current active list of salons matching all criteria
  List<SalonModel> get filteredSalons {
    return _salons.where((s) {
      // 1. Search Query
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase().trim();
        final nameMatch = s.name.toLowerCase().contains(q);
        final addressMatch = s.address.toLowerCase().contains(q);
        final cityMatch = s.city.toLowerCase().contains(q);
        final serviceMatch = s.services.any((srv) => srv.name.toLowerCase().contains(q));
        final stylistMatch = s.stylists.any((st) => st.name.toLowerCase().contains(q));
        if (!nameMatch && !addressMatch && !cityMatch && !serviceMatch && !stylistMatch) {
          return false;
        }
      }

      // 2. City Filter
      if (_selectedCity != "All Locations" && _selectedCity.isNotEmpty) {
        final c = _selectedCity.toLowerCase();
        final salonCity = s.city.toLowerCase();
        final salonAddr = s.address.toLowerCase();
        if (!salonCity.contains(c) && !salonAddr.contains(c)) {
          return false;
        }
      }

      // 3. Minimum Rating Filter
      if (_minRating > 0.0) {
        if (s.rating < _minRating) return false;
      }

      // 4. Home Service Availability Filter
      if (_homeServiceOnly) {
        if (!s.homeServiceAvailable) return false;
      }

      // 5. Price Range Filter (if salon has services)
      if (s.services.isNotEmpty && (_minPrice > 0 || _maxPrice < 10000)) {
        final hasMatchingPrice = s.services.any((srv) =>
            srv.price >= _minPrice && srv.price <= _maxPrice);
        if (!hasMatchingPrice) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        if (_selectedSort == "rating") {
          return b.rating.compareTo(a.rating);
        } else if (_selectedSort == "nearest") {
          return (a.distanceKm ?? 999.0).compareTo(b.distanceKm ?? 999.0);
        } else if (_selectedSort == "price_asc") {
          final minA = a.services.isNotEmpty
              ? a.services.map((s) => s.price).reduce((curr, next) => curr < next ? curr : next)
              : 0.0;
          final minB = b.services.isNotEmpty
              ? b.services.map((s) => s.price).reduce((curr, next) => curr < next ? curr : next)
              : 0.0;
          return minA.compareTo(minB);
        }
        return 0;
      });
  }

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

  Future<SalonModel?> fetchSalonDetails(String id) async {
    final result = await _service.getSalonById(id);
    if (result is Success<SalonModel>) {
      // Update in cached lists
      final idx = _salons.indexWhere((s) => s.id == id);
      if (idx != -1) {
        _salons[idx] = result.data;
      }
      final allIdx = _allSalons.indexWhere((s) => s.id == id);
      if (allIdx != -1) {
        _allSalons[allIdx] = result.data;
      }
      notifyListeners();
      return result.data;
    }
    return null;
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
    notifyListeners();
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

  void applyFilters({
    String? category,
    String? sort,
    String? city,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    bool? homeServiceOnly,
  }) {
    if (category != null) _selectedCategory = category;
    if (sort != null) _selectedSort = sort;
    if (city != null) _selectedCity = city;
    if (minPrice != null) _minPrice = minPrice;
    if (maxPrice != null) _maxPrice = maxPrice;
    if (minRating != null) _minRating = minRating;
    if (homeServiceOnly != null) _homeServiceOnly = homeServiceOnly;

    fetchSalons(category: _selectedCategory, silent: false, forceRefresh: true);
    fetchNearbyServices(category: _selectedCategory, sort: _selectedSort, silent: false);
  }

  void clearAllFilters() {
    _searchQuery = "";
    _selectedCategory = "All";
    _selectedSort = "recommended";
    _selectedCity = "All Locations";
    _minPrice = 0.0;
    _maxPrice = 10000.0;
    _minRating = 0.0;
    _homeServiceOnly = false;

    fetchSalons(query: "", category: "All", silent: false, forceRefresh: true);
    fetchNearbyServices(search: "", category: "All", sort: "recommended", silent: false);
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
