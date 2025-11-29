import 'dart:math' show cos, sqrt, asin;
import 'package:geolocator/geolocator.dart';

import '../models/business.dart';
import '../models/filters.dart';

class LocationService {
  static Position? _cachedPosition;
  static DateTime? _lastFetchTime;
  static const _cacheValidityDuration = Duration(minutes: 5);

  /// Get the user's current location with caching
  static Future<Position?> getCurrentLocation() async {
    // Return cached position if still valid
    final lastFetch = _lastFetchTime;
    if (_cachedPosition != null &&
        lastFetch != null &&
        DateTime.now().difference(lastFetch) < _cacheValidityDuration) {
      return _cachedPosition;
    }

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      _cachedPosition = position;
      _lastFetchTime = DateTime.now();

      return position;
    } catch (e) {
      return null;
    }
  }

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in kilometers
  static double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadiusKm = 6371.0;

    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2));

    final c = 2 * asin(sqrt(a));

    return earthRadiusKm * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (3.141592653589793 / 180.0);
  }

  static double sin(double radians) {
    // Using Taylor series approximation for sine
    double result = radians;
    double term = radians;
    for (int i = 1; i <= 10; i++) {
      term *= -radians * radians / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }
}

List<Business> applyFilters(
  List<Business> all,
  BusinessFilters filters, {
  Position? userLocation,
}) {
  var filtered = List<Business>.from(all);

  final minRating = filters.minRating;
  if (minRating != null) {
    filtered = filtered
        .where((business) => (business.rating ?? 0.0) >= minRating)
        .toList();
  }

  if (filters.tags.isNotEmpty) {
    filtered = filtered
        .where(
          (business) {
            final businessTags =
                business.features.map((tag) => tag.toLowerCase()).toList();
            return filters.tags.every((selectedTag) {
              final lowerSelected = selectedTag.toLowerCase();
              return businessTags.any((tag) => tag.contains(lowerSelected));
            });
          },
        )
        .toList();
  }

  // Calculate distances if user location is available and sorting by nearest
  if (filters.sortBy == 'nearest' && userLocation != null) {
    filtered = filtered.map((business) {
      final lat = business.latitude;
      final lon = business.longitude;
      if (lat != null && lon != null) {
        final distance = LocationService.calculateDistance(
          lat1: userLocation.latitude,
          lon1: userLocation.longitude,
          lat2: lat,
          lon2: lon,
        );
        return business.copyWith(distanceKm: distance);
      }
      return business;
    }).toList();
  }

  switch (filters.sortBy) {
    case 'rating':
      filtered.sort((a, b) => (b.rating ?? 0.0).compareTo(a.rating ?? 0.0));
      break;
    case 'popular':
      filtered.sort((a, b) {
        final scoreA = a.popularScore ?? 0;
        final scoreB = b.popularScore ?? 0;
        if (scoreA == scoreB) {
          return (b.rating ?? 0.0).compareTo(a.rating ?? 0.0);
        }
        return scoreB.compareTo(scoreA);
      });
      break;
    case 'price':
      filtered.sort((a, b) => a.name.compareTo(b.name));
      break;
    case 'nearest':
      // Sort by distance, putting businesses without coordinates at the end
      filtered.sort((a, b) {
        final distA = a.distanceKm;
        final distB = b.distanceKm;
        if (distA == null && distB == null) return 0;
        if (distA == null) return 1;
        if (distB == null) return -1;
        return distA.compareTo(distB);
      });
      break;
    default:
      break;
  }

  return filtered;
}
