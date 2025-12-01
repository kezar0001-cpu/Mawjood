import 'package:hive/hive.dart';

class CachedData<T> {
  @HiveField(0)
  final T data;

  @HiveField(1)
  final DateTime cachedAt;

  @HiveField(2)
  final Duration validDuration;

  CachedData({
    required this.data,
    required this.cachedAt,
    required this.validDuration,
  });

  bool get isExpired {
    return DateTime.now().difference(cachedAt) > validDuration;
  }

  bool get isValid => !isExpired;
}
