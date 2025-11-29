import 'package:flutter/foundation.dart';

@immutable
class Business {
  final String id;
  final String name;
  final String categoryId;
  final String description;
  final String city;
  final String address;
  final String phone;
  final double rating;
  final double? latitude;
  final double? longitude;
  final List<String> images;
  final List<String> features;

  const Business({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.description,
    required this.city,
    required this.address,
    required this.phone,
    this.rating = 0,
    this.latitude,
    this.longitude,
    this.images = const [],
    this.features = const [],
  });

  factory Business.fromMap(Map<String, dynamic> map) {
    return Business(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      categoryId: map['category_id']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      images: (map['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      features:
          (map['features'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'description': description,
      'city': city,
      'address': address,
      'phone': phone,
      'rating': rating,
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
    if (address.isNotEmpty && city.isNotEmpty) {
      return '$city • $address';
    }
    if (address.isNotEmpty) {
      return address;
    }
    return city;
  }
}
