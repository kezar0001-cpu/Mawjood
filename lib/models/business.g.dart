// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BusinessAdapter extends TypeAdapter<Business> {
  @override
  final int typeId = 0;

  @override
  Business read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Business(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String?,
      address: fields[3] as String?,
      phone: fields[4] as String?,
      whatsapp: fields[5] as String?,
      city: fields[6] as String?,
      category: fields[7] as String?,
      rating: fields[8] as double?,
      popularScore: fields[9] as int?,
      categoryId: fields[10] as String?,
      latitude: fields[11] as double?,
      longitude: fields[12] as double?,
      images: (fields[13] as List).cast<String>(),
      features: (fields[14] as List).cast<String>(),
      reviewCount: fields[15] as int,
      verified: fields[16] as bool,
      ownerId: fields[17] as String?,
      distanceKm: fields[18] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Business obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.address)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.whatsapp)
      ..writeByte(6)
      ..write(obj.city)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.rating)
      ..writeByte(9)
      ..write(obj.popularScore)
      ..writeByte(10)
      ..write(obj.categoryId)
      ..writeByte(11)
      ..write(obj.latitude)
      ..writeByte(12)
      ..write(obj.longitude)
      ..writeByte(13)
      ..write(obj.images)
      ..writeByte(14)
      ..write(obj.features)
      ..writeByte(15)
      ..write(obj.reviewCount)
      ..writeByte(16)
      ..write(obj.verified)
      ..writeByte(17)
      ..write(obj.ownerId)
      ..writeByte(18)
      ..write(obj.distanceKm);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
