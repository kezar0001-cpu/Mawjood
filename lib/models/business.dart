import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

part 'business.g.dart';

@immutable
@HiveType(typeId: 0)
class Business {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final String? address;

  @HiveField(4)
  final String? phone;

  @HiveField(5)
  final String? whatsapp;

  @HiveField(6)
  final String? city;

  @HiveField(7)
  final String? category;

  @HiveField(8)
  final double? rating;

  @HiveField(9)
  final int? popularScore;

  @HiveField(10)
  final String? categoryId;

  @HiveField(11)
  final double? latitude;

  @HiveField(12)
  final double? longitude;

  @HiveField(13)
  final List<String> images;

  @HiveField(14)
  final List<String> features;

  @HiveField(15)
  final int reviewCount;

  @HiveField(16)
  final bool verified;

  @HiveField(17)
  final String? ownerId;

  @HiveField(18)
  final double? distanceKm; // Distance from user's location

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
    this.reviewCount = 0,
    this.verified = false,
    this.ownerId,
    this.distanceKm,
  });

  factory Business.fromMap(Map<String, dynamic> map) {
    return Business(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'غير معروف',
      description: map['description']?.toString(),
      address: map['address']?.toString(),
      phone: map['phone']?.toString(),
      whatsapp: map['whatsapp']?.toString(),
      city: map['city']?.toString(),
      category: map['category']?.toString(),
      rating: map['rating'] != null ? (map['rating'] as num).toDouble() : null,
      popularScore: map['popular_score'] != null ? (map['popular_score'] as num).toInt() : 0,
      categoryId: map['category_id']?.toString(),
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      images: map['images'] != null ? List<String>.from(map['images']) : const [],
      features: map['features'] != null ? List<String>.from(map['features']) : const [],
      reviewCount: map['review_count'] != null ? (map['review_count'] as num).toInt() : 0,
      verified: map['verified'] == true,
      ownerId: map['owner_id']?.toString(),
      distanceKm: map['distance_km'] != null ? (map['distance_km'] as num).toDouble() : null,
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
      'review_count': reviewCount,
      'verified': verified,
      'owner_id': ownerId,
      'distance_km': distanceKm,
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
    int? reviewCount,
    bool? verified,
    String? ownerId,
    double? distanceKm,
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
      reviewCount: reviewCount ?? this.reviewCount,
      verified: verified ?? this.verified,
      ownerId: ownerId ?? this.ownerId,
      distanceKm: distanceKm ?? this.distanceKm,
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
