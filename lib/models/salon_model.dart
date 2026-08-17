import 'package:salonverse/core/utils/app_logger.dart';

class ServiceModel {
  final String id;
  final String name;
  final double price;
  final int durationMinutes;
  final String category;
  final String description;
  final String? assignedStaff;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMinutes,
    required this.category,
    required this.description,
    this.assignedStaff,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'durationMinutes': durationMinutes,
      'category': category,
      'description': description,
      'assignedStaff': assignedStaff,
    };
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['_id'])?.toString() ?? '';
    final name = json['name'] ?? '';
    final model = ServiceModel(
      id: id,
      name: name,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: json['durationMinutes'] as int? ?? 30,
      category: json['category'] ?? 'Hair',
      description: json['description'] ?? '',
      assignedStaff: json['assignedStaff']?.toString(),
    );
    AppLogger.logModelParse('ServiceModel', true, 'id: $id, name: $name');
    return model;
  }
}

class StylistModel {
  final String id;
  final String name;
  final String imageUrl;
  final String specialty;
  final List<String> specialties;
  final double rating;
  final int reviewCount;
  final List<String> portfolioImages;

  StylistModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.specialty,
    this.specialties = const [],
    required this.rating,
    this.reviewCount = 0,
    this.portfolioImages = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'specialty': specialty,
      'specialties': specialties,
      'rating': rating,
      'reviewCount': reviewCount,
      'portfolioImages': portfolioImages,
    };
  }

  factory StylistModel.fromJson(Map<String, dynamic> json) {
    List<String> specs = [];
    if (json['specialties'] is List) {
      specs = List<String>.from(json['specialties']);
    } else if (json['specialty'] != null) {
      specs = [json['specialty'].toString()];
    }

    final id = (json['id'] ?? json['_id'])?.toString() ?? '';
    final name = json['name'] ?? '';
    final model = StylistModel(
      id: id,
      name: name,
      imageUrl: json['imageUrl'] ?? json['avatar'] ?? '',
      specialty: specs.isNotEmpty ? specs.join(", ") : '',
      specialties: specs,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      portfolioImages: List<String>.from(
        json['portfolioImages'] ?? json['portfolio'] ?? [],
      ),
    );
    AppLogger.logModelParse('StylistModel', true, 'id: $id, name: $name');
    return model;
  }
}

class SalonModel {
  final String id;
  final String name;
  final String imageUrl;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewCount;
  final String openingHours;
  final String priceRange;
  final String description;
  final String phoneNumber;
  final bool isFeatured;
  final bool homeServiceAvailable;
  final List<String> publishedTimeSlots;
  final List<ServiceModel> services;
  final List<StylistModel> stylists;

  final double? distanceKm;

  String get coverImage => imageUrl;
  String get logo => imageUrl;
  String get phone => phoneNumber;

  SalonModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.address,
    this.city = 'Kathmandu',
    this.latitude = 27.7172,
    this.longitude = 85.3240,
    this.distanceKm,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.openingHours = '9:00 AM - 8:00 PM',
    this.priceRange = 'Rs. 200 - 1500',
    this.description = '',
    this.phoneNumber = '',
    this.isFeatured = false,
    this.homeServiceAvailable = false,
    this.publishedTimeSlots = const [],
    this.services = const [],
    this.stylists = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'distanceKm': distanceKm,
      'rating': rating,
      'reviewCount': reviewCount,
      'openingHours': openingHours,
      'priceRange': priceRange,
      'description': description,
      'phoneNumber': phoneNumber,
      'isFeatured': isFeatured,
      'homeServiceAvailable': homeServiceAvailable,
      'publishedTimeSlots': publishedTimeSlots,
      'services': services.map((e) => e.toJson()).toList(),
      'stylists': stylists.map((e) => e.toJson()).toList(),
    };
  }

  factory SalonModel.fromJson(Map<String, dynamic> json) {
    double lat = 27.7172;
    double lng = 85.3240;

    if (json['location'] != null && json['location']['coordinates'] is List) {
      List coords = json['location']['coordinates'];
      if (coords.length >= 2) {
        lng = (coords[0] as num).toDouble();
        lat = (coords[1] as num).toDouble();
      }
    } else {
      if (json['latitude'] != null) {
        lat = (json['latitude'] as num).toDouble();
      }
      if (json['longitude'] != null) {
        lng = (json['longitude'] as num).toDouble();
      }
    }

    final id = (json['id'] ?? json['_id'])?.toString() ?? '';
    final name = json['name'] ?? '';

    final model = SalonModel(
      id: id,
      name: name,
      imageUrl: json['imageUrl'] ?? json['coverImage'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? 'Kathmandu',
      latitude: lat,
      longitude: lng,
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      openingHours: json['openingHours'] is String
          ? json['openingHours']
          : '9:00 AM - 8:00 PM',
      priceRange: json['priceRange'] ?? 'Rs. 200 - 1500',
      description: json['description'] ?? '',
      phoneNumber: (json['phoneNumber'] ?? json['phone'])?.toString() ?? '',
      isFeatured: json['isFeatured'] as bool? ?? false,
      homeServiceAvailable: json['homeServiceAvailable'] as bool? ?? false,
      publishedTimeSlots: List<String>.from(json['publishedTimeSlots'] ?? []),
      services: (json['services'] as List? ?? [])
          .map((e) => ServiceModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      stylists: (json['stylists'] as List? ?? [])
          .map((e) => StylistModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
    AppLogger.logModelParse('SalonModel', true, 'id: $id, name: $name');
    return model;
  }
}
