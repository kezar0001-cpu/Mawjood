import 'package:flutter/material.dart';

class Category {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? icon;
  final Color color;

  const Category({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.icon,
    this.color = const Color(0xFF00897B),
  });

  String get displayName => nameAr.isNotEmpty ? nameAr : nameEn;

  IconData get iconData => _iconFromName(icon);

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id']?.toString() ?? '',
      nameAr: json['name_ar']?.toString() ?? json['name']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? json['name']?.toString() ?? '',
      icon: json['icon']?.toString(),
      color: json['color'] is int
          ? Color(json['color'] as int)
          : const Color(0xFF00897B),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'icon': icon,
    };
  }

  static IconData _iconFromName(String? iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'cafe':
        return Icons.local_cafe;
      case 'clinic':
        return Icons.local_hospital;
      case 'store':
        return Icons.store;
      case 'service':
        return Icons.build;
      case 'education':
        return Icons.school;
      default:
        return Icons.category;
    }
  }
}
