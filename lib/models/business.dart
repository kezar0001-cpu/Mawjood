class Business {
  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
  final String city;
  final String district;
  final String description;
  final List<String> images;
  final double rating;
  final String phone;
  final String whatsapp;
  final String mapsUrl;
  final String openingHours;
  final String? imageUrl;
  final String? location;

  const Business({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.city,
    required this.district,
    required this.description,
    required this.images,
    this.rating = 0,
    required this.phone,
    required this.whatsapp,
    required this.mapsUrl,
    required this.openingHours,
    this.imageUrl,
    this.location,
  });

  factory Business.fromMap(Map<String, dynamic> map) {
    return Business(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      categoryId: map['category_id']?.toString() ?? '',
      categoryName: map['category_name'] ?? map['categoryName'] ?? '',
      city: map['city'] ?? '',
      district: map['district'] ?? '',
      description: map['description'] ?? '',
      images: (map['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      phone: map['phone'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      mapsUrl: map['maps_url'] ?? '',
      openingHours: map['opening_hours'] ?? '',
      imageUrl: map['imageUrl'] ?? map['image_url'],
      location: map['location'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'category_name': categoryName,
      'city': city,
      'district': district,
      'description': description,
      'images': images,
      'rating': rating,
      'phone': phone,
      'whatsapp': whatsapp,
      'maps_url': mapsUrl,
      'opening_hours': openingHours,
      'image_url': imageUrl,
      'location': location,
    };
  }
}
