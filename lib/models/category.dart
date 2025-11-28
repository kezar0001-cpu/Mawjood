import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    this.color = const Color(0xFF00897B),
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      icon: IconData(
        map['icon'] is int ? map['icon'] : Icons.category.codePoint,
        fontFamily: map['iconFont'] ?? 'MaterialIcons',
      ),
      color: map['color'] is int ? Color(map['color']) : const Color(0xFF00897B),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'iconFont': icon.fontFamily,
      'color': color.value,
    };
  }
}
