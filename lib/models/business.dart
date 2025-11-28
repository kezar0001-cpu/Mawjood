class Business {
  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
  final String city;
  final String district;
  final String description;
  final List<String> images;
  final String phone;
  final String whatsapp;
  final String mapsUrl;
  final String openingHours;

  const Business({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.city,
    required this.district,
    required this.description,
    required this.images,
    required this.phone,
    required this.whatsapp,
    required this.mapsUrl,
    required this.openingHours,
  });

  factory Business.fromMap(Map<String, dynamic> map) {
    return Business(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      categoryId: map['category_id']?.toString() ?? '',
      categoryName: map['category_name'] ?? '',
      city: map['city'] ?? '',
      district: map['district'] ?? '',
      description: map['description'] ?? '',
      images: (map['images'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      phone: map['phone'] ?? '',
      whatsapp: map['whatsapp'] ?? '',
      mapsUrl: map['maps_url'] ?? '',
      openingHours: map['opening_hours'] ?? '',
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
      'phone': phone,
      'whatsapp': whatsapp,
      'maps_url': mapsUrl,
      'opening_hours': openingHours,
    };
  }
}
