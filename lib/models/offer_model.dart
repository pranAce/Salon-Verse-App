import 'package:flutter/material.dart';

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
  });

  String get discountLabel {
    if (discountType == 'percentage') {
      return "${discountValue.round()}% OFF";
    }
    return "Rs. ${discountValue.round()} OFF";
  }

  String get expiryLabel {
    if (endDate == null) return "Ongoing Offer";
    final diff = endDate!.difference(DateTime.now());
    if (diff.isNegative) return "Expired";
    if (diff.inDays == 0) return "Expires today";
    if (diff.inDays <= 7) return "Valid for ${diff.inDays} days";
    return "Valid till ${endDate!.day}/${endDate!.month}/${endDate!.year}";
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
          return Icons.card_giftcard_rounded;
      }
    }

    return OfferModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      code: json['code']?.toString().toUpperCase() ?? '',
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
