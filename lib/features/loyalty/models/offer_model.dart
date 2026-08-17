import 'package:flutter/material.dart';

class OfferSalonModel {
  final String id;
  final String name;
  final String address;
  final String city;

  const OfferSalonModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
  });

  factory OfferSalonModel.fromJson(Map<String, dynamic> json) {
    return OfferSalonModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
    );
  }
}

class OfferModel {
  final String id;
  final String code;
  final String title;
  final String description;
  final String discountType;
  final double discountValue;
  final double minOrderAmount;
  final double? maxDiscount;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final Color badgeColor;
  final String category;
  final IconData icon;
  final List<OfferSalonModel> applicableSalons;
  final List<String> applicableCategories;

  const OfferModel({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    this.maxDiscount,
    this.startDate,
    this.endDate,
    required this.isActive,
    required this.badgeColor,
    required this.category,
    required this.icon,
    this.applicableSalons = const [],
    this.applicableCategories = const [],
  });

  String get discountLabel {
    if (discountType == 'percentage') {
      return "${discountValue.round()}% OFF";
    }
    return "NPR ${discountValue.round()} OFF";
  }

  String get primarySalonName {
    if (applicableSalons.isNotEmpty && applicableSalons.first.name.isNotEmpty) {
      return applicableSalons.first.name;
    }
    return "All Partner Salons";
  }

  String get primaryLocation {
    if (applicableSalons.isNotEmpty) {
      final s = applicableSalons.first;
      if (s.address.isNotEmpty && s.city.isNotEmpty) {
        return "${s.address}, ${s.city}";
      } else if (s.address.isNotEmpty) {
        return s.address;
      } else if (s.city.isNotEmpty) {
        return s.city;
      }
    }
    return "Kathmandu";
  }

  String get expiryLabel {
    if (endDate == null) return "Valid for all bookings";
    final now = DateTime.now();
    final diff = endDate!.difference(now);
    if (diff.isNegative) return "Expired";
    if (diff.inDays == 0) return "Ends today";
    if (diff.inDays <= 7) return "Ends in ${diff.inDays} days";
    return "Valid until ${endDate!.day}/${endDate!.month}/${endDate!.year}";
  }

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    Color parseColor(String? hex) {
      if (hex == null || hex.isEmpty) return const Color(0xFFEC4899);
      try {
        final clean = hex.replaceAll("#", "");
        return Color(int.parse("FF$clean", radix: 16));
      } catch (_) {
        return const Color(0xFFEC4899);
      }
    }

    IconData parseIcon(String? name) {
      switch (name?.toLowerCase()) {
        case 'spa':
          return Icons.spa_rounded;
        case 'cut':
        case 'scissors':
          return Icons.content_cut_rounded;
        case 'celebration':
          return Icons.celebration_rounded;
        case 'star':
          return Icons.auto_awesome_rounded;
        default:
          return Icons.local_offer_rounded;
      }
    }

    final offerId = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final codeStr = json['code']?.toString().toUpperCase() ?? '';

    List<OfferSalonModel> salons = [];
    if (json['applicableSalons'] != null && json['applicableSalons'] is List) {
      salons = (json['applicableSalons'] as List)
          .whereType<Map>()
          .map((s) => OfferSalonModel.fromJson(Map<String, dynamic>.from(s)))
          .toList();
    }

    List<String> categories = [];
    if (json['applicableCategories'] != null && json['applicableCategories'] is List) {
      categories = (json['applicableCategories'] as List).map((c) => c.toString()).toList();
    }

    return OfferModel(
      id: offerId,
      code: codeStr,
      title: json['title']?.toString() ?? 'Special Offer',
      description: json['description']?.toString() ?? '',
      discountType: json['discountType']?.toString() ?? 'fixed',
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble() ?? 0.0,
      maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      isActive: json['isActive'] ?? true,
      badgeColor: parseColor(json['badgeColor']?.toString()),
      category: json['category']?.toString() ?? 'Discounts',
      icon: parseIcon(json['iconName']?.toString()),
      applicableSalons: salons,
      applicableCategories: categories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'minOrderAmount': minOrderAmount,
      'maxDiscount': maxDiscount,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'category': category,
    };
  }
}
