import 'package:salonverse/features/salons/models/salon_model.dart';

class NearbyServiceModel {
  final String id;
  final String serviceId;
  final String serviceName;
  final String serviceDescription;
  final String category;
  final double price;
  final int durationMinutes;
  final String currency;
  final String salonId;
  final String salonName;
  final String salonLogo;
  final String salonCover;
  final String address;
  final String city;
  final double rating;
  final int reviewCount;
  final bool homeServiceAvailable;
  final double? distanceKm;
  final bool isCheapest;
  final SalonModel salon;
  final ServiceModel service;

  NearbyServiceModel({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.serviceDescription,
    required this.category,
    required this.price,
    required this.durationMinutes,
    required this.currency,
    required this.salonId,
    required this.salonName,
    required this.salonLogo,
    required this.salonCover,
    required this.address,
    required this.city,
    required this.rating,
    required this.reviewCount,
    required this.homeServiceAvailable,
    this.distanceKm,
    this.isCheapest = false,
    required this.salon,
    required this.service,
  });

  factory NearbyServiceModel.fromJson(Map<String, dynamic> json) {
    final sId = (json['serviceId'] ?? json['id'] ?? json['_id'])?.toString() ?? '';
    final salId = (json['salonId'] ?? json['salon']?['_id'])?.toString() ?? '';
    final sName = json['serviceName'] ?? json['name'] ?? 'Service';
    final salName = json['salonName'] ?? json['salon']?['name'] ?? 'Salon';
    final pPrice = (json['price'] as num?)?.toDouble() ?? 0.0;
    final durMin = (json['durationMinutes'] as num?)?.toInt() ?? 30;

    SalonModel parsedSalon;
    if (json['fullSalon'] is Map<String, dynamic>) {
      parsedSalon = SalonModel.fromJson(Map<String, dynamic>.from(json['fullSalon']));
    } else if (json['salon'] is Map<String, dynamic>) {
      parsedSalon = SalonModel.fromJson(Map<String, dynamic>.from(json['salon']));
    } else {
      parsedSalon = SalonModel(
        id: salId,
        name: salName,
        imageUrl: json['salonLogo'] ?? json['salonCover'] ?? '',
        address: json['address'] ?? '',
        city: json['city'] ?? 'Kathmandu',
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      );
    }

    final parsedService = ServiceModel(
      id: sId,
      name: sName,
      price: pPrice,
      durationMinutes: durMin,
      category: json['category']?.toString() ?? 'Hair',
      description: json['serviceDescription']?.toString() ?? json['description']?.toString() ?? '',
    );

    return NearbyServiceModel(
      id: sId,
      serviceId: sId,
      serviceName: sName,
      serviceDescription: json['serviceDescription']?.toString() ?? json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Hair',
      price: pPrice,
      durationMinutes: durMin,
      currency: json['currency']?.toString() ?? 'NPR',
      salonId: salId,
      salonName: salName,
      salonLogo: json['salonLogo']?.toString() ?? parsedSalon.imageUrl,
      salonCover: json['salonCover']?.toString() ?? parsedSalon.imageUrl,
      address: json['address']?.toString() ?? parsedSalon.address,
      city: json['city']?.toString() ?? parsedSalon.city,
      rating: (json['rating'] as num?)?.toDouble() ?? parsedSalon.rating,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? parsedSalon.reviewCount,
      homeServiceAvailable: json['homeServiceAvailable'] == true || parsedSalon.homeServiceAvailable,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? parsedSalon.distanceKm,
      isCheapest: json['isCheapest'] == true,
      salon: parsedSalon,
      service: parsedService,
    );
  }
}
