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

  const Business({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.description,
    required this.images,
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
  });

  factory Business.fromMap(Map<String, dynamic> map) {
    return Business(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      categoryId: map['category_id']?.toString() ?? '',
      categoryName: map['category_name'] ?? map['categoryName'] ?? '',
      description: map['description'] ?? '',
      images: (map['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      ratingCount: (map['rating_count'] as num?)?.toInt() ?? 0,
      phone: map['phone'] ?? '',
      whatsapp: map['whatsapp'],
      address: map['address'] ?? map['location'] ?? '',
      openingHours: (map['opening_hours'] as Map?)?.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      imageUrl: map['imageUrl'] ?? map['image_url'],
      tags: (map['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      mapsUrl: map['maps_url'],
      city: map['city'] ?? '',
      district: map['district'] ?? '',
      location: map['location'],
    );
  }

  Map<String, dynamic> toMap() {
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
    };
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
