import 'package:flutter/foundation.dart';

@immutable
class Business {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? phone;
  final String? whatsapp;
  final String? city;
  final String? category;
  final double? rating;

  // ADD THIS FIELD
  final int? popularScore;

  Business({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.phone,
    this.whatsapp,
    this.city,
    this.category,
    this.rating,
    this.popularScore, // ADD THIS
  });

  factory Business.fromMap(Map<String, dynamic> map) {
    return Business(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      address: map['address'],
      phone: map['phone'],
      whatsapp: map['whatsapp'],
      city: map['city'],
      category: map['category'],
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : null,
      popularScore: map['popular_score'] != null ? (map['popular_score'] as num).toInt() : 0, // ADD THIS
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'whatsapp': whatsapp,
      'city': city,
      'category': category,
      'rating': rating,
      'popular_score': popularScore, // ADD THIS
    };
  }
}

  Business copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? description,
    String? city,
    String? address,
    String? phone,
    double? rating,
    double? latitude,
    double? longitude,
    List<String>? images,
    List<String>? features,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      city: city ?? this.city,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      rating: rating ?? this.rating,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      images: images ?? this.images,
      features: features ?? this.features,
    );
  }

  String? get primaryImage => images.isNotEmpty ? images.first : null;

  String get displayAddress {
    if (address.isNotEmpty && city.isNotEmpty) {
      return '$city • $address';
    }
    if (address.isNotEmpty) {
      return address;
    }
    return city;
  }
}
