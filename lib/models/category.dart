import 'package:flutter/material.dart';

@immutable
class Category {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? icon;

  const Category({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.icon,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toString() ?? '',
      nameAr: map['name_ar']?.toString() ?? '',
      nameEn: map['name_en']?.toString() ?? '',
      icon: map['icon']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'icon': icon,
    };
  }

  String get displayName => nameAr.isNotEmpty ? nameAr : nameEn;

  IconData get iconData => _iconFromName(icon);

  Color get color => const Color(0xFF00897B);

  Category copyWith({
    String? id,
    String? nameAr,
    String? nameEn,
    String? icon,
  }) {
    return Category(
      id: id ?? this.id,
      nameAr: nameAr ?? this.nameAr,
      nameEn: nameEn ?? this.nameEn,
      icon: icon ?? this.icon,
    );
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
