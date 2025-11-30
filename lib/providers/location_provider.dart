import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/filter_service.dart';

// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// User location provider
final userLocationProvider = FutureProvider<Position?>((ref) async {
  final locationService = ref.watch(locationServiceProvider);

  try {
    return await locationService.getCurrentLocation();
  } catch (e) {
    // Return null if location permission denied or service unavailable
    return null;
  }
});

// Force refresh location
final refreshLocationProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    ref.invalidate(userLocationProvider);
  };
});
