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
  final int? popularScore;
  final String? categoryId;
  final double? latitude;
  final double? longitude;
  final List<String> images;
  final List<String> features;

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
    this.popularScore,
    this.categoryId,
    this.latitude,
    this.longitude,
    this.images = const [],
    this.features = const [],
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
      popularScore: map['popular_score'] != null ? (map['popular_score'] as num).toInt() : 0,
      categoryId: map['category_id'],
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      images: map['images'] != null ? List<String>.from(map['images']) : const [],
      features: map['features'] != null ? List<String>.from(map['features']) : const [],
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
      'popular_score': popularScore,
      'category_id': categoryId,
      'latitude': latitude,
      'longitude': longitude,
      'images': images,
      'features': features,
    };
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
    final safeAddress = address ?? '';
    final safeCity = city ?? '';
    if (safeAddress.isNotEmpty && safeCity.isNotEmpty) {
      return '$safeCity • $safeAddress';
    }
    if (safeAddress.isNotEmpty) {
      return safeAddress;
    }
    return safeCity;
  }
}
