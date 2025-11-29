class Business {
  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
  final String description;
  final List<String> images;
  final double rating;
  final int ratingCount;
  final String phone;
  final String? whatsapp;
  final String address;
  final Map<String, String>? openingHours;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;
  final List<String> tags;
  final String? mapsUrl;
  final String city;
  final String district;
  final String? location;
  final int? popularScore;

  const Business({
    required this.id,
    required this.name,
    required this.categoryId,
    this.categoryName = '',
    required this.description,
    this.images = const [],
    this.rating = 0,
    this.ratingCount = 0,
    required this.phone,
    this.whatsapp,
    required this.address,
    this.openingHours,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.tags = const [],
    this.mapsUrl,
    this.city = '',
    this.district = '',
    this.location,
    this.popularScore,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      images: (json['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
      phone: json['phone']?.toString() ?? '',
      whatsapp: json['whatsapp']?.toString(),
      address: json['address']?.toString() ?? json['location']?.toString() ?? '',
      openingHours: (json['opening_hours'] as Map?)?.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString(),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      mapsUrl: json['maps_url']?.toString(),
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      location: json['location']?.toString(),
      popularScore: (json['popular_score'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'category_name': categoryName,
      'description': description,
      'images': images,
      'rating': rating,
      'rating_count': ratingCount,
      'phone': phone,
      'whatsapp': whatsapp,
      'address': address,
      'opening_hours': openingHours,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrl,
      'tags': tags,
      'maps_url': mapsUrl,
      'city': city,
      'district': district,
      'location': location,
      'popular_score': popularScore,
    };
  }

  Business copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? categoryName,
    String? description,
    List<String>? images,
    double? rating,
    int? ratingCount,
    String? phone,
    String? whatsapp,
    String? address,
    Map<String, String>? openingHours,
    double? latitude,
    double? longitude,
    String? imageUrl,
    List<String>? tags,
    String? mapsUrl,
    String? city,
    String? district,
    String? location,
    int? popularScore,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      description: description ?? this.description,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      address: address ?? this.address,
      openingHours: openingHours ?? this.openingHours,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      mapsUrl: mapsUrl ?? this.mapsUrl,
      city: city ?? this.city,
      district: district ?? this.district,
      location: location ?? this.location,
      popularScore: popularScore ?? this.popularScore,
    );
  }

  String? get primaryImage {
    if (imageUrl != null && imageUrl!.isNotEmpty) return imageUrl;
    if (images.isNotEmpty) return images.first;
    return null;
  }

  String get displayAddress {
    if (address.isNotEmpty) return address;
    if (location != null && location!.isNotEmpty) return location!;
    if (city.isNotEmpty || district.isNotEmpty) return '$city • $district'.trim();
    return '';
  }

  String get primaryOpeningHours {
    if (openingHours != null && openingHours!.isNotEmpty) {
      final entry = openingHours!.entries.first;
      return '${entry.key}: ${entry.value}';
    }
    return '';
  }
}
